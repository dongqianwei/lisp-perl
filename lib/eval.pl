use Lisp::Eval;

my $code = <<C;
    (define a (+ 5 5))
    (define b 20)
    (puts (+ a b))
    (puts (+ (* a b) (- 13 a)))
    (puts (if 0 2 (if 0 3 4)))
    (puts (if a 2 3))
    (puts (define a 233) a)
    (puts a)
C

tokenize $code;

&e;

print "execute end";
