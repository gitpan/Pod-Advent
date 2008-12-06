#!perl

use strict;
use warnings;
use Test::More tests => 2;

use IO::CaptureOutput qw(capture capture_exec);

my ($stdout, $stderr);

chdir 'ex';

my @perl = ( $^X, '-I../lib' );
push @perl, '-MDevel::Cover=-silent,1,-db,../cover_db,-ignore,.,-select,Pod-Advent' if exists $INC{'Devel/Cover.pm'};
($stdout, $stderr) = capture_exec( @perl, '../bin/pod2advent');

my $html = "";
my $err = <<'EOF';
need pod filename at ../bin/pod2advent line 7.
EOF

is($stdout, $html, "file matches");
is($stderr, $err, "errors match");

