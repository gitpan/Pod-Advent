use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Pod::Advent',
    AUTHOR              => 'David Westbrook <dwestbrook@gmail.com>',
    VERSION_FROM        => 'lib/Pod/Advent.pm',
    ABSTRACT_FROM       => 'lib/Pod/Advent.pm',
    EXE_FILES           => [ 'bin/pod2advent' ],
    PREREQ_PM => {
        'Test::More' => 0,
	'Pod::Simple' => 0,
	'Perl::Tidy' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Pod-Advent-*' },
);
