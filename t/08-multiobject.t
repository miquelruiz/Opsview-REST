
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use Opsview::REST::TestUtils;

use Try::Tiny;

use Test::More;
use Test::Exception;

use Data::Dumper;

BEGIN { use_ok 'Opsview::REST::Config'; };

my @tests = (
    {
        args => ['hostgroup'],
        url  => '/config/hostgroup',
    },
    {
        args => ['host'],
        url  => '/config/host',
    },
    {
        args => ['host', json_filter => '{"name":{"-like":"%opsview%"}}'],
        url  => '/config/host?json_filter=%7B%22name%22%3A%7B%22-like%22%3A%22%25opsview%25%22%7D%7D',
    },
);

test_urls('Opsview::REST::Config', @tests);

SKIP: {
    skip 'No $ENV{OPSVIEW_REST_TEST} defined', 7
        if (not defined $ENV{OPSVIEW_REST_TEST});

    my $ops  = get_opsview();

    my $name = 'Application';
    my $res = $ops->get_hosttemplates(name => { '-like' => "$name%" });

    my $summ = $res->{summary};
    ok(defined $summ, "Got a summary back");
    cmp_ok($summ->{rows}, '==', 17, "There are 17 rows");
    my $matches = scalar grep { $_->{name} =~ /$name/ } @{ $res->{list} };
    cmp_ok($matches, '==', 17, 'All retrieved names match');

    my ($name1, $name2) = (get_random_name(), get_random_name());
    $res = $ops->create_contact([
        {
            name     => $name1,
            fullname => $name1,
        },
        {
            name     => $name2,
            fullname => $name2,
        },
    ]);
    ok($res->{objects_updated}, 'Create two contacts in a row');

    throws_ok {
        $ops->create_contacts([
            {
                name     => $name1,
                fullname => $name1,
            },
            {
                name     => $name2,
                fullname => $name2,
            },
        ]);
    } qr/Duplicate entry/, "Can't create them again";

    my ($descr1, $descr2) = (get_random_name(), get_random_name());

    lives_ok {
        $res = $ops->create_or_update_contacts([
            {
                name        => $name1,
                fullname    => $name1,
                description => $descr1,
            },
            {
                name        => $name2,
                fullname    => $name2,
                description => $descr2,
            },
        ]);
    } "create_or_update didn't die";

    $res = $ops->get_contacts(name => { '=', [ $name1, $name2 ]});
    is($res->{summary}->{rows}, 2, 'Got back two contacts in search');

    my $desc     = { $name1 => $descr1, $name2 => $descr2 };
    my %contacts = map { $_->{name} => $_ } @{ $res->{list} };
    for ($name1, $name2) {
        my $c = $contacts{$_};
        is($c->{description}, $desc->{$_}, "Contact $c->{id} correctly updated");
        $res = $ops->delete_contact($c->{id});
        ok($res->{success}, "Contact $c->{id} deleted");
    }
}

done_testing;
