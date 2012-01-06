package Opsview::REST;

use Moose;
use namespace::autoclean;

use URI;
use Carp;
use JSON::XS ();
use HTTP::Tiny;

has ['user', 'pass', 'base_url'] => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);


# Private stuff
has [ qw/ua headers/ ] => (
    is => 'rw',
);

has 'json' => (
    is      => 'ro',
    default => sub { JSON::XS->new },
);

sub BUILD {
    my ($self) = @_;
    
    $self->ua(HTTP::Tiny->new(
        agent => 'Opsview::REST/' . Opsview::REST->VERSION,
    ));

    $self->headers({
        'Accept'        => 'application/json',
        'Content-type'  => 'application/json',
    });

    my $r = $self->post('/login', {
        username => $self->user,
        password => $self->pass,
    });

    $self->headers->{'X-Opsview-Username'} = $self->user;
    $self->headers->{'X-Opsview-Token'}    = $r->{token};

}

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
    my $msg = "$r->{status} $r->{reason}";
    if ($r->{content}) {
        $msg .= ': ' . $self->json->decode($r->{content})->{message};
    };
}

__PACKAGE__->meta->make_immutable;

1;
__END__

=pod

=head1 NAME
    
Opsview::REST - Interface to the Opsview REST API

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use Opsview::REST;

    my $ops = Opsview::REST->new(
        base_url => 'http://opsview.example.com/rest',
        user     => 'username',
        pass     => 'password',
    );

    my $resp = $ops->get('/event');

=head1 DESCRIPTION

Opsview::REST is a set of modules to access the Opsview REST API, which is the
recommended method for scripting configuration changes or any other form of
integration.

=head1 METHODS

=head2 new

Return an instance of the Opsview::REST.

=head3 Required Arguments

=over 4

=item base_url

Base url where the REST API resides. By default it is under C</rest>.

=item user

=item pass

Username and password needed to login.

=back

=head2 get

Makes a "GET" request to the API. The response is properly deserialized and
returned as a Perl data structure.

=head1 SEE ALSO

=over 4

=item *

L<http://www.opsview.org/>

=item *

L<Opsview REST API Documentation|http://docs.opsview.com/doku.php?id=opsview-community:restapi>

=back

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


