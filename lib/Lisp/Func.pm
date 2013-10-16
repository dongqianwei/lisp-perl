package Lisp::Func;
use Lisp::Env;
use Lisp::Eval;
use Data::Dump 'dump';
use parent 'Exporter';
our @EXPORT = qw[get_func];

sub register {
    my $func = shift;
    e_put($func->{name}, $func);
}

sub new {
    my $class = shift;
    my %func = (name => '', env => {}, args => [], states => [], @_);
    bless \%func, $class;
    \%func;
}

sub get_func {
    my $fun = shift;
    return $fun if ref $fun eq 'Lisp::Func';
    e_val($fun);
}

sub f_eval {
    my ($func, @args) = @_;
    my $save_env = e_env();
    my $cur_env = $func->{env};
    e_set_env $cur_env;

    e_push;

    #set env
    for my $sb (@{$func->{args}}) {
        e_put($sb, shift @args);
    }

    my @save_tokens = get_tokens();
    set_tokens(@{$func->{states}});

    my @res = Lisp::Eval::e();

    e_pop;

    set_tokens(@save_tokens);
    e_set_env $save_env;

    @res;
}

1;
