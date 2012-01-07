package Opsview::REST::Status;

use Moose;
use namespace::autoclean;

use URI;

has uri => (
    is      => 'ro',
    default => sub { URI->new; },
    handles => [qw/ as_string /],
);

has path => (
    is  => 'ro',
    isa => 'Str',
);

has args => (
    is  => 'ro',
    isa => 'HashRef',
);

sub BUILDARGS {
    my ($class, $path, @args) = @_;
    return {
        path => $path,
        args => { @args },
    };
}

sub BUILD {
    my $self = shift;

    $self->uri->path('/status/' . $self->path);
    $self->uri->query_form($self->args);
}

__PACKAGE__->meta->make_immutable;

1;
