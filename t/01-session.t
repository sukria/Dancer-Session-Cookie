use Test::More import => ['!pass'];
use Test::NoWarnings;

use strict;
use warnings;
use Dancer;
use Dancer::ModuleLoader;
use Dancer::Config 'setting';

BEGIN { 
    plan tests => 10;
    use_ok 'Dancer::Session::Cookie' 
}

my $session;
setting session_cookie_key => 'test/secret*@?)';

eval { $session = Dancer::Session::Cookie->create };
is $@, '', "Cookie session created";

isa_ok $session, 'Dancer::Session::Cookie';
can_ok $session, qw(init create retrieve destroy flush);

my $eid;
ok defined($eid = $session->id), 'session id is defined';
$session->{bar} = 'baz';
$session->flush;
ok defined($session->id), 'id after storing a value is defined';
isnt $session->id, $eid, '...but changed';

my $s = Dancer::Session::Cookie->retrieve('XXX');
is $s, undef, "unknown session is not found";

$s = Dancer::Session::Cookie->retrieve($session->id);
is_deeply $s, $session, "session is retrieved";
