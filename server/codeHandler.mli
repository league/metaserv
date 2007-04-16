type page = Request.req -> (string -> unit) -> unit
type map = ((unit -> page) * page ref) StringMap.t

val run : map -> Server.handler
val redirect : map -> Server.handler
val regenerate : map -> Server.handler
