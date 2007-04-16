type page = Request.req -> (string -> unit) -> unit
type map = ((unit -> page) * page ref) StringMap.t

  let chunked_response f o =
    output_string o "Transfer-encoding: chunked\r\n\r\n";
    flush o;
    let ch = Chunked.channel o Server.bufsize in
    f (Chunked.puts ch);
    Chunked.finish ch;
    (* footers go here *)
    output_string o "\r\n"

  let buffered_response f o =
    let buf = Buffer.create Server.bufsize in
    f (Buffer.add_string buf);
    Printf.fprintf o "Content-length: %d\r\n" (Buffer.length buf);
    (* headers go here *)
    output_string o "\r\n";
    Buffer.output_buffer o buf

  let choose_response req =
    if Request.version req < 1.1 then buffered_response
    else chunked_response

  let headers o req st =
    Printf.fprintf o
      "HTTP/1.1 %d %s\r\n\
       Server: MetaOCaml/%s\r\n\
       Connection: %s\r\n\
       Date: %s\r\n\
       Content-type: text/html\r\n"
           (Status.code st) (Status.text st)
           Sys.ocaml_version
           (Request.keep_alive req)
           (TimeStamp.now())

  let mutex = Mutex.create()

(* NEED A WAY FOR script function to send additional headers *)
(* would be nice to support HEAD *)
  let run map req o =
   (match Request.meth req with
      Request.GET ->
        let _, code = StringMap.find (Request.uri req) map in
        let fn puts = 
          try 
            (*Mutex.lock mutex;
            let code = .!code in 
            Mutex.unlock mutex;*)
            !code req puts
          with e ->
            Printf.kprintf puts
              "<b>Unhandled exception: %s</b>" (Printexc.to_string e) in
        headers o req Status.Ok;
        choose_response req fn o;
        Status.Ok
    | _ -> raise Server.Not_implemented)

(* This one is for already-compiled code (not using META features) *)
  let runc map req o =
   (match Request.meth req with
      Request.GET ->
        let handler = StringMap.find (Request.uri req) map in
        let fn puts = 
          try handler req puts
          with e ->
            Printf.kprintf puts
              "<b>Unhandled exception: %s</b>" (Printexc.to_string e) in
        headers o req Status.Ok;
        choose_response req fn o;
        Status.Ok
    | _ -> raise Server.Not_implemented)

(* Here is a separate handler that redirects if adding a slash
   to the uri would cause a match in the code_map, i.e., 
   "/dir" --> "/dir/" 
 *)

  let redirect map req o =
    (match Request.meth req with
      Request.GET ->
        let uri' = Request.uri req ^ "/" in
        let _ = StringMap.find uri' map in
        let url = "http://" in
        let url = url^Unix.gethostname() in
        let url = 
          match Unix.getsockname (Unix.descr_of_out_channel o) with
            Unix.ADDR_INET(_,p) -> Printf.sprintf "%s:%d" url p
          | _ -> url (* bogus anyway *) in
        let url = url^uri' in
        let page puts =
          Printf.kprintf puts "Go <a href=\"%s\">here</a>.\n" url in
        headers o req Status.Moved_permanently;
        Printf.fprintf o "Location: %s\r\n" url;
        choose_response req page o;
        Status.Moved_permanently
     | _ -> raise Server.Not_implemented)

(* This one only applies if the uri ends with "!".  It will 
   force regeneration of the page. *)
                    
  let regenerate map req o =
    (match Request.meth req with
      Request.GET | Request.POST ->
        let uri = Request.uri req in
        let n = String.length uri - 1 in
        if String.get uri n <> '!'
        then raise Not_found;
        let uri' = String.sub uri 0 n in
        let (mk, cache) = StringMap.find uri' map in
        cache := mk();
        let url = "http://" in
        let url = url^Unix.gethostname() in
        let url = 
          match Unix.getsockname (Unix.descr_of_out_channel o) with
            Unix.ADDR_INET(_,p) -> Printf.sprintf "%s:%d" url p
          | _ -> url (* bogus anyway *) in
        let url = url^uri' in
        let page puts =
          Printf.kprintf puts "Go <a href=\"%s\">here</a>.\n" url in
        headers o req Status.Moved_permanently;
        Printf.fprintf o "Pragma: no-cache\r\nLocation: %s\r\n" url;
        choose_response req page o;
        Status.Moved_permanently
     | _ -> raise Server.Not_implemented)
