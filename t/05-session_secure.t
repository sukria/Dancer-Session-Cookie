#!/usr/bin/env perl

use strict;
use warnings;

use Dancer ':syntax';
use Dancer::Session::Cookie;

use Test::More import => ["!pass"];

plan skip_all => "Dancer::Cookie->secure not supported in this version of Dancer"
  unless Dancer::Cookie->can("secure");

plan tests => 2;

my $Session_Name = Dancer::Session::Cookie->session_name;

note "session_secure off"; {
    set session_cookie_key => "secret squirrel";
    set session => "cookie";
    session foo => "bar";

    my $session_cookie = Dancer::Cookies->cookies->{ $Session_Name };
    ok !$session_cookie->secure;
}


note "session_secure on"; {
    delete Dancer::Cookies->cookies->{ $Session_Name };

    set session_secure  => 1;
    set session         => "cookie";

    session up => "down";

    my $session_cookie = Dancer::Cookies->cookies->{ $Session_Name };
    ok $session_cookie->secure;
}
