use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'namepass',
    AUTHOR              => q{Audrey Tang <audreyt@audreyt.org>},
#    VERSION_FROM        => 'namepass.pm',
    VERSION             => 1,
    ABSTRACT            => 'Generate Chinese Name Passwords',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Hijk'        => 0,
        'JSON'        => 0,
        'File::Slurp' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'namepass-*' },
);
