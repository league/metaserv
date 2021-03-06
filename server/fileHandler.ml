open Unix
open Server

let check_dir d = 
  if (stat d).st_kind <> S_DIR
  then raise (Unix_error (ENOTDIR,"check_dir",d))

let parent_regex = 
  Str.regexp (".*" ^ (Str.quote Filename.parent_dir_name))

let check_uri uri = 
  try 
    if String.get uri 0 <> '/' then raise Forbidden
    else if Str.string_match parent_regex uri 0 then raise Forbidden
    else String.sub uri 1 (String.length uri - 1)
  with
    Invalid_argument _ -> raise Forbidden

let default_content_type = "text/plain"

let content_type path = 
  try 
    let i = String.rindex path '.' + 1 in
    let k = String.length path - i in
    let ext = String.sub path i k in
    match ext with
    | "html" -> "text/html"
    | "htm" -> "text/html"
    | "txt" -> "text/plain"
    | "png" -> "image/png"
    | "gif" -> "image/gif"
    | "jpg" -> "image/jpeg"
    | "pdf" -> "application/pdf"
    | _ -> default_content_type
  with Not_found -> default_content_type

let headers req o (path, st) =
  Printf.fprintf o
   "HTTP/1.1 200 OK\r\n\
    Server: MetaOCaml/%s\r\n\
    Connection: %s\r\n\
    Date: %s\r\n\
    Last-modified: %s\r\n\
    Content-type: %s\r\n\
    Content-length: %d\r\n\r\n"
          Sys.ocaml_version
          (Request.keep_alive req)
          (TimeStamp.now())
          (TimeStamp.format st.st_mtime)
          (content_type path)
          st.st_size

let copy o' (path, st) =
  flush o';
  let o = descr_of_out_channel o' in
  let i = openfile path [O_RDONLY] 0 in
  let size = min st.st_size Server.bufsize in
  let buf = String.create size in
  while
    match read i buf 0 size with
      0 -> false
    | n -> let m = write o buf 0 n in
           if m <> n then failwith "FileHandler.copy: not all bytes written";
           true
  do()
  done;
  close i
 
let stat' path = 
  try stat path
  with Unix_error(ENOENT,_,_) -> raise Not_found

let rec find path st =
  match st.st_kind with
  | S_DIR -> 
      let path = Filename.concat path "index.html"
      in find path (stat' path)
  | S_REG -> 
      if st.st_perm land 0o004 = 0      (* world-readable? *)
      then raise Forbidden
      else (path, st)
  | _ -> raise Forbidden

open LogFile
let root d = 
  (check_dir d;
   fun req o ->
     match Request.meth req with
       (Request.GET | Request.HEAD) ->
         let uri = check_uri (Request.uri req) in
         let path = Filename.concat d uri in
         let r = find path (stat' path) in 
         (try
           headers req o r;
           if Request.meth req = Request.GET
           then copy o r;
           Status.Ok
         with
           Sys_error "Broken pipe" -> raise Exit)
     | _ -> raise Not_implemented)
