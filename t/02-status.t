
use strict;
use warnings;

use Opsview::REST;

use Test::More;
use Data::Dumper;

my ($url, $user, $pass) = (qw( http://localhost/rest admin initial ));
my $ops = Opsview::REST->new(
    base_url => $url,
    user     => $user,
    pass     => $pass,
);

my $status = $ops->status('hostgroup', hostgroupid => 1);
my $list   = $status->{list};
my %hgids  = map { $_->{hostgroupid} => 1 } @$list;
is_deeply(\%hgids, { 1 => 1 }, 'Got status for hostgroup 1');

$status  = $ops->status('hostgroup', hostgroupid => [1,2]);
my $list = $status->{list};
%hgids   = map { $_->{hostgroupid} => 1 } @$list;
is_deeply(\%hgids, {1 => 1, 2 => 1}, 'Got status for hostgroups 1 and 2');

done_testing();

