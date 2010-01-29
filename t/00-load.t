#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Dancer::Session::Cookie' ) || print "Bail out!
";
}

diag( "Testing Dancer::Session::Cookie $Dancer::Session::Cookie::VERSION, Perl $], $^X" );
