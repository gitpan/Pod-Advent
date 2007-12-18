#!perl

use strict;
use warnings;
use Test::More tests => 4;

use Pod::Advent;

my $advent = Pod::Advent->new;
isa_ok($advent, 'Pod::Advent');
my $s;
$advent->output_string( \$s );
$advent->parse_file( \*DATA );

like($s, qr#<!-- Generated by Pod::Advent \S+ \(Pod::Simple \S+, Perl::Tidy \S+\) on \d{4}-\d\d-\d\d \d\d:\d\d:\d\d -->#, "'Generated by' line");
like($s, qr#<p>This is a <B>test</B>\.</p>#, 'bold line');
like($s, qr#<p>This is a another <I>test</I>\.</p>#, 'italics line');

__DATA__

=pod

This is a B<test>.

This is a another I<test>.

=cut
