package Catalyst::Model::CPI;
use Moose;
use Module::Pluggable (
    search_path => [ 'Business::CPI::Gateway' ],
    except      => [
        'Business::CPI::Gateway::Base',
        'Business::CPI::Gateway::Test',
    ],
    sub_name    => 'available_gateways',
    require     => 1,
);
use Moo::Role ();

extends 'Catalyst::Model';

has config_for_gateway => (
    isa     => 'HashRef',
    is      => 'ro',
    default => sub { +{} },
    traits  => ['Hash'],
    handles => {
        get_config_for_gateway => 'get',
    },
);

has _req => ( is => 'rw' );

around BUILDARGS => sub {
    my $orig = shift;
    my $self = shift;

    my $args = $self->$orig(@_);

    $args->{config_for_gateway} = delete $args->{gateway};

    return $args;
};

before COMPONENT => sub {
    my ($self, $ctx) = @_;

    for ($self->available_gateways) {
        if ($_->isa('Business::CPI::Gateway::Base') && $_->can('notify')) {
            Moo::Role->apply_roles_to_package(
                $_, 'Business::CPI::Role::Request'
            );
        }
    }
};

sub ACCEPT_CONTEXT {
    my ($self, $ctx) = @_;

    $self->_req($ctx->req);

    return $self;
}

sub get {
    my ($self, $name) = @_;

    if (!$self->exists($name)) {
        local $" = ", ";
        my @plugins = $self->available_gateways;
        die "Can't get gateway $name. Available gateways are @plugins";
    }

    my $fullname = "Business::CPI::Gateway::$name";

    my %args = %{ $self->get_config_for_gateway($name) };
    $args{req} = $self->_req;

    return $fullname->new(%args);
}

sub exists {
    my ($self, $name) = @_;

    my $fullname = "Business::CPI::Gateway::$name";

    for ($self->available_gateways) {
        return 1 if $_ eq $fullname;
    }

    return 0;
}

package # hide from PAUSE
    Business::CPI::Role::Request;
use Moo::Role;

has req => ( is => 'ro' );

around notify => sub {
    my $orig = shift;
    my $self = shift;

    if (scalar @_) {
        die "You are using Business::CPI from Catalyst.\n" .
            "You don't have to pass the request!\n";
    }

    return $self->$orig($self->req);
};

1;

__END__
