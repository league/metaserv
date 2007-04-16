(* returns a pair of lists: one for the top-level menu, with a boolean
   flag indicating which is selected; another for the sub-menu, again
   with a flag. *)

type spec = (string * string * (string * string) list) list

let flag tag (uri,txt) = 
  if tag = uri then (uri,txt,true)
  else (uri,txt,false)

let rec find spec tag top sub =
  match spec, sub with
    [], None -> (List.rev top, [])
  | [], Some sub -> (List.rev top, sub)
  | (uri,txt,ch)::spec, _ ->
      if tag = uri or List.exists (fun (u,_) -> tag=u) ch 
      then find spec tag ((uri,txt,true)::top) (Some (List.map (flag tag) ch))
      else find spec tag ((uri,txt,false)::top) sub

let rec iter f i list = 
  match list with
    [] -> ()
  | x::xs -> f i x; iter f (i+1) xs

open Buffer
let gen spec tag =
  let buf = create 1024 in
  let sel = ref 0 in
  let each top_p i (uri,txt,select_p) =
    add_string buf
      (Printf.sprintf "<li %s><a href=\"%s\">%s</a></li>\n"
         (match top_p, select_p with
         | false, true -> "id=\"subselected\""
         | true, true -> 
             (sel := i;
              Printf.sprintf "id=\"selected\" class=\"nav%d\"" i)
         | _ -> "")
         uri txt) in
  let top, sub = find spec tag [] None in
  add_string buf "<div id=\"nav\"><ul class=\"menu\">\n";
  iter (each true) 0 top;
  add_string buf 
    (Printf.sprintf "</ul><ul class=\"submenu\" id=\"nav%d\">\n" (!sel));
  iter (each false) 0 sub;
  add_string buf "<li></li></ul></div><div id=\"body\">\n";
  contents buf
  
(* tag, uri, text, children *)
let spec = 
  ["/"            ,"Home"    ,[];
   "/browse"      ,"Browse"  ,[];
   "/power17"     ,"Power"   ,[
     "/power17"   ,  "17"      ;
     "/power127"  ,  "127"     ;
     "/power255"  ,  "255"     ;
     "/power511"  ,  "511"     ;
     "/power1023" ,  "1023"    ;
     "/power2047" ,  "2047"    ;
     "/power4095" ,  "4095"    ;
     "/power8191" ,  "8191"    ];
   "/stats"       ,"Stats",   [
     "/uptime"    ,  "Uptime"  ;
     "/gc"        ,  "GC"      ;
     "/log"       ,  "Log"     ];
   "/about"       ,"About",   []
 ]

