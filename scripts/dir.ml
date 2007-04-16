module Dir = struct
               (* About half this file is -*- caml -*- code... *)
  open List
  open Printf
  let val_of opt default = 
    match opt with None -> default | Some x -> x
 
  open Unix

  type fileinfo =
      { name: string;          (* these fields suitable for sorting *)
        ext: string;
        kind: string;
        mtime: float;
        size: int;
        md5: string;
        prn: string
      }

  let by order f1 f2 = match order with
    Some "ext" -> compare f1.ext f2.ext
  | Some "kind" -> compare f1.kind f2.kind
  | Some "time" -> compare f1.mtime f2.mtime
  | Some "size" -> compare f1.size f2.size
  | _ -> compare f1.name f2.name

  let human_size n = 
    if n < 1024 then sprintf "%4d " n
    else if n < 102400 then sprintf "%4.1fk" (float_of_int n/.1024.)
    else if n < 1024000 then sprintf "%4dk" (n/1024)
    else if n < 104857600 then sprintf "%4.1fM" (float_of_int n/.1048576.)
    else sprintf "%4dM" (n/1048576)

  let entry_fmt = format_of_string
      "<span class=\"md5\">%-32s</span>  %-29s  %5s  \
       <a href=\"%s\" class=\"file\"><span class=\"%s\">\
       %s%s</span></a>\n"

  let header = sprintf
      "<b>%-32s  %-29s  %-5s  %s</b>\n"
      "checksum" "modification time" "size" "name"

  let fileinfo d dh =
    let name = readdir dh in
    let path = Filename.concat d name in
    let st = stat path in
    let md5 = 
      if st.st_kind = S_REG 
      then Digest.to_hex (Digest.file path)
      else "" in
    let ext = 
      try let i = String.rindex name '.' + 1 in
          Str.string_after name i
      with Not_found -> "" in
    let (kind, indicator) = 
      match st.st_kind with
      | S_DIR  -> ("dir", "/")
      | S_LNK  -> ("symlink", "@")
      | S_FIFO -> ("fifo", "|")
      | S_SOCK -> ("sock", "=")
      | S_CHR  -> ("cdev", "")
      | S_BLK  -> ("bdev", "")
      | S_REG ->
          let k =
            match ext with
            | "a"   -> "lib"
            | "cma" -> "lib"
            | "ppc-darwin" -> "lib"
            | "x86-linux" -> "lib"
            | "cmi" -> "obj"
            | "cmo" -> "obj"
            | "ml"  -> "src"
            | "mli" -> "hdr"
            | "sml"  -> "src"
            | "sig" -> "hdr"
            | "txt" -> "doc"
            | "tex" -> "doc"
            | "pdf" -> "doc"
            | _ -> "" in
          let i =
            if st.st_perm land 0o111 = 0 then "" else "*" in
          match (k,i) with
          | ("", "*") -> ("exe", "*")
          | other -> other in
    let prn = 
      sprintf entry_fmt md5
        (TimeStamp.format st.st_mtime) 
        (human_size st.st_size)
        name kind name indicator
    in
    {name=name; ext=ext; kind=kind;
      mtime=st.st_mtime; size=st.st_size;
      prn=prn; md5=md5}

  let list_files d regex =
    .<let list = [] in
      .~(let dh = opendir d in
         let rec loop plug =
           try let file = fileinfo d dh in
               .<let list = 
                   try let _ = Str.search_forward .~regex file.name 0 in
                       file:: .~plug
                   with Not_found -> .~plug
                 in .~(loop .<list>.)>.
           with End_of_file -> closedir dh; plug in
         loop .<list>.) >.
 let page  d  = .<fun req puts ->
let arg = Request.arg req in
puts "\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"\n    \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n\n<html xmlns=\"http://www.w3.org/1999/xhtml\">\n  <head>\n    <title>Directory: ";
puts (d);
puts "</title>\n    <link href=\"/meta.css\" rel=\"stylesheet\" type=\"text/css\" />\n  </head>\n<body>\n<h1>Directory listing of &lsquo;";
puts (d);
puts "&rsquo;</h1>\n\n<p>This page was produced by a MetaOCaml program.  The filenames,\ndates, sizes, and MD5 checksums were produced ahead of time, in stage\none.  Stage two, executed in response to your request merely sorts and\nfilters the entries.  This substantially reduces the number of system\ncalls and disk accesses needed to handle each request.</p>\n\n";
 let re = val_of (arg "re") ".*"  in 
 let rc = Str.regexp re  in 
let list = .~( list_files d .<rc>. ) in
 let list = stable_sort (by (arg "ord")) list in puts "\n\n";
Printf.kprintf puts "%d" ( length list) ;
puts " files in directory.\n\n<form method=\"get\">\nOrder:\n  <select name=\"ord\">\n    <option value=\"name\">Name</option>\n    <option value=\"ext\" >Extension</option>\n    <option value=\"time\">Timestamp</option>\n    <option value=\"size\">Size</option>\n    <option value=\"kind\">Kind</option>\n  </select>\nFilter: \n  <input type=\"text\" name=\"re\" size=\"14\" value=\"";
puts (re);
puts "\" />\n  <input type=\"submit\" value=\"Redisplay\" />\n</form>\n\n<pre>\n";
puts (header);
 iter (fun f -> puts f.prn) list ;
puts "</pre>\n<hr/>\nMetaOCaml ";
puts (Sys.ocaml_version);
puts "\n</body>\n</html>\n";

>.
end
