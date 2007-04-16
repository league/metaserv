open Printf 
open Unix 

let default_re = let r = "^[^\\.].*[^~]$" in (r, Str.regexp r) 
type fileinfo = { name: string; ext: string; kind: string;
      mtime: float; size: int; md5: string; prn: string } 
let cex f1 f2 = compare f1.ext f2.ext
    let ck f1 f2 = compare f1.kind f2.kind
    let cmt f1 f2 = compare f1.mtime f2.mtime
    let csz f1 f2 = compare f1.size f2.size
    let sort_by order list = match order with
     | "ext"  -> List.stable_sort cex list | "kind" -> List.stable_sort ck list
     | "time" -> List.stable_sort cmt list | "size" -> List.stable_sort csz list
     | _ -> list 
let entry_fmt = format_of_string
"<span class='md5'>%-32s</span>  %-13s  %5s  <a class='file' \
  href='%s'><span class='%s'>%s</span></a>%s\n"
let header = sprintf
 "<b>%-32s  %-13s  %-5s  %s</b>\n"
 "checksum" "last modified" "size" "name" 
let human_size n = 
     if n < 1024 then sprintf "%4d " n
     else if n < 102400 then sprintf "%4.1fk" (float_of_int n/.1024.)
     else if n < 1024000 then sprintf "%4dk" (n/1024)
     else if n < 104857600 then sprintf "%4.1fM" (float_of_int n/.1048576.)
     else sprintf "%4dM" (n/1048576) 
let reg_kinds ext perm =
     let k = match ext with
       | "a"->"lib" | "cma"->"lib" | "cmi"->"obj" | "cmo"->"obj"
       | "ml"->"src" | "sml"->"src" | "mli"->"hdr" | "sig"->"hdr"
       | _->"" in
     let i = if perm land 0o111 = 0 then "" else "*" in
     match (k,i) with
       | ("", "*") -> ("exe", "*") | other -> other 
let fileinfo d f =
      let path = Filename.concat d f in
      let st = stat path in
(*      Printf.printf "stat %s\n" path; *)
      let md5 = if st.st_kind = S_REG 
        then Digest.to_hex(Digest.file path) else "" in
      let ext = try let i = String.rindex f '.' + 1 in Str.string_after f i
                with Not_found -> "" in
      let (kind, indicator) = match st.st_kind with
        | S_DIR->("dir", "/") | S_FIFO->("fifo", "|")
        | S_BLK->("bdev", "") | S_CHR->("cdev", "")
        | S_LNK->("link", "@") | S_SOCK->("sock", "=")
        | S_REG->reg_kinds ext st.st_perm
      in let prn = sprintf entry_fmt md5 (TimeStamp.brief st.st_mtime) 
                     (human_size st.st_size) f kind f indicator
      in {name=f; ext=ext; kind=kind; md5=md5; mtime=st.st_mtime; 
          size=st.st_size; prn=prn} 
let rc x y = - (compare x y)
    let rec read_all dh files = try read_all dh (readdir dh :: files)
        with End_of_file -> closedir dh; List.sort rc files 
let list_files d re =
  let rec loop term files =
    match files with [] -> term
    | name::files ->
      (let list =
          try ignore(Str.search_forward re name 0);
              ((fileinfo d name)) :: term
          with Not_found -> term
        in (loop (list) files)) 
in loop ([]) (read_all (opendir d) [])
let rec ord_options puts ord opts = 
      match opts with [] -> () | (tag,text)::opts ->
      (kprintf puts "<option %s value='%s'>%s</option>\n"
         (if ord = tag then "selected" else "") tag text;
        (ord_options puts ord opts)) 
(* End of `dir.meta' *)

let page d  = (fun req puts ->
let arg = Request.arg req in
puts (Navspec.preamble("browsing "^d) ^ Navspec.navbar "" );
let (re,rc) = match arg "re" with 
          None -> default_re | Some r -> (r, Str.regexp r)  in 
let list = list_files d rc  in 
let ord = match arg "ord" with 
          None -> "name"  | Some o -> o in
  let list = sort_by ord list in puts "<form method='get' action=''>\n<input type='submit' value='Redisplay' /> files matching\n<input type='text' name='re' size='14' value='";
puts (re);
puts "' />\nordered by <select name='ord'>\n";
ord_options puts ord
      ["name", "Name"; "ext",  "Extension";
       "time", "Timestamp"; "size", "Size";
       "kind", "Kind"] ;
puts " </select></form>\n";
puts "<pre>\n";
puts (header (* column heads *) );
List.iter (fun f->puts f.prn) list ;
puts "</pre>\n<form method='post' action='";
puts ("");
puts "!'>\n<input type='submit' value='Regenerate' /></form>\n";
puts (Navspec.postamble  (* page ends *) ))

