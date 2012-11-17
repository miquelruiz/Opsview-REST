package Opsview::REST::Exception;

use Moo;

# Can't use autoclean since it breaks overload:
# https://github.com/rafl/namespace-autoclean/pull/1
#use namespace::autoclean;

use overload
    '""' => sub {
        join ': ',
            join (' ', $_[0]->status, $_[0]->reason),
            $_[0]->message || '', $_[0]->detail || '';
    },
    fallback => 1;


has [qw/status reason/] => (
    is       => 'ro',
    required => 1,
);

has [qw/message detail/] => (
    is       => 'ro',
    required => 0,
);

__PACKAGE__->meta->make_immutable;

1;

__END__
=pod

=head1 NAME

Opsview::REST::Exception - Structured exceptions for Opsview::REST

=head1 SYNOPSIS

    my $e = Opsview::REST::Exception->new(
        status  => 404,
        reason  => "Not Found",
        message => "The method called doesn't exist",
    );

    croak $e;

    # To inspect the exception from your code
    my $ops = Opsview::REST->new( ... );
    
    eval { $ops->get('/rest_api_method'); };
    if ($@) {
        warn $@->status;
        warn $@->reason;
        warn $@->message;
    }

=head1 DESCRIPTION

This is a convenience object to throw exceptions from within Opsview::REST
modules.

=head1 ATTRIBUTES

=head2 status

=head2 reason

=head2 message

message is not guaranteed to be defined in every exception

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
