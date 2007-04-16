
type t =
    Continue                            (* 1xx Informational *)
  | Ok                                  (* 2xx Successful *)
  | Moved_permanently                   (* 3xx *)
  | Bad_request                         (* 4xx Client errors *)
  | Forbidden
  | Not_found
  | Request_timeout
  | Server_error                        (* 5xx Server errors *)
  | Not_implemented

val code : t -> int
val text : t -> string
