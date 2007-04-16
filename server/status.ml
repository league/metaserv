
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

let code status = match status with
| Continue -> 100
| Ok -> 200
| Moved_permanently -> 301
| Bad_request -> 400
| Forbidden -> 403
| Not_found -> 404
| Request_timeout -> 408
| Server_error -> 500
| Not_implemented -> 501

let text status = match status with
  Continue -> "Continue"
| Ok -> "Ok"
| Moved_permanently -> "Moved Permanently"
| Bad_request -> "Bad Request"
| Forbidden -> "Forbidden"
| Not_found -> "Not Found"
| Request_timeout -> "Request Timeout"
| Server_error -> "Server Error"
| Not_implemented -> "Not Implemented"

