let rec power n =
  if is_zero n then fun x -> Int 1
  else if is_zero (mod_num n (Int 2)) 
       then let f = power (n // (Int 2)) in fun x -> square (f x)
       else let g = power (n -/ (Int 1)) in fun x -> x */ (g x)
