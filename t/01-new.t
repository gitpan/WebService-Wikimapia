#!perl

use strict; use warnings;
use WebService::Wikimapia;
use Test::More tests => 10;

eval { WebService::Wikimapia->new(); };
like($@, qr/Attribute \(key\) is required/);

eval { WebService::Wikimapia->new(key => 'aabbccd-aabbccdd'); };
like($@, qr/Attribute \(key\) does not pass the type constraint/);

eval 
{ 
    WebService::Wikimapia->new(
        key    => 'aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd',
        format => 'jsson',
    ); 
};
like($@, qr/Attribute \(format\) does not pass the type constraint/);

eval 
{ 
    WebService::Wikimapia->new(
        key  => 'aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd',
        page => 'a',
    ); 
};
like($@, qr/Attribute \(page\) does not pass the type constraint/);

eval 
{ 
    WebService::Wikimapia->new(
        key   => 'aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd',
        count => 'a',
    ); 
};
like($@, qr/Attribute \(count\) does not pass the type constraint/);

eval 
{ 
    WebService::Wikimapia->new(
        key  => 'aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd',
        page => -1,
    ); 
};
like($@, qr/Attribute \(page\) does not pass the type constraint/);

eval 
{ 
    WebService::Wikimapia->new(
        key   => 'aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd',
        count => -1,
    ); 
};
like($@, qr/Attribute \(count\) does not pass the type constraint/);

eval 
{ 
    WebService::Wikimapia->new(
        key      => 'aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd',
        language => 'enn',
    ); 
};
like($@, qr/Attribute \(language\) does not pass the type constraint/);

eval 
{ 
    WebService::Wikimapia->new(
        key  => 'aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd',
        pack => 'noone',
    ); 
};
like($@, qr/Attribute \(pack\) does not pass the type constraint/);

eval 
{ 
    WebService::Wikimapia->new(
        key     => 'aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd-aabbccdd',
        disable => 'pollygon',
    ); 
};
like($@, qr/Attribute \(disable\) does not pass the type constraint/);