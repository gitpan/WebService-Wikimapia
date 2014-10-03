package WebService::Wikimapia;

use Mouse;
use MouseX::Params::Validate;
use Mouse::Util::TypeConstraints;

use Carp;
use Readonly;
use Data::Dumper;

use HTTP::Request;
use LWP::UserAgent;

=head1 NAME

WebService::Wikimapia - Interface to Wikimapia API.

=head1 VERSION

Version 0.04

=cut

our $VERSION = '0.04';
Readonly my $BASE_URL => 'http://api.wikimapia.org/';
Readonly my $DISABLE  => { 'location' => 1, 'polygon' => 1 };
Readonly my $FORMAT   => { 'xml'  => 1, 'json' => 1, jsonp => 1, 'kml'=> 1, 'binary' => 1 };
Readonly my $PACK     => { 'none' => 1, 'gzip' => 1 };
Readonly my $LANGUAGE =>
{
    'ab' => 1,  'aa' => 1,    'af' => 1,   'ak' => 1,    'sq' => 1,    'am' => 1,
    'ar' => 1,  'an' => 1,    'hy' => 1,   'as' => 1,    'av' => 1,    'ae' => 1,
    'ay' => 1,  'az' => 1,    'bm' => 1,   'ba' => 1,    'eu' => 1,    'be' => 1,
    'bn' => 1,  'bh' => 1,    'bi' => 1,   'bs' => 1,    'br' => 1,    'bg' => 1,
    'my' => 1,  'ca' => 1,    'ch' => 1,   'ce' => 1,    'ny' => 1,    'zh' => 1,
    'cv' => 1,  'kw' => 1,    'co' => 1,   'cr' => 1,    'hr' => 1,    'cs' => 1,
    'da' => 1,  'dv' => 1,    'nl' => 1,   'dz' => 1,    'en' => 1,    'eo' => 1,
    'et' => 1,  'ee' => 1,    'fo' => 1,   'fj' => 1,    'fi' => 1,    'fr' => 1,
    'ff' => 1,  'gl' => 1,    'ka' => 1,   'de' => 1,    'el' => 1,    'gn' => 1,
    'gu' => 1,  'ht' => 1,    'ha' => 1,   'he' => 1,    'hz' => 1,    'hi' => 1,
    'ho' => 1,  'hu' => 1,    'ia' => 1,   'id' => 1,    'ie' => 1,    'ga' => 1,
    'ig' => 1,  'ik' => 1,    'io' => 1,   'is' => 1,    'it' => 1,    'iu' => 1,
    'ja' => 1,  'jv' => 1,    'kl' => 1,   'kn' => 1,    'kr' => 1,    'ks' => 1,
    'kk' => 1,  'km' => 1,    'ki' => 1,   'rw' => 1,    'ky' => 1,    'kv' => 1,
    'kg' => 1,  'ko' => 1,    'ku' => 1,   'kj' => 1,    'la' => 1,    'lb' => 1,
    'lg' => 1,  'li' => 1,    'ln' => 1,   'lo' => 1,    'lt' => 1,    'lu' => 1,
    'lv' => 1,  'gv' => 1,    'mk' => 1,   'mg' => 1,    'ms' => 1,    'ml' => 1,
    'mt' => 1,  'mi' => 1,    'mr' => 1,   'mh' => 1,    'mn' => 1,    'na' => 1,
    'nv' => 1,  'nb' => 1,    'nd' => 1,   'ne' => 1,    'ng' => 1,    'nn' => 1,
    'no' => 1,  'ii' => 1,    'nr' => 1,   'oc' => 1,    'oj' => 1,    'cu' => 1,
    'om' => 1,  'or' => 1,    'os' => 1,   'pa' => 1,    'pi' => 1,    'fa' => 1,
    'pl' => 1,  'ps' => 1,    'pt' => 1,   'qu' => 1,    'rm' => 1,    'rn' => 1,
    'ro' => 1,  'ru' => 1,    'sa' => 1,   'sc' => 1,    'sd' => 1,    'se' => 1,
    'sm' => 1,  'sg' => 1,    'sr' => 1,   'gd' => 1,    'sn' => 1,    'si' => 1,
    'sk' => 1,  'sl' => 1,    'af' => 1,   'st' => 1,    'es' => 1,    'su' => 1,
    'sw' => 1,  'ss' => 1,    'sv' => 1,   'ta' => 1,    'te' => 1,    'tg' => 1,
    'th' => 1,  'ti' => 1,    'bo' => 1,   'tk' => 1,    'tl' => 1,    'tn' => 1,
    'to' => 1,  'tr' => 1,    'ts' => 1,   'tt' => 1,    'tw' => 1,    'ty' => 1,
    'ug' => 1,  'uk' => 1,    'ur' => 1,   'uz' => 1,    've' => 1,    'vi' => 1,
    'vo' => 1,  'wa' => 1,    'cy' => 1,   'wo' => 1,    'fy' => 1,    'xh' => 1,
    'yi' => 1,  'yo' => 1,    'za' => 1,   'zu' => 1,
};

=head1 DESCRIPTION

Wikimapia API is a system that allows you to receive data from Wikimapia map & that can easily
be integrate Wikimapia Geo Data into your external application/web site. And it's all free.You
need to get the API Key first from here: http://wikimapia.org/api?action=create_key
Please note API is still in developing stage (beta).

=head1 CONSTRUCTOR

The only key required is 'key' which is an api key. Rest of them are optional.

    +----------+-----------------------------------------------------------------------------+
    | Key      | Description                                                                 |
    +----------+-----------------------------------------------------------------------------+
    | key      | Wikimapia API Key.                                                          |
    | disable  | Option to disable the output of various parameters. You can disable fields  |
    |          | for xml, json(p) formats. Allowed fields to disable: location, polygon.     |
    | page     | This is page number. 1 is default.                                          |
    | count    | Determines the number of results/page. 50 is default.                       |
    | language | Language in ISO 639-1 format. Default is 'en'.                              |
    | format   | Output format. Choices: xml(default),kml,json,jsonp and binary.             |
    | pack     | Pack output data in zipped format. Available values: none (default), gzip.  |
    +----------+-----------------------------------------------------------------------------+

    use strict; use warnings;
    use WebService::Wikimapia;

    my ($key, $wiki);
    $key  = 'Your_API_Key';
    $wiki = WebService::Wikimapia->new(key => $key);

    #or
    $wiki = WebService::Wikimapia->new(key => $key, format => 'json');

    #or
    $wiki = WebService::Wikimapia->new(key => $key, count => 20);

=head1 LANGUAGE

    +-----------------------+----------------+
    | Language Name         | ISO 639-1 Code |
    +-----------------------+----------------+
    | Abkhaz                |       ab       |
    | Afar                  |       aa       |
    | Afrikaans             |       af       |
    | Akan                  |       ak       |
    | Albanian              |       sq       |
    | Amharic               |       am       |
    | Arabic                |       ar       |
    | Aragonese             |       an       |
    | Armenian              |       hy       |
    | Assamese              |       as       |
    | Avaric                |       av       |
    | Avestan               |       ae       |
    | Aymara                |       ay       |
    | Azerbaijani           |       az       |
    | Bambara               |       bm       |
    | Bashkir               |       ba       |
    | Basque                |       eu       |
    | Belarusian            |       be       |
    | Bengali               |       bn       |
    | Bihari                |       bh       |
    | Bislama               |       bi       |
    | Bosnian               |       bs       |
    | Breton                |       br       |
    | Bulgarian             |       bg       |
    | Burmese               |       my       |
    | Catalan               |       ca       |
    | Chamorro              |       ch       |
    | Chechen               |       ce       |
    | Chichewa              |       ny       |
    | Chinese               |       zh       |
    | Chuvash               |       cv       |
    | Cornish               |       kw       |
    | Corsican              |       co       |
    | Cree                  |       cr       |
    | Croatian              |       hr       |
    | Czech                 |       cs       |
    | Danish                |       da       |
    | Divehi                |       dv       |
    | Dutch                 |       nl       |
    | Dzongkha              |       dz       |
    | English               |       en       |
    | Esperanto             |       eo       |
    | Estonian              |       et       |
    | Ewe                   |       ee       |
    | Faroese               |       fo       |
    | Fijian                |       fj       |
    | Finnish               |       fi       |
    | French                |       fr       |
    | Fula                  |       ff       |
    | Galician              |       gl       |
    | Georgian              |       ka       |
    | German                |       de       |
    | Greek, Modern         |       el       |
    | Guarani               |       gn       |
    | Gujarati              |       gu       |
    | Haitian               |       ht       |
    | Hausa                 |       ha       |
    | Hebrew (modern)       |       he       |
    | Herero                |       hz       |
    | Hindi                 |       hi       |
    | Hiri Motu             |       ho       |
    | Hungarian             |       hu       |
    | Interlingua           |       ia       |
    | Indonesian            |       id       |
    | Interlingue           |       ie       |
    | Irish                 |       ga       |
    | Igbo                  |       ig       |
    | Inupiaq               |       ik       |
    | Ido                   |       io       |
    | Icelandic             |       is       |
    | Italian               |       it       |
    | Inuktitut             |       iu       |
    | Japanese              |       ja       |
    | Javanese              |       jv       |
    | Kalaallisut           |       kl       |
    | Kannada               |       kn       |
    | Kanuri                |       kr       |
    | Kashmiri              |       ks       |
    | Kazaq                 |       kk       |
    | Khmer                 |       km       |
    | Kikuyu                |       ki       |
    | Kinyarwanda           |       rw       |
    | Kirghiz               |       ky       |
    | Komi                  |       kv       |
    | Kongo                 |       kg       |
    | Korean                |       ko       |
    | Kurdish               |       ku       |
    | Kwanyama              |       kj       |
    | Latin                 |       la       |
    | Luxembourgish         |       lb       |
    | Luganda               |       lg       |
    | Limburgish            |       li       |
    | Lingala               |       ln       |
    | Lao                   |       lo       |
    | Lithuanian            |       lt       |
    | Luba-Katanga          |       lu       |
    | Latvian               |       lv       |
    | Manx                  |       gv       |
    | Macedonian            |       mk       |
    | Malagasy              |       mg       |
    | Malay                 |       ms       |
    | Malayalam             |       ml       |
    | Maltese               |       mt       |
    | Ma-ori                |       mi       |
    | Marathi               |       mr       |
    | Marshallese           |       mh       |
    | Mongolian             |       mn       |
    | Nauru                 |       na       |
    | Navajo                |       nv       |
    | Norwegian             |       nb       |
    | North Ndebele         |       nd       |
    | Nepali                |       ne       |
    | Ndonga                |       ng       |
    | Norwegian Nynorsk     |       nn       |
    | Norwegian             |       no       |
    | Nuosu                 |       ii       |
    | South Ndebele         |       nr       |
    | Occitan               |       oc       |
    | Ojibwe                |       oj       |
    | Old Church Slavonic   |       cu       |
    | Oromo                 |       om       |
    | Oriya                 |       or       |
    | Ossetian              |       os       |
    | Punjabi               |       pa       |
    | Pa-li                 |       pi       |
    | Persian               |       fa       |
    | Polish                |       pl       |
    | Pashto                |       ps       |
    | Portuguese            |       pt       |
    | Quechua               |       qu       |
    | Romansh               |       rm       |
    | Kirundi               |       rn       |
    | Romanian              |       ro       |
    | Russian               |       ru       |
    | Sanskrit              |       sa       |
    | Sardinian             |       sc       |
    | Sindhi                |       sd       |
    | Northern Sami         |       se       |
    | Samoan                |       sm       |
    | Sango                 |       sg       |
    | Serbian               |       sr       |
    | Scottish Gaelic;      |       gd       |
    | Shona                 |       sn       |
    | Sinhala               |       si       |
    | Slovak                |       sk       |
    | Slovene               |       sl       |
    | Somali                |       af       |
    | Southern Sotho        |       st       |
    | Spanish               |       es       |
    | Sundanese             |       su       |
    | Swahili               |       sw       |
    | Swati                 |       ss       |
    | Swedish               |       sv       |
    | Tamil                 |       ta       |
    | Telugu                |       te       |
    | Tajik                 |       tg       |
    | Thai                  |       th       |
    | Tigrinya              |       ti       |
    | Tibetan Standard      |       bo       |
    | Turkmen               |       tk       |
    | Tagalog               |       tl       |
    | Tswana                |       tn       |
    | Tonga (Tonga Islands) |       to       |
    | Turkish               |       tr       |
    | Tsonga                |       ts       |
    | Tatar                 |       tt       |
    | Twi                   |       tw       |
    | Tahitian              |       ty       |
    | Uighur                |       ug       |
    | Ukrainian             |       uk       |
    | Urdu                  |       ur       |
    | Uzbek                 |       uz       |
    | Venda                 |       ve       |
    | Vietnamese            |       vi       |
    | Volapuk               |       vo       |
    | Walloon               |       wa       |
    | Welsh                 |       cy       |
    | Wolof                 |       wo       |
    | Western Frisian       |       fy       |
    | Xhosa                 |       xh       |
    | Yiddish               |       yi       |
    | Yoruba                |       yo       |
    | Zhuang                |       za       |
    | Zulu                  |       zu       |
    +-----------------------+----------------+

=cut

type 'BBox'       => where { _validateBBox($_) };
type 'Coordinate' => where { /^\-?\d*\.?\d*?$/ };
type 'Page'       => where { /^\d+$/ };
type 'Count'      => where { /^\d+$/ };
type 'Key'        => where { /^[A-Z0-9]{8}\-[A-Z0-9]{8}\-[A-Z0-9]{8}\-[A-Z0-9]{8}\-[A-Z0-9]{8}\-[A-Z0-9]{8}\-[A-Z0-9]{8}\-[A-Z0-9]{8}$/i };
type 'Language'   => where { exists($LANGUAGE->{lc($_)}) };
type 'Disable'    => where { exists($DISABLE->{lc($_)})  };
type 'Format'     => where { exists($FORMAT->{lc($_)})   };
type 'Pack'       => where { exists($PACK->{lc($_)})     };

# Not clearly defined.
# has  'options'  => (is => 'ro', isa => 'Options');
# has  'category' => (is => 'ro', isa => 'Category');

has  'disable'  => (is => 'ro', isa => 'Disable');
has  'language' => (is => 'ro', isa => 'Language', default => 'en');
has  'page'     => (is => 'ro', isa => 'Page',     default => 1);
has  'count'    => (is => 'ro', isa => 'Count',    default => 50);
has  'format'   => (is => 'ro', isa => 'Format',   default => 'xml');
has  'pack'     => (is => 'ro', isa => 'Pack',     default => 'none');
has  'key'      => (is => 'ro', isa => 'Key',      required => 1);
has  'browser'  => (is => 'rw', isa => 'LWP::UserAgent', default => sub { return LWP::UserAgent->new(agent => 'Mozilla/5.0'); });

=head1 METHODS

=head2 search()

Returns search results of a given query.

    +---------+---------------------------------------------------------------------+
    | Key     | Description                                                         |
    +---------+---------------------------------------------------------------------+
    | q       | Query to search in wikimapia (UTF-8).                               |
    | lat     | Coordinates of the "search point" lat means latitude.               |
    | lon     | Coordinates of the "search point" lon means longitude.              |
    +---------+---------------------------------------------------------------------+

    use strict; use warnings;
    use WebService::Wikimapia;

    my $key  = 'Your_API_Key';
    my $wiki = WebService::Wikimapia->new(key => $key);
    print $wiki->search(q => 'Recreation', lat => 37.7887088, lon => -122.4997044);

=cut

sub search
{
    my $self  = shift;
    my %param = validated_hash(\@_,
                'q'    => { isa => 'Str'        },
                'lat'  => { isa => 'Coordinate' },
                'lon'  => { isa => 'Coordinate' },
                MX_PARAMS_VALIDATE_NO_CACHE => 1);

    my $url = sprintf("%s?function=search&q=%s&lat=%s&lon=%s",
        $BASE_URL, $param{q}, $param{lat}, $param{lon});
    $url.= sprintf("&key=%s", $self->key);
    $url = $self->_addOptionalParams($url);
    return $self->_process($url);
}

=head2 box()

Returns object in the given boundary box.

    +---------+---------------------------------------------------------------------+
    | Key     | Description                                                         |
    +---------+---------------------------------------------------------------------+
    | bbox    | Coordinates of the selected box [lon_min,lat_min,lon_max,lat_max].  |
    +---------+---------------------------------------------------------------------+

    OR

    +---------+---------------------------------------------------------------------+
    | Key     | Description                                                         |
    +---------+---------------------------------------------------------------------+
    | lon_min | Longiture Min.                                                      |
    | lat_min | Latitude Min.                                                       |
    | lon_max | Longitude Max.                                                      |
    | lat_max | Latitude Max.                                                       |
    +---------+---------------------------------------------------------------------+

    OR

    +---------+---------------------------------------------------------------------+
    | Key     | Description                                                         |
    +---------+---------------------------------------------------------------------+
    | x       | Tile's x co-ordinate.                                               |
    | y       | Tile's y co-ordinate.                                               |
    | z       | Tile's z co-ordinate.                                               |
    +---------+---------------------------------------------------------------------+

    use strict; use warnings;
    use WebService::Wikimapia;

    my $key  = 'Your_API_Key';
    my $wiki = WebService::Wikimapia->new(key => $key);

    print $wiki->box(bbox => '37.617188,55.677586,37.70507,55.7271128');

    #or
    print $wiki->box(lon_min => 37.617188,
                     lat_min => 55.677586,
                     lon_max => 37.70507,
                     lat_max => 55.7271128);

    #or
    print $wiki->box(x =>687, y => 328, z => 10);

=cut

# TODO: Limitations of Box API
# (lon_max - lon_min) * 10000000 must be greater than 12100
# (lon_max - lon_min) * (lat_max - lat_min)| * 10000000 must be less than 14641000000
sub box
{
    my $self  = shift;
    my %param = validated_hash(\@_,
                'bbox'    => { isa => 'BBox',       optional => 1 },
                'lon_min' => { isa => 'Coordinate', optional => 1 },
                'lat_min' => { isa => 'Coordinate', optional => 1 },
                'lon_max' => { isa => 'Coordinate', optional => 1 },
                'lat_max' => { isa => 'Coordinate', optional => 1 },
                'x'       => { isa => 'Coordinate', optional => 1 },
                'y'       => { isa => 'Coordinate', optional => 1 },
                'z'       => { isa => 'Coordinate', optional => 1 },
                MX_PARAMS_VALIDATE_NO_CACHE => 1);

    croak("ERROR: Missing lon_min/lat_min/lon_max/lat_max coordinates.\n")
        if (!exists($param{bbox})
            &&
            ((exists($param{'lon_min'}) && !(exists($param{'lat_min'}) || exists($param{'lon_max'}) || exists($param{'lat_max'})))
             ||
             (exists($param{'lat_min'}) && !(exists($param{'lon_min'}) || exists($param{'lon_max'}) || exists($param{'lat_max'})))
             ||
             (exists($param{'lon_max'}) && !(exists($param{'lon_min'}) || exists($param{'lat_min'}) || exists($param{'lat_max'})))
             ||
             (exists($param{'lat_max'}) && !(exists($param{'lon_min'}) || exists($param{'lat_min'}) || exists($param{'lon_max'})))));

    croak("ERROR: Missing x,y,z coordinates.\n")
        if (!exists($param{bbox})
            &&
            ((exists($param{'x'}) && !(exists($param{'y'}) || exists($param{'z'})))
             ||
             (exists($param{'y'}) && !(exists($param{'x'}) || exists($param{'z'})))
             ||
             (exists($param{'z'}) && !(exists($param{'x'}) || exists($param{'y'})))));

    croak("ERROR: Missing boundary box coordinates.\n")
        unless (!exists($param{bbox})
                &&
                ((exists($param{'lon_min'}) || exists($param{'lat_min'}) || exists($param{'lon_max'}) || exists($param{'lat_max'}))
                 ||
                 (exists($param{'x'}) || exists($param{'y'}) || exists($param{'z'}))));

    my ($url);
    $url = sprintf("%s?function=box&bbox=%s", $BASE_URL, $param{'bbox'})
        if defined $param{'bbox'};

    $url = sprintf("%s?function=box&lon_min=%s&lat_min=%s&lon_max=%s&lat_max=%s", $BASE_URL,
        $param{'lon_min'},$param{'lat_min'},$param{'lon_max'},$param{'lat_max'})
        if (!defined($param{'bbox'}) && (exists($param{'lon_min'}) || exists($param{'lat_min'}) || exists($param{'lon_max'}) || exists($param{'lat_max'})));

    $url = sprintf("%s?function=box&x=%s&y=%s&z=%s", $BASE_URL, $param{'x'},$param{'y'},$param{'z'})
        if (!defined($param{'bbox'}) && (exists($param{'x'}) || exists($param{'y'}) || exists($param{'z'})));

    $url.= sprintf("&key=%s", $self->key);
    $url = $self->_addOptionalParams($url);
    return $self->_process($url);
}

=head2 object()

Returns information about object.

    +---------+---------------------------------------------------------------------+
    | Key     | Description                                                         |
    +---------+---------------------------------------------------------------------+
    | id      | Identifier of the object you want to get information about.         |
    +---------+---------------------------------------------------------------------+

    use strict; use warnings;
    use WebService::Wikimapia;

    my $key  = 'Your_API_Key';
    my $wiki = WebService::Wikimapia->new(key => $key);

    print $wiki->object(22139);

=cut

sub object
{
    my $self = shift;
    my $id   = shift;
    croak("ERROR: Missing object id.\n") unless defined $id;

    my $url = sprintf("%s?function=object&id=%s", $BASE_URL, $id);
    $url.= sprintf("&key=%s", $self->key);
    $url = $self->_addOptionalParams($url);
    return $self->_process($url);
}

sub _process
{
    my $self = shift;
    my $url  = shift;

    my ($browser, $request, $response, $content);
    $browser = $self->browser;
    $browser->env_proxy;
    $request  = HTTP::Request->new(GET => $url);
    $response = $browser->request($request);
    croak("ERROR: Couldn't fetch data [$url]:[".$response->status_line."]\n")
        unless $response->is_success;
    $content  = $response->content;
    croak("ERROR: No data found.\n") unless defined $content;
    return $content;
}

sub _addOptionalParams
{
    my $self = shift;
    my $url  = shift;

    $url .= sprintf("&disable=%s",  $self->disable) if $self->disable;
    $url .= sprintf("&page=%s",     $self->page);
    $url .= sprintf("&count=%s",    $self->count);
    $url .= sprintf("&language=%s", $self->language);
    $url .= sprintf("&format=%s",   $self->format);
    $url .= sprintf("&pack=%s",     $self->pack);

    return $url;
}

sub _validateBBox
{
    my $data = shift;
    return 0 unless ((defined $data) && ($data =~ /\,/));

    my ($lon_min,$lat_min,$lon_max,$lat_max) = split /\,/,$data,4;
    return 0 unless (((defined $lon_min) && ($lon_min =~ /\-?\d+\.?\d+$/))
                     &&
                     ((defined $lat_min) && ($lat_min =~ /\-?\d+\.?\d+$/))
                     &&
                     ((defined $lon_max) && ($lon_max =~ /\-?\d+\.?\d+$/))
                     &&
                     ((defined $lat_max) && ($lat_max =~ /\-?\d+\.?\d+$/)));
    return 1;
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-webservice-wikimapia at rt.cpan.org> ,  or
through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WebService-Wikimapia>.
I will be notified and then you'll automatically be notified of progress on your bug as I make
changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WebService::Wikimapia

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WebService-Wikimapia>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WebService-Wikimapia>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WebService-Wikimapia>

=item * Search CPAN

L<http://search.cpan.org/dist/WebService-Wikimapia/>

=back

=head1 LICENSE AND COPYRIGHT

This  program  is  free  software; you can redistribute it and/or modify it under the terms of
either:  the  GNU  General Public License as published by the Free Software Foundation; or the
Artistic License.

See http://dev.perl.org/licenses/ for more information.

=head1 DISCLAIMER

This  program  is  distributed in the hope that it will be useful,  but  WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

__PACKAGE__->meta->make_immutable;
no Mouse; # Keywords are removed from the WebService::Wikimapia package
no Mouse::Util::TypeConstraints;

1; # End of WebService::Wikimapia
