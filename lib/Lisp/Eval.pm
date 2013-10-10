package Lisp::Eval;
use v5.16;
use Lisp::Env;
use parent 'Exporter';
use Lisp::Func;
use subs qw[l_eval];
$|++;

BEGIN {
    our @EXPORT = qw(e tokenize get_tokens set_tokens);
};

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
    $op =~ 'puts' ? do {
        say "@args";
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
        e_pop();
        return $r;
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
            do{push @args, l_swallow()} until $tokens[0] eq ')';
            my @states;
            l_match ')';
            #get stetements
            while ($tokens[0] ne ')') {
                unshift @states, l_swallow;
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

    #apply func
    my @args;
    while ($tokens[0] ne ')') {
        push @args, l_eval();
    }
    l_match ')';
    e_pop();
    return l_apply $op, @args;
}

sub e {
    my @res;
    while (@tokens) {
        @res = l_eval();
    }
    @res;
}

1;
