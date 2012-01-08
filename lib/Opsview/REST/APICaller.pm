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
__END__

=pod

=head1 NAME

Opsview::REST::APICaller - Role to call the Opsview API

=head1 SYNOPSIS

    use Moose;
    with 'Opsview::REST::APICaller';

    $self->get($url);
    $self->post($url, $data);

=head1 DESCRIPTION

This role implements the actual HTTP calls. It uses L<HTTP::Tiny> to do so.
Only C<get> and C<post> implemented at the moment.

=head1 AUTHOR

=over 4

=item *

Miquel Ruiz <mruiz@cpan.org>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Miquel Ruiz.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
