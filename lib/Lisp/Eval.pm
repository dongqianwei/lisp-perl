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

sub l_swallow {
    my $t = shift @tokens;
    #just value
    if ($t ne '(') {
        return;
    }

    my $n = 1;
    while ($n > 0) {
        $t = shift @tokens;
        if ($t eq '(') {
            $n ++;
        }

        if ($t eq ')') {
            $n --;
        }
    }
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
    } : die;
}

sub l_eval {
    return e_val(shift @tokens) if $tokens[0] ne '(';

    l_match '(';
    my $op = shift @tokens;

    #if
    if ($op eq 'if') {
        my $x = l_eval();
        my $r;
        if ($x) {
            $r = l_eval();
            l_swallow();
        }
        else {
            l_swallow();
            $r = l_eval();
        }
        l_match ')';
        return $r;
    }

    #define
    #first param should not be evaled
    if ($op eq 'define') {
        e_put((shift @tokens), l_eval());
        l_match ')';
        return;
    }

    #apply func
    my @args;
    while ($tokens[0] ne ')') {
        push @args, l_eval();
    }
    l_match ')';
    return l_apply $op, @args;
}

sub e {
    while (@tokens) {
        say if local $_ = &l_eval;
    }
}

1;
