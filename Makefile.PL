use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Dancer::Session::Cookie',
    AUTHOR              => q{Alex Kapranoff <kappa@cpan.org>},
    VERSION_FROM        => 'lib/Dancer/Session/Cookie.pm',
    ABSTRACT_FROM       => 'lib/Dancer/Session/Cookie.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'      => 0,
        'Crypt::CBC'      => 0,
        'String::CRC32'   => 0,
        'Crypt::Rijndael' => 0,
        'Dancer'          => 1.130,
        'Test::NoWarnings'=> 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Dancer-Session-Cookie-* t/logs' },
);
