#!perl

use strict;
use warnings;
use Test::More tests => 34;
use Test::Differences;
use IO::CaptureOutput qw(capture_exec);

my @perl = ( $^X, '-Ilib' );
push @perl, '-MDevel::Cover=-silent,1,-db,cover_db,-ignore,.,+select,advent,+select,Advent' if exists $INC{'Devel/Cover.pm'};

my @files = (
  [ 'ex/sample.pod', 'ex/sample.html', '## Please see file perltidy.ERR
Possible SPELLING ERRORS:
	href
	lt
	pre
	mispelling
', ],
  [ 'ex/getting_started.pod', 'ex/getting_started.html', '## Please see file perltidy.ERR
', ],
  [ 'ex/footnotes.pod', 'ex/footnotes.html', 'Possible SPELLING ERRORS:
	sourcedcode
', ],
  [ '+', undef, '', 'B<test>', '<p><span style="font-weight: bold">test</span></p>' ],
  [ '-', undef, '', 'B<test>', q{<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!-- Generated by Pod::Advent 0.15 (Pod::Simple 3.07, Perl::Tidy 20071205) on 2008-12-19 23:48:02 -->
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>2008 Perl Advent Calendar: </title>
<link rel="stylesheet" href="../style.css" type="text/css" />

</head>
<body>
<h1><a href="../">Perl Advent Calendar 2008-12</a>-00</h1>
<h2 align="center"></h2>
<h3 align="center">by </h3>
</body>
</html>} ],
  [ '+', undef, 'Possible SPELLING ERRORS:
	z1
', 'B<z1>', '<p><span style="font-weight: bold">z1</span></p>' ],
);

foreach my $info ( @files ){
  my ( $podfile, $htmlfile, $errors,   $stdin, $snippet ) = @$info;
  my ($stdout, $stderr, $success, $exit_code) = $stdin
	? capture_exec( join ' ', "echo '$stdin' |" , @perl, 'bin/pod2advent', $podfile )
	: capture_exec( @perl, 'bin/pod2advent', $podfile )
  ;

  is($success, 1, "[$podfile] success");
  is($exit_code, 0, "[$podfile] exit code");

  my $html = $stdin
	? $snippet . "\n"
	: do{ local $/ = undef; open FILE, '<', $htmlfile; <FILE> }
  ;
  s/^<!-- Generated by Pod::Advent .+? -->$//m for $html, $stdout;

  SKIP: {
    skip 'spellcheck disabled', 3 if $stderr =~ /Couldn't load Text::Aspell -- spellchecking disabled./;
    eq_or_diff($stderr, $errors, "[$podfile] errors match");

    ok( $stdout, "[$podfile] got output" )
	or skip 'no output!', 1;
    eq_or_diff($stdout, $html,   "[$podfile] output matches");
  }
}


my ($stdout, $stderr, $success, $exit_code) = capture_exec( @perl, 'bin/pod2advent');
is($success, 0, "[no args] failed");
ok($exit_code>>8, "[no args] exit code");
eq_or_diff($stdout, '', "[no args] file matches");
SKIP: {
  skip 'spellcheck disabled', 1 if $stderr =~ /Couldn't load Text::Aspell -- spellchecking disabled./;
  eq_or_diff($stderr, "need pod filename, or - for file on stdin, or + for snippet on stdin at bin/pod2advent line 7.\n", "[no args] errors match");
}

