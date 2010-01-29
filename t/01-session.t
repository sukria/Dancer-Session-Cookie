use Test::More import => ['!pass'];

use strict;
use warnings;
use Dancer;
use Dancer::ModuleLoader;
use Dancer::Config 'setting';

BEGIN { 
    plan tests => 4;
    use_ok 'Dancer::Session::Cookie' 
}

my $session;
setting session_cookie_key => 'test/secret*@?)';

eval { $session = Dancer::Session::Cookie->create };
is $@, '', "Cookie session created";

isa_ok $session, 'Dancer::Session::Cookie';
can_ok $session, qw(init create retrieve destroy flush);

