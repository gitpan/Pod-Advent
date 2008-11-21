package Pod::Advent;

use strict;
use warnings;
use base qw(Pod::Simple);
use Perl::Tidy;

our $VERSION = '0.06';

our @mode;
our $section;
our %data;
our %blocks;
our %M_values_seen;
our $BODY_ONLY;

__PACKAGE__->__reset();

sub __reset(){
  my $self = shift;

  @mode = ();
  $section = '';
  %data = (
    title => undef,
    author => undef,
    year => (localtime)[5]+1900,
    day => 0,
    body => '',
    file => undef,
    css_url => '../style.css',
  );
  %blocks = (
    code => '',
    codeNNN => '',
    pre => '',
    sourced_file => '',
    sourced_desc => '',
  );
  %M_values_seen = ();
  $BODY_ONLY = 0;
}

sub new {
  my $self = shift;
  $self = $self->SUPER::new(@_);
  $self->accept_codes( qw/A M N/ );
  $self->accept_targets_as_text( qw/advent_title advent_author advent_year advent_day/ );
  $self->accept_targets( qw/code codeNNN pre/ );
  $self->accept_targets_as_text( qw/quote eds/ );
#  $self->accept_targets_as_text( map { "footnote$_" } 1 .. 25 );
  $self->accept_directive_as_data('sourcedcode');
  $self->__reset();
  return $self;
}

sub css_url {
  my $self = shift;
  if( scalar @_ ){
    $data{css_url} = $_[0];
  }
  return $data{css_url};
}

sub parse_file {
  my $self = shift;
  $data{file} = $_[0] if ! ref($_[0]);  # if it's a scalar, meaning a filename
  $self = $self->SUPER::parse_file(@_);
}

sub add {
  my $self = shift;
  my $s = shift;
  $data{body} .= $s;
}

sub nl {
  my $self = shift;
  $self->add("\n");
}

sub _handle_element_start {
  my($parser, $element_name, $attr_hash_r) = @_;
  push @mode, $element_name;
  if( $element_name eq 'Document' ){
  }elsif( $element_name eq 'head1' ){
    $parser->add('<h1>');
  }elsif( $element_name eq 'head2' ){
    $parser->add('<h2>');
  }elsif( $element_name eq 'head3' ){
    $parser->add('<h3>');
  }elsif( $element_name eq 'head4' ){
    $parser->add('<h4>');
  }elsif( $element_name eq 'Para' && ($mode[-2]||'') ne 'for' ){
    $parser->add('<p>');
  }elsif( $element_name eq 'L' ){
    $parser->add( sprintf('<tt><a href="%s">',$attr_hash_r->{to}) );
  }elsif( $element_name eq 'A' ){
    $parser->add('<tt>');
  }elsif( $element_name eq 'M' ){
    $parser->add('<tt>');
  }elsif( $element_name eq 'F' ){
    $parser->add('<tt>');
  }elsif( $element_name eq 'C' ){
    $parser->add('<tt>');
  }elsif( $element_name eq 'I' ){
    $parser->add('<span style="font-style: italic">');
  }elsif( $element_name eq 'B' ){
    $parser->add('<span style="font-weight: bold">');
  }elsif( $element_name eq 'for' && $attr_hash_r->{target} =~ /^advent_(\w+)$/ ){
    $section = $1;
  }elsif( $element_name eq 'for' && $attr_hash_r->{target} =~ /^quote|eds$/ ){
    $mode[-1] = $attr_hash_r->{target};
    $parser->add('<blockquote style="padding: 1em; border: 2px ridge black; background-color:#eee">');
  }elsif( $element_name eq 'for' && $attr_hash_r->{target} =~ /^code|codeNNN|pre$/ ){
    $section = $attr_hash_r->{target};
  }
}

sub _handle_element_end {
  my($parser, $element_name) = @_;
  my $mode = pop @mode;
  if( $element_name eq 'Document' ){
    my $fmt = <<'EOF';
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!-- Generated by Pod::Advent %s (Pod::Simple %s, Perl::Tidy %s) on %04d-%02d-%02d %02d:%02d:%02d -->
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>%d Perl Advent Calendar: %s</title>
<link rel="stylesheet" href="%s" type="text/css" /></head>
<body>
<h1><a href="../">Perl Advent Calendar %d-12</a>-%02d</h1>
<h2 align="center">%s</h2>
<h3 align="center">by %s</h3>
EOF
    my @d = (localtime)[5,4,3,2,1,0]; $d[1]++; $d[0]+=1900;
    my $fh = $parser->output_fh() || \*STDOUT;
    printf( $fh $fmt,
	$Pod::Advent::VERSION, $Pod::Simple::VERSION, $Perl::Tidy::VERSION,
	@d[0..5],
	map {defined($_)?$_:''} @data{qw/year title css_url year day title author/},
    ) unless $BODY_ONLY;
    print $fh $data{body};
    if( $data{file} ){
      printf $fh '<div style="float: right; font-size: 10pt"><a href="%s">POD</a></div><br />'."\n", $data{file};
    }
    print $fh <<'EOF' unless $BODY_ONLY;
</body>
</html>
EOF
  }elsif( $element_name eq 'head1' ){
    $parser->add('</h1>');
    $parser->nl;
  }elsif( $element_name eq 'head2' ){
    $parser->add('</h2>');
    $parser->nl;
  }elsif( $element_name eq 'head3' ){
    $parser->add('</h3>');
    $parser->nl;
  }elsif( $element_name eq 'head4' ){
    $parser->add('</h4>');
    $parser->nl;
  }elsif( $element_name eq 'Para' && ($mode[-1]||'') ne 'for' ){
    $parser->add('</p>');
    $parser->nl;
  }elsif( $element_name eq 'for' && $mode =~ /^quote|eds$/ ){
    $parser->add('</blockquote>');
    $parser->nl;
  }elsif( $element_name eq 'for' && $section =~ /^code|codeNNN$/ ){
    my $s;
    $blocks{$section} =~ s/\s+$//;
    Perl::Tidy::perltidy(
        source            => \$blocks{$section},
        destination       => \$s,
        argv              => [qw/-html -pre/, ($section=~/NNN/?'-nnn':()) ],
    );
    $parser->add($s);
    $parser->nl;
    $blocks{$section} = '';
    $section = '';
  }elsif( $element_name eq 'for' && $section eq 'pre' ){
    $blocks{$section} =~ s/\s+$//s;
    $parser->add('<pre><span class="c">');
    $parser->add($blocks{$section});
    $parser->add('</span></pre>');
    $parser->nl;
    $blocks{$section} = '';
    $section = '';
  }elsif( $element_name eq 'L' ){
    $parser->add('</a></tt>');
  }elsif( $element_name eq 'M' ){
    $parser->add('</tt>');
  }elsif( $element_name eq 'A' ){
    $parser->add('</tt>');
  }elsif( $element_name eq 'F' ){
    $parser->add('</tt>');
  }elsif( $element_name eq 'C' ){
    $parser->add('</tt>');
  }elsif( $element_name eq 'I' ){
    $parser->add('</span>');
  }elsif( $element_name eq 'B' ){
    $parser->add('</span>');
  }
}

sub _handle_text {
  my($parser, $text) = @_;
  my $mode = $mode[-1];
  my $out = '';
  if( $mode eq 'Verbatim' ){
    my $s;
    Perl::Tidy::perltidy(
        source            => \$text,
        destination       => \$s,
        argv              => [qw/-html -pre/],
    );
    $out .= $s;
  }elsif( $mode eq 'C' ){
    my $s;
    Perl::Tidy::perltidy(
        source            => \$text,
        destination       => \$s,
        argv              => [qw/-html -pre/],
    );
    $s =~ s#^<pre>\s*(.*?)\s*</pre>$#$1#si;
    $out .= $s;
  }elsif( $mode eq 'N' ){
    $out .= sprintf '<sup><a href="#footnote%s">%s</a></sup>', $text, $text;
  }elsif( $mode eq 'sourcedcode' ){
#    $section = $mode;
    die "bad filename '$text'" unless -r $text;
    $blocks{sourced_file} = $text;
    $out .= sprintf '<a name="%s" id="%s"></a><h2><a href="%s">%s</a></h2>', ($text)x4;
    my $s;
    Perl::Tidy::perltidy(
        source            => $text,
        destination       => \$s,
        argv              => [qw/-html -pre -nnn/],
    );
    $out .= $s;
#  }elsif( $mode =~ /^footnote/ ){
#    $data{$section} .= $text;
  }elsif( $mode eq 'Para' && $section ){
    $data{$section} = $text;
    $section = '';
  }elsif( $mode eq 'A' ){
    my ($href, $text) = split /\|/, $text, 2;
    $text = $href unless defined $text;
    $parser->add( sprintf('<a href="%s">%s</a>',$href,$text) );
  }elsif( $mode eq 'M' ){
    if( $M_values_seen{$text}++ ){
      $parser->add($text);
    }else{
      $parser->add( sprintf('<a href="http://search.cpan.org/search?module=%s">%s</a>',$text,$text) );
    }
  }elsif( $mode eq 'Data' && $section ){
    $blocks{$section} .= $text . "\n\n";
  }else{
    $out .= $text;
  }
  $parser->add( $out, undef );
}

1; # End of Pod::Advent

__END__

=pod

=head1 NAME

Pod::Advent - POD Formatter for The Perl Advent Calendar

=head1 VERSION

Version 0.06

=head1 SYNOPSIS

Most likely, the included I<pod2advent> script is all you will need:

  pod2advent entry.pod > entry.html

Or, using this module directly:

  use Pod::Advent;
  my $pod = shift @ARGV or die "need pod filename";
  my $advent = Pod::Advent->new;
  $advent->parse_file( \*STDIN );

Example POD:

  =for advent_year 2008

  =for advent_day 32

  =for advent_title This is a sample

  =for advent_author Your Name Here

  Today's module M<My::Example> is featured on
  the A<http://example.com|Example Place> web site
  and is I<very> B<special>.

  =sourcedcode example.pl

B<Getting Started:>
See F<ex/getting_started.pod> and F<ex/getting_started.html> in the distribution for an initial template.

=head1 DESCRIPTION

This module provides a POD formatter that is designed to facilitate the create of submissions for The Perl Advent Calendar (L<http://perladvent.pm.org>) by providing authors with simple markup that will be automatically transformed to full-fill the specific formatting guidelines. This makes it easier for authors to provide calendar-ready submissions, and for the editors to save lots of time in editting submissions.

For example, 'file-, module and program names should be wrapped in <tt>,' and 'the code sample should be appended to the document from the results of a perltidy -nnn -html'. Both of these can be trivially accomplished:

  This entry is for M<Foo::Bar> and the F<script.pl> program.

  =sourcedcode mod0.pl

The meta-data of title, date (year & day), and author is now easy to specify as well, and is used to automatically generate the full HTML header (including style) that the calendar entries require before being posted.

See F<ex/sample.pod.txt> and F<ex/sample.html> in the distribution for a fuller example.

=head1 SUPPORTED POD

=head2 Custom Codes

=head3 AE<lt>E<gt>

This is because POD doesn't support the case of LE<lt>http://example.com|ExampleE<gt>, so we introduce this AE<lt>E<gt> code for that exact purpose -- to generate E<lt>a href="URL"E<gt>TEXTE<lt>/aE<gt> hyperlinks.

  A<http://perladvent.pm.org|The Perl Advent Calendar>
  A<http://perladvent.pm.org>

=head3 ME<lt>E<gt>

This is intended for module names. The first instance, it will <tt> it and hyperlink it to a F<http://search.cpan.org/search?module=> url. All following instances will just <tt> it. Being just for module searches, any other searches can simply use the AE<lt>E<gt> code instead.

  M<Pod::Simple>
  A<http://search.cpan.org/search?query=Pod::Simple::Subclassing|Pod::Simple::Subclassing>
  A<http://search.cpan.org/search?dist=TimeDate|TimeDate>

=head3 NE<lt>E<gt>

Insert a superscript footnote reference. It will link to a #N anchor.

  In this entry we talk about XYZ.N<3>
  ...
  <a name="3" id="3"></a>3.
  Some footnote about XYZ.

=head2 Custom Directives

=head3 sourcedcode

=head2 Custom Info Targets

=head3 advent_title

Specify the title of the submission.

  =for advent_title Your Entry Title

=head3 advent_author

Specify the author of the submission.

  =for advent_author Your Name Here

=head3 advent_year

Specify the year of the submission (defaults to current year).

  =for advent_year 2008

=head3 advent_day

Specify the day of the submission (if currently known).

  =for advent_day 99

=head2 Custom Block Targets

=head3 code

Display a code snippet (sends it through Perl::Tidy).

  =begin code
  my $foo = Bar->new();
  $foo->do_it;
  =end code

=head3 codeNNN

Same as L<code>, but with line numbers.

  =begin codeNNN
  my $foo = Bar->new();
  $foo->do_it;
  =end codeNNN

=head3 pre

Display a snippet (e.g. data, output, etc) as E<lt>PREE<gt>-formatted text (does not use Perl::Tidy).

  =begin pre
  x,y,z
  1,2,3
  2,4,9
  3,8,27
  =end pre

=head3 quote

Processes POD and wraps it in a E<lt>BLOCKQUOTEE<gt> section.

  =begin quote
  "Ho-Ho-Ho!"
    -- S.C.
  =end quote

=head3 eds

Currently behaves exactly the same as L<quote>.

  =begin eds
  The editors requested
  this directive.
    -- the management
  =end eds

=head2 Standard Codes

=head3 LE<lt>E<gt>

Normal behavior.

=head3 FE<lt>E<gt>

Normal behavior.  Uses E<lt>ttE<gt>

=head3 CE<lt>E<gt>

Uses E<lt>ttE<gt>. Sends text through Perl::Tidy.

=head3 IE<lt>E<gt>

Normal behavior: uses E<lt>IE<gt>

=head3 BE<lt>E<gt>

Normal behavior: uses E<lt>BE<gt>

=head2 Standard Directives

=head3 headN

Expected behavior (N=1..4): uses E<lt>headNE<gt>

=head1 TODO

more tests

create test for bin/pod2advent

create test for output_fh not being set

test w/more complicated perl samples, for differences in Perl::Tidy versions.

code refactoring (package var usage; also maybe make code/directive behavior based on a config data structure)

footnotes

support for =over/=item

docs re: html passing through

spell check support -- probably on the POD, as opposed to generated html

check html output for validity

=head1 METHODS

See L<Pod::Simple> for all of the inherited methods.  Also see L<Pod::Simple::Subclassing> for more information.

=head2 new

Constructor.  See L<Pod::Simple>.

=head2 parse_file

Overloaded from Pod::Simple -- if input is a filename, will add a link to it at the bottom of the generated HTML.

=head2 css_url

Accessor/mutator for the stylesheet to use.  Defaults to F<../style.css>

=head1 INTERNAL METHODS

=head2 add

Appends text to the output buffer.

=head2 nl

Appends a newline onto the output buffer.

=head2 _handle_element_start

Overload of method to process start of an element.

=head2 _handle_element_end

Overload of method to process end of an element.

=head2 _handle_text

Overload of method to process handling of text.

=head1 AUTHOR

David Westbrook (CPAN: davidrw), C<< <dwestbrook at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-pod-advent at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Pod-Advent>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Pod::Advent

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Pod-Advent>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Pod-Advent>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Pod-Advent>

=item * Search CPAN

L<http://search.cpan.org/dist/Pod-Advent>

=back

=head1 SEE ALSO

=over 4

=item *

L<http://perladvent.pm.org> - The Perl Advent Calendar

=item *

L<http://perladvent.pm.org/2007/17> - The 2007-12-17 submission that discussed this application of Pod::Simple

=item *

L<Pod::Simple> - The base class for Pod::Advent

=item *

L<Pod::Simple::Subclassing> - Discusses the techniques that Pod::Advent is based on

=item *

L<perlpod> - POD documentation

=item *

L<Perl::Tidy> - used for formatting code

=back

=head1 ACKNOWLEDGEMENTS

The maintainers of The Perl Advent Calendar at L<http://perladvent.pm.org>.

The 2007 editors, Bill Ticker & Jerrad Pierce, for reviewing and providing feedback on this concept.

=head1 COPYRIGHT & LICENSE

Copyright 2007 David Westbrook, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
