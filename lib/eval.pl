use Lisp::Eval;

my $code = <<C;
    (define a 10)
    (define b 20)
    (+ a b)
    (+ (* a b) (- 13 a))
C

tokenize $code;

&e;
