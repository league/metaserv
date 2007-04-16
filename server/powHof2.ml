open Num (* for arbitrary-precision arithmetic *)
  let width = 54
  let rec wrap puts s =  (* wrap `s' into a fixed-width block *)
    if String.length s <= width then puts s else
      (puts (Str.string_before s width); puts "\n";
       wrap puts (Str.string_after s width))
  let is_zero = eq_num (Int 0)
  let square x = (let z = x in z */ z)

  let rec power n x =  (* staged power function *)
    if is_zero n then (Int 1) else
    if is_zero (mod_num n (Int 2)) then square(power (n//Int 2) x)
    else ( x */ (power (n -/ Int 1) x)) 

let one = Int 1
let two = Int 2

(* here is one without continuations, as suggested by reviewer *)
let rec power n =
 (Printf.printf "hof power B %s\n" (string_of_num n);
  if is_zero n then fun x -> Int 1
  else if is_zero (mod_num n two) then
      let pow_ndiv2 = power (n//two) in
      fun x -> square (pow_ndiv2 x)
  else 
      let pow_nsub1 = power (n -/ one) in
      fun x -> x */ (pow_nsub1 x))

let page  y  = 
  let pre_gen = power y in
(fun req puts ->
let arg = Request.arg req in
let y' = (( string_of_num y )) in
let x' = match (arg "x") with Some v -> v | None -> "2"  in 
puts (Navspec.preamble(x'^"^"^y')   (* Output begins here *) );
puts (Navspec.navbar("/power"^string_of_num y));
puts "<form method='get'> This page computes \n  <input name='x' type='text' value='";
puts (x');
puts "' size='20'/>\n  <sup>";
puts (y');
puts "</sup> </form>\n";
let result = ( pre_gen (num_of_string x') ) in
puts "<p>The result is: \n<pre>";
wrap puts (string_of_num result) ;
puts "</pre></p>\n";
puts Navspec.postamble;
)
