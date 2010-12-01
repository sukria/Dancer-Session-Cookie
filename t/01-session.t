use Test::More import => ['!pass'];
use Test::Exception;
use Test::NoWarnings;

use strict;
use warnings;
use Dancer;
use Dancer::ModuleLoader;

BEGIN { 
    plan tests => 12;
    use_ok 'Dancer::Session::Cookie' 
}

my $session;

throws_ok { $session = Dancer::Session::Cookie->create }
    qr/session_cookie_key must be defined/, 'requires session_cookie_key';

set session_cookie_key => 'test/secret*@?)';
lives_and { $session = Dancer::Session::Cookie->create } 'works';
is $@, '', 'Cookie session created';

isa_ok $session, 'Dancer::Session::Cookie';
can_ok $session, qw(init create retrieve destroy flush);

my $eid;
ok defined($eid = $session->id), 'session id is defined';
$session->{bar} = 'baz';
$session->flush;
ok defined($session->id), 'id after storing a value is defined';
isnt $session->id, $eid, '...but changed';
ok length($session->id) > 20, 'new id is a long string';

my $s = Dancer::Session::Cookie->retrieve('XXX');
is $s, undef, 'unknown session is not found';

$s = Dancer::Session::Cookie->retrieve($session->id);
is_deeply $s, $session, 'session is retrieved';
