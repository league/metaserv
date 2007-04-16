let rec power n k =
  if is_zero n then k (Int 1)
  else if is_zero (mod_num n (Int 2)) then
      power (n//(Int 2)) (fun r -> k (square r))
  else 
      power (n -/ (Int 1)) (fun r -> fun x -> k (x */ r) x)
