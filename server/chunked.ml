
type t = { chan: out_channel;
           buf: Buffer.t;
           size: int }

let create chan size =
  { chan = chan;
    buf = Buffer.create size;
    size = size }

let flush out = 
  match Buffer.length out.buf with
    0 -> ()
  | k ->
      Printf.fprintf out.chan "%x\r\n" k;
      Buffer.output_buffer out.chan out.buf;
      output_string out.chan "\r\n";
      Buffer.clear out.buf

let puts out str =
  Buffer.add_string out.buf str;
  if Buffer.length out.buf >= out.size 
  then flush out

let putc out char = 
  Buffer.add_char out.buf char;
  if Buffer.length out.buf >= out.size
  then flush out

let finish out =
  flush out;
  output_string out.chan "0\r\n"
