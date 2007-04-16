.<fun req puts ->
  let arg = Request.arg req in
  puts "<html>\n<head>\n<title>MetaOCaml...";
  let (re,rc) = match arg "re" with
          None -> default_re | Some r -> (r, Str.regexp r) 
  let list = 
      try ignore(Str.search_forward rc "timeStamp.mli" 0);
          [{name="timeStamp.mli", prn="...", ...}]
      with Not_found -> [] in
  let list =
      try ignore(Str.search_forward rc "timeStamp.ml" 0);
          {name="timeStamp.ml", prn="...", ...} :: list
      with Not_found -> list in
  let list =
      try ignore(Str.search_forward rc "timeStamp.cmo" 0);
          {name="timeStamp.cmo", prn="...", ...} :: list
      with Not_found -> list in
    :  (* and so on, for the rest of the files. *)
  let ord = match arg "ord" with
          None -> "name" | Some o -> o in
  let list = sort_by ord list
  puts "<form method='get' ...";
   :  (* etc. *)
 >.
