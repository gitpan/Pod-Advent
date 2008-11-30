#!perl

use strict;
use warnings;
use Test::More tests => 22;
use Pod::Advent;

my $advent = Pod::Advent->new;
my $s;
$advent->output_string( \$s );
$advent->parse_file( \*DATA );

is( $advent->num_spelling_errors, 18, "misspelled word ct" );
is_deeply( [ $advent->spelling_errors ], [qw/
	z1
	z2
	z3
	z4
	z5
	z6
	z9
	z15
	z16
	z20
	z21
	z22
	z23
	z24
	z25
	z26
	z27
	z28
/], "misspelled words" )
	or diag join "\n", map { "\t$_" } $advent->spelling_errors;

$advent->__reset();
is( $advent->num_spelling_errors, 0, "<reset> misspelled word ct" );
is_deeply( [ $advent->spelling_errors ], [qw/ /], "<reset> misspelled words" );

my $text;

$text = "";
is( $advent->__spellcheck($text), 0, "[$text] spellcheck return val" );
is( $advent->num_spelling_errors, 0, "[$text] misspelled word ct" );
is_deeply( [ $advent->spelling_errors ], [qw/ /], "[$text] misspelled words" );

$text = "word";
is( $advent->__spellcheck($text), 0, "[$text] spellcheck return val" );
is( $advent->num_spelling_errors, 0, "[$text] misspelled word ct" );
is_deeply( [ $advent->spelling_errors ], [qw/ /], "[$text] misspelled words" );

$text = "bad z1 and z2 a";
is( $advent->__spellcheck($text), 2, "[$text] spellcheck return val" );
is( $advent->num_spelling_errors, 2, "[$text] misspelled word ct" );
is_deeply( [ $advent->spelling_errors ], [qw/z1 z2/], "[$text] misspelled words" );

$text = "spell";
is( $advent->__spellcheck($text), 0, "[$text] spellcheck return val" );
is( $advent->num_spelling_errors, 2, "[$text] misspelled word ct" );
is_deeply( [ $advent->spelling_errors ], [qw/z1 z2/], "[$text] misspelled words" );

$text = "1234";
is( $advent->__spellcheck($text), 0, "[$text] spellcheck return val" );
is( $advent->num_spelling_errors, 2, "[$text] misspelled word ct" );
is_deeply( [ $advent->spelling_errors ], [qw/z1 z2/], "[$text] misspelled words" );

$text = "more z3 bad z4";
is( $advent->__spellcheck($text), 2, "[$text] spellcheck return val" );
is( $advent->num_spelling_errors, 4, "[$text] misspelled word ct" );
is_deeply( [ $advent->spelling_errors ], [qw/z1 z2 z3 z4/], "[$text] misspelled words" );

__DATA__
=pod

z1 word B<word z2> word I<z3> B<z4 I<z5> word z6>

A<http://example.z07.com>
A<http://example.z08.com|z9>

M<z010>
N<z011>

L<z012>
F<z013>

C<z014>
I<z15>
B<z16>

=begin code

z017

=end code

=begin codeNNN

z018

=end codeNNN

=begin pre

z019

=end pre

=begin eds

z20

=end eds

=head1 z21

z22

=head2 z23

z24

=head3 z25

z26

=head4 z27

z28

=cut
