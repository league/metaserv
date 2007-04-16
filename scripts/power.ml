module Power = struct
  (* this pages computes x^y, 
        where y is an early argument, and x is late. *)
  open Num
  let zero = eq_num (Int 0)
  let even n = zero (mod_num n (Int 2))
  let square' x = (x */ x)
  let square x = .<let y = .~x in square' y>.
  let rec power' n x = 
    if zero n then .<Int 1>.
    else if even n then square(power' (n//Int 2) x)
    else .<.~x*/ .~(power' (n-/Int 1) x)>.

  let num = string_of_num
  let max = 64
  let rec wrap puts s = 
    if String.length s <= max then puts s
    else (puts (Str.string_before s max);
          puts "\n";
          wrap puts (Str.string_after s max))
 let page  y  = .<fun req puts ->
let arg = Request.arg req in
puts "\n";
let x = match arg "x" with 
          Some x -> num_of_string x
        | None -> Int 2 
  in 
puts "\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"\n    \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n\n<html xmlns=\"http://www.w3.org/1999/xhtml\">\n  <head>\n    <title>";
puts (num x);
puts "^";
puts (num y);
puts "</title>\n    <link href=\"/meta.css\" rel=\"stylesheet\" type=\"text/css\" />\n  </head>\n<body>\n\n<h1>Staged power function: x^";
puts (num y);
puts "</h1>\n<p><form method=\"get\">\nwhere x= <input name=\"x\" type=\"text\" value=\"";
puts (num x);
puts "\" size=\"24\">\n<input type=\"submit\">\n</form></p>\n\n";
let result = .~( power' y .<x>. ) in
puts "<p>\nResult is:\n<pre>\n";
 wrap puts (num result) ;
puts "</p>\n\n<hr/>\nMetaOCaml ";
puts (Sys.ocaml_version);
puts "</body>\n</html>\n";

>.
end
