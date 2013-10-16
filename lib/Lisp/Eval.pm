package Lisp::Eval;
use v5.16;
use Lisp::Env;
use parent 'Exporter';
use subs qw[l_eval];
$|++;

BEGIN {
    our @EXPORT = qw(e execute tokenize get_tokens set_tokens);
};

use Lisp::Func;
my @tokens;
sub tokenize {
    @tokens = shift =~ /\(|\)|[^\s\(\)]+/xg;
}

sub set_tokens {
    @tokens = @_;
}

sub get_tokens {
    @tokens;
}

sub l_swallow {
    my $t = shift @tokens;
    #just value
    if ($t ne '(') {
        return $t;
    }

    my @res = '(';
    my $n = 1;
    while ($n > 0) {
        $t = shift @tokens;
        if ($t eq '(') {
            $n ++;
        }

        if ($t eq ')') {
            $n --;
        }

        push @res, $t;
    }
    return @res;
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
    $op =~ /^[<=>]$/ ? do {
        return eval $args[0]. ' '.($op eq '=' ? '==' : $op).' '. $args[1];
    } :
    $op eq 'puts' ? do {
        say "@args";
    } :
    $op eq 'list' ? do {
        [@args];
    } :
    $op eq 'car' ? do {
        $args[0]->[0];
    } :
    $op eq 'cdr' ? do {
        [@{$args[0]}[1 .. ($#{$args[0]})]];
    } :
    $op eq 'cons' ? do {
        [$args[0], @{$args[1]}];
    } :
    $op eq 'null?' ? do {
        @{$args[0]} == 0;
    } :
    get_func($op) ? do {
        my $func = get_func($op);
        return $func->f_eval(@args);
    } : die "operator not exist: $op";
}

sub l_eval {
    return e_val(shift @tokens) if $tokens[0] ne '(';

    l_match '(';
    e_push();

    # $op is a symbol
    # it could be function name or syntax symbol
    my $op;
    if ($tokens[0] ne '(') {
        $op = shift @tokens;
    }
    #$op will be evaled
    else {
        $op = l_eval;
    }

    #********************syntax symbol********************#

    #if
    if ($op eq 'if') {
        my $x = l_eval();
        my @r;
        if ($x) {
            @r = l_eval();
            l_swallow();
        }
        else {
            l_swallow();
            @r = l_eval();
        }
        l_match ')';
        e_pop();
        return @r;
    }

    #define
    #first param should not be evaled
    if ($op eq 'define') {
        e_pop();

        if ($tokens[0] ne '(') {
            e_put((shift @tokens), l_eval());
        }
        #match function defination
        else {
            l_match '(';
            #get function name
            my $funame = shift @tokens;
            #get args
            my @args;
            while ($tokens[0] ne ')'){push @args, l_swallow()};
            my @states;
            l_match ')';
            #get stetements
            while ($tokens[0] ne ')') {
                push @states, l_swallow;
            }
            Lisp::Func->register(
                                name => $funame,
                                env => e_env(),
                                args => \@args,
                                states => \@states,
                                );
        }

        l_match ')';
        return;
    }

    #********************function name symbol********************#
    #apply func
    my @args;
    while ($tokens[0] ne ')') {
        push @args, l_eval();
    }
    l_match ')';
    e_pop();
    return l_apply $op, @args;
}

#inner execute
sub e {
    my @res;
    while (@tokens) {
        @res = l_eval();
    }
    @res;
}

sub execute {
    my $code = shift;
    @tokens = tokenize $code;
    my @res = e;
    wantarray ? @res : $res[0];
}

1;
