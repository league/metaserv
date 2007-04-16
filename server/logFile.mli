type log

val create: string -> log
val add: log -> string -> unit
val access: log -> Unix.sockaddr -> Request.req -> Status.t -> unit
val close: log -> unit

