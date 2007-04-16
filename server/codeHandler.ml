
module type CodeHandler =
  sig
    val run : Server.handler
    val redirect : Server.handler
  end

module CodeHandler : CodeHandler = struct

  let chunked_response f o =
    output_string o "Transfer-encoding: chunked\r\n\r\n";
    flush o;
    let ch = Chunked.create o 512 in
    f (Chunked.puts ch);
    Chunked.finish ch;
    (* footers go here *)
    output_string o "\r\n"

  let buffered_response f o =
    let buf = Buffer.create 512 in
    f (Buffer.add_string buf);
    Printf.fprintf o "Content-length: %d\r\n" (Buffer.length buf);
    (* headers go here *)
    output_string o "\r\n";
    Buffer.output_buffer o buf

  let choose_response req =
    if Request.version req < 1.1 then buffered_response
    else chunked_response

  let mutex = Mutex.create()

(* NEED A WAY FOR script function to send additional headers *)
(* would be nice to support HEAD *)
  let run req o =
   (match Request.meth req with
      Request.GET ->
        let code = StringMap.find (Request.uri req) code_map in
        let fn puts = 
          try 
            (*Mutex.lock mutex;
            let code = .!code in 
            Mutex.unlock mutex;*)
            code req puts
          with e ->
            Printf.kprintf puts
              "<b>Unhandled exception: %s</b>" (Printexc.to_string e) in
        Printf.fprintf o
          "HTTP/1.1 200 OK\r\n\
          Server: MetaOCaml/%s\r\n\
          Connection: %s\r\n\
          Date: %s\r\n\
          Content-type: text/html\r\n"
                Sys.ocaml_version
                (Request.keep_alive req)
                (TimeStamp.now());
        choose_response req fn o;
        Status.Ok
    | _ -> raise Server.Not_implemented)

(* Here is a separate handler that redirects if adding a slash
   to the uri would cause a match in the code_map, i.e., 
   "/dir" --> "/dir/" 
 *)

  let redirect req o =
    (match Request.meth req with
      Request.GET ->
        let uri' = Request.uri req ^ "/" in
        let _ = StringMap.find uri' code_map in
        let url = "http://" in
        let url = url^Unix.gethostname() in
        let url = 
          match Unix.getsockname (Unix.descr_of_out_channel o) with
            Unix.ADDR_INET(_,p) -> Printf.sprintf "%s:%d" url p
          | _ -> url (* bogus anyway *) in
        let url = url^uri' in
        let page puts =
          Printf.kprintf puts "Go <a href=\"%s\">here</a>.\n" url in
        Printf.fprintf o
          "HTTP/1.1 301 Moved Permanently\r\n\
          Server: MetaOCaml/%s\r\n\
          Connection: %s\r\n\
          Date: %s\r\n\
          Location: %s\r\n\
          Content-type: text/html\r\n"
                Sys.ocaml_version
                (Request.keep_alive req)
                (TimeStamp.now())
                url;
        choose_response req page o;
        Status.Moved_permanently
     | _ -> raise Server.Not_implemented)
                    
end
