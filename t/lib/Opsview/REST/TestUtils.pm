package Opsview::REST::TestUtils;

use strict;
use warnings;

require Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/get_opsview/;

sub get_opsview {
    my ($url, $user, $pass) = (qw( http://localhost/rest admin initial ));
    return Opsview::REST->new(
        base_url => $ENV{OPSVIEW_REST_URL}  || $url,
        user     => $ENV{OPSVIEW_REST_USER} || $user,
        pass     => $ENV{OPSVIEW_REST_PASS} || $pass,
    );
}

1;

