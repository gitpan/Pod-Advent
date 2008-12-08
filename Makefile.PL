use strict;
use warnings;
use 5.006;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Pod::Advent',
    AUTHOR              => 'David Westbrook <dwestbrook@gmail.com>',
    VERSION_FROM        => 'lib/Pod/Advent.pm',
    ABSTRACT_FROM       => 'lib/Pod/Advent.pm',
    EXE_FILES           => [ 'bin/pod2advent' ],
    PREREQ_PM => {
					# {newest as of 12/2008; should eventually become min vers}
        'Test::More' => 0,		#	0.86
	'Pod::Simple' => 0,		#	3.07
	'Perl::Tidy' => 0,		#	20071205
	'Text::Aspell' => 0,		#	0.09
	'IO::CaptureOutput' => 0,	#	1.1
	'File::Basename' => 0,		#	2.74
	'Cwd' => 0,			#	3.29
	'Test::Differences' => 0,	#	0.4801
	'ExtUtils::MakeMaker' => 6.48,  # MIN_PERL_VERSION support was added in v6.47_01
    },
    MIN_PERL_VERSION    => '5.6.1',
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Pod-Advent-*' },
);
