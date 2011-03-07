#!/usr/bin/env perl

use Test::More import => ['!pass'];

use strict;
use warnings;
use Dancer;

my $CLASS = 'Dancer::Session::Cookie';
use_ok $CLASS;

note "test setup"; {
    set session_cookie_key => "The dolphins are in the jacuzzi";
}


note "default path"; {
    my $session = Dancer::Session::Cookie->create;
    $session->flush;

    is cookies->{"dancer.session"}->path, "/";
}


note "set the path"; {
    set session_cookie_path => "/some/thing";

    my $session = Dancer::Session::Cookie->create;
    $session->flush;

    is cookies->{"dancer.session"}->path, "/some/thing";
}

done_testing;
