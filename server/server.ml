open Unix

let bufsize = 4096

module TMap = Map.Make
    (struct 
      type t = Thread.t
      let compare t1 t2 = compare (Thread.id t1) (Thread.id t2)
    end)

type server = 
    { mutable threads: Unix.file_descr TMap.t;
      sock: Unix.file_descr;
      log: LogFile.log;
      mutex: Mutex.t }

let stop server =
  Printf.printf "STOP received: shutting down\n%!";
  shutdown server.sock SHUTDOWN_ALL;
  Mutex.lock server.mutex;
  let ts = server.threads in
  Mutex.unlock server.mutex;
  TMap.iter (fun t s -> shutdown s SHUTDOWN_ALL) ts;
  sleep 2;
  LogFile.close server.log

let threaded_server log session_fun sock_addr =

  let announce_death() =
    Printf.kprintf (LogFile.add log) 
      "t%d terminated" (Thread.id (Thread.self())) in
  
  let domain =
    match sock_addr with 
    | ADDR_UNIX _ -> PF_UNIX
    | ADDR_INET _ -> PF_INET in

  let sock = socket domain SOCK_STREAM 0 in

  let server: server =
    { threads = TMap.empty;
      sock = sock;
      log = log;
      mutex = Mutex.create() } in

  let cleanup o =
    Mutex.lock server.mutex;
    server.threads <- TMap.remove (Thread.self()) server.threads;
    Mutex.unlock server.mutex;
    close_out_noerr o;
    LogFile.thread log false in

  let session (fd,a) =
    LogFile.thread log true;
    Mutex.lock server.mutex;
    server.threads <- TMap.add (Thread.self()) fd server.threads;
    Mutex.unlock server.mutex;
    let i = in_channel_of_descr fd in
    let o = out_channel_of_descr fd in
    try 
      session_fun(a,i,o); 
      raise Exit
    with
      Exit -> cleanup o
    | other -> cleanup o; raise other in

  let master() = 
    setsockopt sock SO_REUSEADDR true;
    bind sock sock_addr;
    listen sock 8;
    try
      while true do
        let cn = 
          try accept sock 
          with Unix_error _ -> raise Exit in
        ignore(Thread.create session cn)
      done 
    with
      Exit -> LogFile.thread log false
    | Sys.Break -> stop server in

  master();
  server

let error_handler req out status =
  let title = 
    Printf.sprintf "%d: %s" 
      (Status.code status) 
      (Status.text status) in
  let buf = Buffer.create 1024 in
  let puts = Buffer.add_string buf in
  Printf.kprintf puts                   (* construct html page *)
    "<html><head><title>%s</title></head>\n\
    <body><h1>%s</h1>\n"
    title title;
  Request.dump puts req;
  Printf.kprintf puts
    "<h3>Server information</h3><i>MetaOCaml %s</i>\n\
    </body></html>\n"
    Sys.ocaml_version;
  Printf.fprintf out                   (* ship page to client *)
    "HTTP/1.1 %d %s\r\n\
    Server: MetaOCaml/%s\r\n\
    Connection: %s\r\n\
    Content-type: text/html\r\n\
    Content-length: %d\r\n\r\n"
          (Status.code status)
          (Status.text status)
          Sys.ocaml_version
          (Request.keep_alive req)
          (Buffer.length buf);
  if Request.meth req <> Request.HEAD
  then Buffer.output_buffer out buf;
  status

exception Not_implemented
exception Forbidden

let status_of_exn exn = match exn with
| Exit -> Status.Ok
| Not_found -> Status.Not_found
| Forbidden -> Status.Forbidden
| Not_implemented -> Status.Not_implemented
| _ -> Status.Server_error

let start 
    ?(port = 1080)
    ?(logfile = "server.log")
    handlers =

  let log = LogFile.create logfile in

  let connect'(a,i,o) = 
    let req = Request.read i in
    let record = LogFile.access log a req in
    let rec loop exn hs = 
      match hs with
        [] -> record (error_handler req o (status_of_exn exn))
      | h::hs -> 
          try record (h req o)
          with Exit -> raise Exit
          | exn -> loop exn hs in
    loop Not_implemented handlers;
    flush o;
    Request.keep_alive_p req in
    
  let connect aio = 
    while 
      try connect' aio with _ -> false
    do () done in

  let addr = ADDR_INET(inet_addr_any, port) in
  threaded_server log connect addr

type handler = Request.req -> out_channel -> Status.t
