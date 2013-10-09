use Lisp::Eval;

my $code = <<C;
    (define a (+ 5 5))
    (define b 20)
    (+ a b)
    (+ (* a b) (- 13 a))
    (if 0 2 (if 0 3 4))
    (if 1 2 3)
C

tokenize $code;

&e;

print "execute end";
