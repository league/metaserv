open Unix

type log =
    { chan: out_channel;
      mutex: Mutex.t }

let with_locked log writer =
  Mutex.lock log.mutex;
  seek_out log.chan (out_channel_length log.chan);
  writer log.chan;
(*  flush log.chan; *)
  Mutex.unlock log.mutex

let tstamp writer =
  let tm = localtime(time()) in
  fun chan -> 
    Printf.fprintf chan "%4d-%02d-%02d %02d:%02d:%02d "
      (tm.tm_year+1900) (tm.tm_mon+1) tm.tm_mday 
      tm.tm_hour tm.tm_min tm.tm_sec;
    writer chan

let write_line line chan =
  output_string chan line;
  output_char chan '\n'

let add log line = 
  with_locked log (tstamp (write_line line))

let flags = [Open_wronly; Open_append; Open_creat]

let create name =
  let chan = open_out_gen flags 0o600 name in
  let log = {chan=chan; mutex=Mutex.create()} in
  let () = add log "log opened" in
  log

let close log = 
  add log "log closed";
  close_out log.chan

type session =
    { i: in_channel;
      o: out_channel;
      req: Request.req;
      log: log }

let access log addr req status =
  let addr = 
    try 
      match addr with
        ADDR_UNIX s -> s
      | ADDR_INET(a,_) -> string_of_inet_addr a
    with _ -> "-" in
  let put ch =
    Printf.fprintf ch "t%-4d %-15s %3d %.1f %s %-15s [%s]\n"
      (Thread.id (Thread.self())) addr 
      (Status.code status) 
      (Request.version req)
      (Request.meth' req) 
      (Request.query req)
      (match Request.header req "User-agent" with
        None -> "-" | Some ua -> ua) in

  with_locked log (tstamp put)

