use strict;use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'WebService::Wikimapia',
    AUTHOR        => q{Mohammad S Anwar <mohammad.anwar@yahoo.com>},
    VERSION_FROM  => 'lib/WebService/Wikimapia.pm',
    ABSTRACT_FROM => 'lib/WebService/Wikimapia.pm',
    dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean         => { FILES => 'WebService-Wikimapia-*' },
    PREREQ_PM     => {
        'Test::More' => 0,
        'Readonly'   => '1.03',
        'Mouse'      => '0.93',
        'HTTP::Request'  => '1.40',
        'LWP::UserAgent' => '2.33',
        'MouseX::Params::Validate' => '0.01',
    },
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
);