type t
val create : out_channel -> int -> t
val flush : t -> unit
val finish : t -> unit
val puts : t -> string -> unit
val putc : t -> char -> unit
