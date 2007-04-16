
(* HTTP requires "\r\n" as the line ending, so input_line will leave
   behind the "\r".  Here we rebind input_line to remove the '\r' if
   present. *)

let get_line i = 
   let s = Pervasives.input_line i in
   let n = String.length s - 1 in
   if n >= 0 && '\r' = String.get s n
   then String.sub s 0 n
   else s

type meth =
    OPTIONS
  | GET
  | HEAD
  | POST
  | PUT
  | DELETE
  | TRACE
  | OTHER of string

type req = 
    { meth: meth;
      query: string;
      uri: string;
      version: float;
      headers: string StringMap.t;
      args: string StringMap.t }

let header req key = 
  try Some (StringMap.find (String.lowercase key) req.headers)
  with Not_found -> None

let arg req key = 
  try Some (StringMap.find key req.args)
  with Not_found -> None

let request_regex = 
  Str.regexp "\\([A-Z]+\\)[ \t]+\\([^ \t]+\\)[ \t]+HTTP/\\([0-9\\.]+\\)"
let header_regex = Str.regexp "\\([^ \t]+\\):[ \t]+\\(.*\\)"
let cont_regex = Str.regexp "[ \t]+\\(.*\\)"

let add k v m =
(* Printf.printf "%s: %s\n%!" k v; *)
  StringMap.add k v m

let rec read_headers map key i = 
  let s = get_line i in
  let oops() = read_headers map key i in
  (if s = "" then map
   else if Str.string_match header_regex s 0
   then let key = String.lowercase (Str.matched_group 1 s) in
        let map = add key (Str.matched_group 2 s) map in
        read_headers map (Some key) i
   else if Str.string_match cont_regex s 0
   then match key with 
          None -> oops()
        | Some k -> let v = StringMap.find k map in
                    let v = v^" "^(Str.matched_group 1 s) in
                    let map = add k v map in
                    read_headers map (Some k) i
   else oops())

let meth_of_string s = match s with
  "OPTIONS" -> OPTIONS
| "GET"     -> GET    
| "HEAD"    -> HEAD   
| "POST"    -> POST   
| "PUT"     -> PUT    
| "DELETE"  -> DELETE 
| "TRACE"   -> TRACE  
| _ -> OTHER s

let string_of_meth m = match m with
  OPTIONS -> "OPTIONS"
| GET     -> "GET"    
| HEAD    -> "HEAD"   
| POST    -> "POST"  
| PUT     -> "PUT"  
| DELETE  -> "DELETE"
| TRACE   -> "TRACE"
| OTHER s -> s

let query_delim = Str.regexp_string "&"
let url_coding_regex = Str.regexp "+\\|%[0-9a-fA-F][0-9a-fA-F]"

let url_subst s = 
  let i = Str.match_beginning() in
  if String.get s i = '+' then " " 
  else
    let hex = "0x" ^ String.sub s (i+1) 2 in
    let int = int_of_string hex in
    let char = char_of_int int in
    String.make 1 char

let parse_query q =
  try
    let i = String.index q '?' in
    let uri = Str.string_before q i in
    let args = Str.split query_delim (Str.string_after q (i+1)) in
    let each arg map =
      try 
        let j = String.index arg '=' in
        let key = Str.string_before arg j in
        let v = Str.string_after arg (j+1) in
        let v = Str.global_substitute url_coding_regex url_subst v in
        Printf.printf "%s -> %s\n%!" key v;
        StringMap.add key v map
      with
        Not_found -> map in
    (uri, List.fold_right each args StringMap.empty)
  with
    Not_found -> (q, StringMap.empty)

let read i = 
  let s = get_line i 
  in (if not(Str.string_match request_regex s 0)
      then failwith("read_request: "^s);
      let meth = String.uppercase (Str.matched_group 1 s) in
      let query = Str.matched_group 2 s in
      let version = float_of_string(Str.matched_group 3 s) in
      let headers = read_headers StringMap.empty None i in
      let (uri, args) = parse_query query in
      { meth = meth_of_string meth;
        uri = uri;
        query = query;
        version = version;
        args = args;
        headers = headers })

let dump puts req =
  (Printf.kprintf puts
     "<p>This is in response to your HTTP/%.1f %s request for \
     the resource &ldquo;%s&rdquo;.</p>\n\
     <h3>Request headers</h3>\n<dl>\n"
     req.version
     (string_of_meth req.meth)
     req.uri;
   StringMap.iter 
     (fun k -> Printf.kprintf puts "<dt><i>%s:</i></dt><dd>%s</dd>\n" k)
     req.headers;
   Printf.kprintf puts "</dl></p>\n")

let version {version=x} = x
let uri {uri=x} = x
let query {query=x} = x
let meth {meth=x} = x
let meth' {meth=x} = string_of_meth x

let conn req =
  match header req "connection" with
  | None -> None
  | Some s -> Some (String.lowercase s)

(* should optimize this; compute it once and store a flag *)

let keep_alive_p req =
  match (version req > 1.0, conn req) with
    (* HTTP/1.1 stays alive unless Connection: close specified *)
  | (true, Some "close") -> false
  | (true, _) -> true
    (* HTTP/1.0 stays alive only if Connection: keep-alive specified *)
  | (false, Some "keep-alive") -> true  (* this breaks wget? *)
  | (false, _) -> false

let keep_alive req =
  if keep_alive_p req then "Keep-Alive"
  else "close"
