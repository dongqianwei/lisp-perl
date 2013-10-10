package Lisp::Func;
use Data::Dump 'dump';

sub new {
    my $class = shift;
    my %func = (name => '', env => {}, params => [], states => [], @_);
    bless \%func, $class;
}

1;
