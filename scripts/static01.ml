module Static01 = struct
let lift x = .<x>.
let page  = .<fun req puts ->
let arg = Request.arg req in
puts "QkRot/9stySLucxGJImoG8PYR+N+Y3cT5KZ5UAdIR83pwzg5oBDrl9lgxbkeF1Y9jMvi2IEk\niHuqN945qjR0gUnhKmwmArmAx6agwpBBiJKLqSJ4hd+MqqGDH5mj1w7qhRhAWyI7DHOVllPF\nj80Whq878Q6efL0EjrO6wjSYqMqP/UJoSQMgFKa8oMOkn63NjpT8sOz+TDOxu2YzV+jQIITi\nTLJANLfDa+IXmQz/M+ozmPJbuuZaU/+exOEOJ2OUoJ8SRHZQGS3iE/Ko1f+c9PB2YSHFICpg\n7VpBqqXpsQwhvFKocYSSBWxal92xwsCe0+EAzedQzlXQopzhCFfZnkJtNwCVavzJm0JjMO17\n4OJm4Hrkzj1Iene3YgYUaX19zCYc4Xw8ZjDXHXaNA2d2SaAjxcmGeYe5fMno00/xSwUg3DV+\npFGpFRf+DSUPwz9TPH4Y5fIKkNNz/H5VPyaQtUAaD6ZcsKDu7brDc+FUsehSDpFJol9tHjX+\nS1Gbzf0UOmMYJStL4IwaIqDQcawEn0fjUO/QIgLYzQLkoJGddGI0RmftBN95jcAiitXpdH1/\nSCuyyQKH3rzt2uXtdR3UqYbsxq5Z9NT7IgecSRkXlI1rKxk51Fc1B5NTNDAUwGWexXd3UH4j\nf7uhtUGu0cgh9KL+BbHbEQrhjdmL/+zA7N4pionAx1PbEvnD3ZwekUG+3FvuR4dAu36yqPJS\n/EoXp+dchTXwa36x0cEAXJi5gXmaLTtNS2Uy4RMKp55j+FsSsEFNIfuOTRabJOqe7ABxzdxv\nIx9qNaRvgB0IkOp3W9Tx8TD8V1kk0XMlQgKPDkRuFkBigM0qYmRqEKOf/BvENWTSojy4nnp2\nPfMDVaDKZDaKVbFcT6w+uAMZjfA8+3Ek3GzSH6eE6XSxirEpKSliphss1fVK3gUPMku6RFDE\nRlt+VJz5NW9LZKf04v7ZSGMvsysoIon3u66sfBTr8WXqijOq/ZUMaugsOhNOGY6MG+ka1SNU\npT";

>.
let store name = 
  let o = open_out_bin name in
  Marshal.to_channel o (.!page) [Marshal.Closures];
  close_out o
end
