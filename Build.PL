use strict;use warnings;
use Module::Build;

my $builder = Module::Build->new(
    sign              => 1,
    module_name       => 'WebService::Wikimapia',
    license           => 'perl',
    dist_author       => q{Mohammad S Anwar <mohammad.anwar@yahoo.com>},
    dist_version_from => 'lib/WebService/Wikimapia.pm',
    add_to_cleanup    => [ 'WebService-Wikimapia-*' ],    
    build_requires    => {
        'Test::More' => 0,
        'Readonly'    => 0,
        'Mouse'       => '0.93',
        'HTTP::Request'  => '1.40',
        'LWP::UserAgent' => '2.33',
        'MouseX::Params::Validate' => '0.01',
    },
);

$builder->create_build_script();