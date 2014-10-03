#!perl

use strict; use warnings;
use WebService::Wikimapia;
use Test::More tests => 4;

my $wiki = WebService::Wikimapia->new(key => 'aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd');

eval { $wiki->box(); };
like($@, qr/ERROR: Missing boundary box coordinates/);

eval { $wiki->box(bbox => '1,2,3'); };
like($@, qr/The 'bbox' parameter/);

eval { $wiki->box(lon_min=> 1); };
like($@, qr/ERROR: Missing lon_min\/lat_min\/lon_max\/lat_max coordinates/);

eval { $wiki->box(x=> 1); };
like($@, qr/ERROR: Missing x\,y\,z coordinates/);