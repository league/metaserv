.<fun req puts -> let arg = Request.arg req in
    (match (arg "unit") with
     | Some ("M") -> (puts "0.0M")
     | Some ("k") -> (puts "2.4k")
     | _ -> (puts "2458.0"))>.
