package Opsview::REST::APICaller;

use Moose::Role;

use Carp;

use JSON::XS ();
use HTTP::Tiny;

has ua => (
    is      => 'ro',
    default => sub { HTTP::Tiny->new(
        agent => 'Opsview::REST/' . (__PACKAGE__->VERSION || '0.001_DEV'),
    ); },
);

has headers => (
    is      => 'rw',
    default => sub { {
        'Accept'        => 'application/json',
        'Content-type'  => 'application/json',
    }; },
);

has json => (
    is      => 'ro',
    default => sub { JSON::XS->new },
);

sub get {
    my $self = shift;
    my $r = $self->ua->get($self->base_url . shift, {
        headers => $self->headers,
    });
    croak $self->_errmsg($r) unless $r->{success};

    return $self->json->decode($r->{content});
}

sub post {
    my ($self, $method, $data) = @_;
    my $r = $self->ua->post(
        $self->base_url . $method,
        {
            headers => $self->headers,
            content => $self->json->encode($data),
        }
    );
    croak $self->_errmsg($r) unless $r->{success};

    return $self->json->decode($r->{content});
}

sub _errmsg {
    my ($self, $r) = @_;
    my $cont; $cont = $self->json->decode($r->{content})
        if $r->{content};

    return Opsview::REST::Exception->new(
        status  => $r->{status},
        reason  => $r->{reason},
        message => $cont ? $cont->{message} : undef,
    );
}

1;
