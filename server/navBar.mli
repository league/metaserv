type spec = (string * string * (string * string) list) list
val gen : spec -> string -> string
