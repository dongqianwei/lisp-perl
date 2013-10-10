package Lisp::Env;
use subs qw[e_push e_pop e_val e_put];
use parent Exporter;
our @EXPORT = qw[e_val e_put e_push e_pop e_env e_set_env];
my %ENV;

my $cur_env = \%ENV;

sub e_push {
    my $new_env = {};
    $new_env->{_parent} = $cur_env;
    $cur_env = $new_env;
}

sub e_env {
    $cur_env;
}

#set current env
sub e_set_env {
    $cur_env = shift;
}

sub e_pop {
    $cur_env = $cur_env->{_parent};
}

sub e_put {
    $cur_env->{$_[0]} = $_[1];
}

sub e_val {
    my $sb = shift;
    #value
    return $sb unless $sb =~ /^[a-zA-Z_]/;

    #symbol
    my $env = $cur_env;
    until (exists $env->{$sb}) {
        $env = $env->{_parent} or die "search for symbol: $sb ;no more env";
    }
    $env->{$sb};
}
1;
