val preamble: string -> string
  (* Generate a standard HTML header, including a title block
     composed from the given string. *)
val navbar: string -> string
  (* Generate the navigation bar, given a URI denoting
     the current page. *)
val postamble: string
  (* The page footer. *)
