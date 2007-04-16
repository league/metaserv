.<fun req puts -> let arg = Request.arg req in
    (match (arg "unit") with
     | Some ("M") -> (puts "0.0M")
     | Some ("k") -> (puts "35.4k")
     | _ -> (puts "36249.0"))>.
