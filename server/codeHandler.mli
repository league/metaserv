type code = Request.req -> (string -> unit) -> unit
val run : code StringMap.t -> Server.handler
val redirect : code StringMap.t -> Server.handler
