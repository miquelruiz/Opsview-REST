package Opsview::REST;

use Moose;
use namespace::autoclean;

use Opsview::REST::Exception;

with 'Opsview::REST::APICaller';

has ['user', 'pass', 'base_url'] => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

sub BUILD {
    my ($self) = @_;
    
    my $r = $self->post('/login', {
        username => $self->user,
        password => $self->pass,
    });

    $self->headers->{'X-Opsview-Username'} = $self->user;
    $self->headers->{'X-Opsview-Token'}    = $r->{token};

}

sub status {
    my $self = shift;

    require Opsview::REST::Status;
    my $uri = Opsview::REST::Status->new(@_);

    return $self->get($uri->as_string);
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

    # These are equivalent
    my $status = $ops->get('/status/hostgroup?hostgroupid=1&...');
    my $status = $ops->status(
        'hostgroup',
        'hostgroupid' => [1, 2],
        'filter'      => 'unhandled',
        ...
    );

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

=head2 get($url)

Makes a "GET" request to the API. The response is properly deserialized and
returned as a Perl data structure.

=head2 status( $endpoint, [ %args ] )

Convenience method to request the "status" part of the API. C<$endpoint> is
the endpoint to send the query to. C<%args> is a hash which will get properly
translated to URL arguments.

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


