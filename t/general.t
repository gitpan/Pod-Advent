#!perl

use strict;
use warnings;
use Test::More tests => 5;

use Pod::Advent;

my $advent = Pod::Advent->new;
isa_ok($advent, 'Pod::Advent');
my $s;
$advent->output_string( \$s );
$advent->parse_file( \*DATA );

like($s, qr#<!-- Generated by Pod::Advent \S+ \(Pod::Simple \S+, Perl::Tidy \S+\) on \d{4}-\d\d-\d\d \d\d:\d\d:\d\d -->#, "'Generated by' line");
like($s, qr#<p>This is a <span style="font-weight: bold">test</span>\.</p>#, 'bold line');
like($s, qr#<p>This is a another <span style="font-style: italic">test</span>\.</p>#, 'italics line');

push @Pod::Advent::mode, 'sourcedcode';
eval { $advent->_handle_text('_non-existent_file_that_DNE.none') };
like( $@, qr/^bad filename '_non-existent_file_that_DNE.none' at /, "bad =sourcedcode file dies" );



__DATA__

=pod

This is a B<test>.

This is a another I<test>.

=cut
