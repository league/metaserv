type t
val channel : out_channel -> int -> t
val descr : Unix.file_descr -> int -> t
val puts : t -> string -> unit
val flush : t -> unit
val finish : t -> unit
