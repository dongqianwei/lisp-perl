package Lisp::Env;
use subs qw[e_push e_pop e_val e_put];
use parent Exporter;
our @EXPORT = qw[e_val e_put];
my %ENV;

sub e_put {
    $ENV{$_[0]} = $_[1];
}

sub e_val {
    my $sb = shift;
    #value
    return $sb unless $sb =~ /^[a-zA-Z_]/;

    #symbol
    $ENV{$sb} or die "no symbol $sb exists, current symbols: " ,keys %ENV;
}
1;
