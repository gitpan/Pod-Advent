#!perl

use strict;
use warnings;
use Test::More tests => 23;
use Pod::Advent;
use IO::CaptureOutput qw(capture);

sub test_snippet {
  my $desc     = shift;
  my $pod      = shift;
  my $expected = shift;
  my $no_extra_newline = shift || 0;
  my $s;
  my $ADVENT = Pod::Advent->new;
  $Pod::Advent::BODY_ONLY = 1;
  $ADVENT->output_string( \$s );
  $ADVENT->parse_string_document("=pod\n\n" . $pod . "\n\n=cut");
  is( $s, $expected.($no_extra_newline?'':"\n"), $desc );
}

test_snippet 'bold line', 'This is a B<test>.', '<p>This is a <span style="font-weight: bold">test</span>.</p>';

test_snippet 'italics line', 'This is a I<test>.', '<p>This is a <span style="font-style: italic">test</span>.</p>';

test_snippet 'A<url>', 'A<http://example.com>', '<p><tt><a href="http://example.com">http://example.com</a></tt></p>';
test_snippet 'A<url|desc>', 'A<http://example.com|stuff>', '<p><tt><a href="http://example.com">stuff</a></tt></p>';
test_snippet 'M<Module::Name>', 'M<Foo::Bar>', '<p><tt><a href="http://search.cpan.org/perldoc?Foo::Bar">Foo::Bar</a></tt></p>';

test_snippet 'L<>', 'L<test>', '<p><tt><a href="test">test</a></tt></p>';
test_snippet 'F<>', 'F<test>', '<p><tt>test</tt></p>';
test_snippet 'C<>', 'C<test>', qq{<p><tt><span class="w">test</span>\n</tt></p>};
test_snippet 'I<>', 'I<test>', '<p><span style="font-style: italic">test</span></p>';
test_snippet 'B<>', 'B<test>', '<p><span style="font-weight: bold">test</span></p>';

test_snippet 'code', qq{=begin code\n\nfoo\n\n=end code}, q{<pre>
<span class="w">foo</span>
</pre>
};
test_snippet 'codeNNN', qq{=begin codeNNN\n\nfoo\n\n=end codeNNN}, q{<pre>
   1 <span class="w">foo</span>
</pre>
};
test_snippet 'pre', qq{=begin pre\n\nfoo\n\n=end pre}, q{<pre><span class="c">foo</span></pre>};
test_snippet 'quote', qq{=begin quote\n\nfoo\n\n=end quote}, q{<blockquote style="padding: 1em; border: 2px ridge black; background-color:#eee"><p>foo</p>
</blockquote>
}, 1;
test_snippet 'eds', qq{=begin eds\n\nfoo\n\n=end eds}, q{<blockquote style="padding: 1em; border: 2px ridge black; background-color:#eee"><p>foo</p>
</blockquote>
}, 1;

test_snippet 'unknown', qq{=begin unknown\n\nfoo\n\n=end unknown}, '', 1;

test_snippet 'head1', qq{=head1 foo}, q{<h1>foo</h1>};
test_snippet 'head1a', qq{=head1 foo\nbar}, q{<h1>foo bar</h1>};
test_snippet 'head1b', qq{=head1 foo\n\nbar}, qq{<h1>foo</h1>\n<p>bar</p>};
test_snippet 'head2', qq{=head2 foo}, q{<h2>foo</h2>};
test_snippet 'head3', qq{=head3 foo}, q{<h3>foo</h3>};
test_snippet 'head4', qq{=head4 foo}, q{<h4>foo</h4>};

test_snippet 'html', q{foo<b>bar</b><i>stuff</i>}, q{<p>foo<b>bar</b><i>stuff</i></p>};

