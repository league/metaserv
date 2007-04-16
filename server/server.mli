type server
type handler = Request.req -> out_channel -> Status.t

exception Not_implemented
exception Forbidden

val start: ?port:int -> ?logfile:string -> handler list -> server
val stop: server -> unit
val bufsize: int  (* recommended size for buffering *)
