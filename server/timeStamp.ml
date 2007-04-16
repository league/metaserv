open Unix

let days = [|"Sun"; "Mon"; "Tue"; "Wed"; "Thu"; "Fri"; "Sat"|]
let months = [|"Jan"; "Feb"; "Mar"; "Apr"; "May"; "Jun";
               "Jul"; "Aug"; "Sep"; "Oct"; "Nov"; "Dec"|]

(* examples:
 * Wed, 15 Nov 1995 04:58:08 GMT
 * Fri, 31 Dec 1999 23:59:59 GMT
 *)
let format' tz tm =
   Printf.sprintf "%s, %02d %s %04d %02d:%02d:%02d %s"
       days.(tm.tm_wday)
       tm.tm_mday
       months.(tm.tm_mon)
       (1900+tm.tm_year)
       tm.tm_hour tm.tm_min tm.tm_sec tz

let format t = format' "GMT" (gmtime t)   

let brief t =
  let tm = localtime t in
  Printf.sprintf "%2d %s %02d:%02d"
    tm.tm_mday
    months.(tm.tm_mon)
    tm.tm_hour tm.tm_min

let now() = format(time())

