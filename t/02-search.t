#!perl

use strict; use warnings;
use WebService::Wikimapia;
use Test::More tests => 3;

my $wiki = WebService::Wikimapia->new(key => 'aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd');

eval { $wiki->search() };
like($@, qr/Mandatory parameters \'lat\'\, \'q\'\, \'lon\' missing/);

eval { $wiki->search(q => 'Recreation') };
like($@, qr/Mandatory parameters \'lat\'\, \'lon\' missing/);

eval { $wiki->search(q => 'Recreation', lat => 37.7887088) };
like($@, qr/Mandatory parameter \'lon\' missing/);