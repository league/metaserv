
type t = 
    { fd: Unix.file_descr;
      buf: string;
      size: int;
      mutable pos: int
    }

let descr fd size =
  { fd  = fd;
    buf = String.create size;
    size = size - 2;  (* so there is always room for CR/LF *)
    pos = 0 }

let channel ch size =
  flush ch;
  descr (Unix.descr_of_out_channel ch) size

let write fd s n = 
  let k = Unix.write fd s 0 n in
  if n <> k then failwith "Chunked.write: incomplete"

let write_string fd s = 
  write fd s (String.length s)

let write_chunk_header fd n =
  write_string fd (Printf.sprintf "%x\r\n" n)

let add_crlf s k = 
  String.set s k '\r';
  String.set s (k+1) '\n'

let flush stream =
  let n = stream.pos in 
  if n > 0 then
    (write_chunk_header stream.fd n;
     add_crlf stream.buf n;
     write stream.fd stream.buf (n+2);
     stream.pos <- 0)
          
let puts stream text =
  let n = String.length text in
  if stream.pos + n > stream.size then
    flush stream;
  if n > stream.size then
    (write_chunk_header stream.fd n;
     write_string stream.fd text;
     write_string stream.fd "\r\n")
  else
    (String.blit text 0 stream.buf stream.pos n;
     stream.pos <- stream.pos + n)

let finish stream =
  flush stream;
  write_string stream.fd "0\r\n"

