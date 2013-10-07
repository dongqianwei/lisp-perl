package Lisp::Eval;
use v5.16;
my $code = <<C;
    (- 1 (* 10 5) (+ 3 4))
C

sub tokenize {
    die 'tokenize must be called in array context' unless wantarray;
    my $code = shift;
    $code =~ /\(|\)|[^\s\(\)]+/xg;
}

my @tokens = tokenize $code;

say "@tokens";

sub l_match {
    my $m = shift;
    die "$m not match" unless $tokens[0] eq $m;
    shift @tokens;
}

sub l_apply {
    my ($op, @args) = @_;
    $op =~ /^[\+\-\*]$/ ? do {
        return eval ''.join $op, @args;
    } : die;
}

sub l_eval {
    $tokens[0] ne '(' ? shift @tokens :
    do {
        l_match '(';
        my $op = shift @tokens;
        my @args;
        while ($tokens[0] ne ')') {
            push @args, __SUB__->();
        }
        l_match ')';
        return l_apply $op, @args;
    }
}

say l_eval;
