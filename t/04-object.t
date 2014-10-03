#!perl

use strict; use warnings;
use WebService::Wikimapia;
use Test::More tests => 1;

my $wiki = WebService::Wikimapia->new(key => 'aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd');

eval { $wiki->object(); };
like($@, qr/ERROR: Missing object id/);