(define (square x) (* x x))

(define (pow n)
  (cond
    ((zero? n) (lambda (x) (display "z ") 1))
    ((even? n) (lambda (x) (display "even ") `(square ,((pow (/ n 2)) x))))
    (else (lambda (x) (display "odd ") `(* ,x ,((pow (- n 1)) x))))))

(define (make-pow n) (eval `(lambda (x) ,((pow n) 'x)) 
                           (interaction-environment)))

(define p11 (make-pow 11))
(= (p11 2) 2048)

