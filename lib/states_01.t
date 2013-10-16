use v5.16;
use Test::More;
use Lisp::Eval;
=head
    test helper function
=cut
my $code;
sub ts {
    execute $code;
}


$code = <<'.';
123
.

is(ts, 123, 'value');

$code = <<'.';
(+ 1 2)
.

is(ts, 3, 'add');

$code = <<'.';
(+ 1 2)
.

is(ts, 3, 'minus');

$code = <<'.';
(- 1 2)
.

is(ts, -1, 'add');

$code = <<'.';
(* 3 2)
.

is(ts, 6, 'times');

$code = <<'.';
(/ 12 6)
.

is(ts, 2, 'devide');

$code = <<'.';
(define a 10)
(define b 20)
(- b a)
.


is(ts, 10, 'variable defination');

$code = <<'.';
(define (add x y)(+ x y))
(add 12 13)
.

is(ts, 25, 'function defination');

$code = <<'.';
(define a 10)
(define (f) (define a 20) a)
(f)
.

is(ts, 20, 'scope');

$code = <<'.';
(define l (list 1 2 3 4 5))
(car l)
.

is(ts, 1, 'list defination');

$code = <<'.';
(define l (list 1 2 3 4 5))
(car (cdr l))
.

is(ts, 2, 'list function');

done_testing();
