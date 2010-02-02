#!perl -T

use strict;
use warnings;
use Test::More;

unless ( $ENV{RELEASE_TESTING} ) {
    plan( skip_all => "Author tests not required for installation" );
}

eval "use Test::DistManifest";
plan skip_all => "Test::DistManifest required" if $@;
manifest_ok();
