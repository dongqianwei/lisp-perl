package Lisp::Func;
use Lisp::Env;
use Lisp::Eval;
use Data::Dump 'dump';
use parent 'Exporter';
our @EXPORT = qw[get_func];

my %f_map;

sub register {
    my $class = shift;
    my %func = (name => '', env => {}, args => [], states => [], @_);
    $f_map{$func{name}} = bless \%func, $class;
}

sub get_func {
    $f_map{+shift};
}

sub f_eval {
    my ($func, @args) = @_;
    my $save_env = e_env();
    my $cur_env = $func->{env};
    e_set_env $cur_env;

    #set env
    for my $sb (@{$func->{args}}) {
        e_put($sb, shift @args);
    }

    my @save_tokens = Lisp::Eval::get_tokens();
    Lisp::Eval::set_tokens(@{$func->{states}});

    my @res = Lisp::Eval::e();

    Lisp::Eval::set_tokens(@save_tokens);
    e_set_env $save_env;

    @res;
}

1;
