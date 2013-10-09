package Lisp::Eval;
use Lisp::Env;
use parent Exporter;
use subs qw[l_eval];

use v5.16;

our @EXPORT = qw[e tokenize];

my @tokens;
sub tokenize {
    @tokens = shift =~ /\(|\)|[^\s\(\)]+/xg;
}

sub l_match {
    my $m = shift;
    die "$m not match" unless $tokens[0] eq $m;
    shift @tokens;
}

sub l_apply {
    my ($op, @args) = @_;
    $op =~ /^[\+\-\*\/]$/ ? do {
        return eval ''.join ' '.$op.' ', @args;
    } :
    $op eq 'define' ? do {
        e_put $args[0], $args[1];
        return;
    } : die;
}

sub l_eval {
    $tokens[0] ne '(' ? return e_val(shift @tokens) :
    do {
        l_match '(';
        my $op = shift @tokens;
        my @args;

        #define first param should not be evaled
        if ($op eq 'define') {
            push @args, shift @tokens;
        }

        while ($tokens[0] ne ')') {
            push @args, l_eval();
        }
        l_match ')';
        return l_apply $op, @args;
    };
}

sub e {
    while (@tokens) {
        say if local $_ = &l_eval;
    }
}

1;
