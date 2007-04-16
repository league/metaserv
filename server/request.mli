type meth =
    OPTIONS
  | GET
  | HEAD
  | POST
  | PUT
  | DELETE
  | TRACE
  | OTHER of string

type req

val read    : in_channel -> req
val dump    : (string -> unit) -> req -> unit

val meth    : req -> meth
val meth'   : req -> string
val query   : req -> string   (* the whole thing: /foo/bar?arg=2 *)
val uri     : req -> string   (* just the path:   /foo/bar       *)
val version : req -> float
val header  : req -> string -> string option  (* look up http header *)
val arg     : req -> string -> string option  (* look up query arg *)

val keep_alive : req -> string (* returns either "close" or "keep-alive" *)
val keep_alive_p : req -> bool   (* true for keep-alive, false otherwise *)
