package Opsview::REST::TestUtils;

use strict;
use warnings;

require Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/get_opsview test_urls/;

use Opsview::REST;

use Test::More;
use Test::Exception;

sub get_opsview {
    my ($url, $user, $pass) = (qw( http://localhost/rest admin initial ));
    return Opsview::REST->new(
        base_url => $ENV{OPSVIEW_REST_URL}  || $url,
        user     => $ENV{OPSVIEW_REST_USER} || $user,
        pass     => $ENV{OPSVIEW_REST_PASS} || $pass,
    );
}

sub test_urls {
    my ($class, @tests) = @_;
    for (@tests) {
        if ($_->{die}) {
            dies_ok { $class->new(@{ $_->{args} }); } $_->{die};
        } else {
            my $status = $class->new(@{ $_->{args} });
            is($status->as_string, $_->{url}, $_->{url});
        }
    };
}

1;

