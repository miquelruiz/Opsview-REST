
use strict;
use warnings;

use Test::More tests => 5;
use Test::Exception;

BEGIN { use_ok 'Opsview::REST'; };

dies_ok { Opsview::REST->new() } "Die if no arguments passed";

my ($url, $user, $pass) = (qw( http://localhost/rest admin initial ));

SKIP: {
    skip 'No $ENV{OPSVIEW_REST_TEST} defined', 3
        if (not defined $ENV{OPSVIEW_REST_TEST});

    throws_ok { Opsview::REST->new(
        base_url => $ENV{OPSVIEW_REST_URL}  || $url,
        user     => 'incorrect_user',
        pass     => 'incorrect_pass',
    ); } qr/401 Unauthorized/, "Incorrect credentials";

    my $ops = Opsview::REST->new(
        base_url => $ENV{OPSVIEW_REST_URL}  || $url,
        user     => $ENV{OPSVIEW_REST_USER} || $user,
        pass     => $ENV{OPSVIEW_REST_PASS} || $pass,
    );

    isa_ok($ops, 'Opsview::REST', "Object created");
    ok(defined $ops->headers->{'X-Opsview-Token'}, "Logged in");
};

