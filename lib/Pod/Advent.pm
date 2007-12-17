package Pod::Advent;

use strict;
use warnings;
use base qw(Pod::Simple);
use Perl::Tidy;

our $VERSION = '0.01';
our @mode;
our $section = '';
our %data = (
  title => undef,
  author => undef,
  year => (localtime)[5]+1900,
  day => 0,
  body => '',
);
our %blocks = (
  code => '',
  codeNNN => '',
  pre => '',
  sourced_file => '',
  sourced_desc => '',
);
our %M_values_seen;

sub new {
  my $self = shift;
  $self = $self->SUPER::new(@_);
  $self->accept_codes( qw/A M Y N/ );
  $self->accept_targets_as_text( qw/advent_title advent_author advent_year advent_day/ );
  $self->accept_targets( qw/code codeNNN pre/ );
  $self->accept_targets_as_text( qw/quote eds/ );
#  $self->accept_targets_as_text( map { "footnote$_" } 1 .. 25 );
  $self->accept_directive_as_data('sourcedcode');
  return $self;
}

sub add {
  my $self = shift;
  my $s = shift;
  $data{body} .= $s;
}

sub br {
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
  }elsif( $element_name eq 'Para' ){
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
    $parser->add('<I>');
  }elsif( $element_name eq 'B' ){
    $parser->add('<B>');
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
    $parser->br;
    $parser->add('</body>');
    $parser->br;
    $parser->add('</html>');
    $parser->br;

    printf <<'EOF', @data{qw/year title year day title author/};
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>%d Perl Advent Calendar: %s</title>
<link rel="stylesheet" href="../style.css" type="text/css" /></head>
<body>
<h1><a href="../">Perl Advent Calendar %d-12</a>-%02d</h1>
<h2 align="center">%s</h2>
<h3 align="center">by %s</h3>
EOF
    print $data{body};
</html>
  }elsif( $element_name eq 'head1' ){
    $parser->add('</h1>');
    $parser->br;
  }elsif( $element_name eq 'head2' ){
    $parser->add('</h2>');
    $parser->br;
  }elsif( $element_name eq 'head3' ){
    $parser->add('</h3>');
    $parser->br;
  }elsif( $element_name eq 'head4' ){
    $parser->add('</h4>');
    $parser->br;
  }elsif( $element_name eq 'Para' ){
    $parser->add('</p>');
    $parser->br;
  }elsif( $element_name eq 'for' && $mode =~ /^quote|eds$/ ){
    $parser->add('</blockquote>');
    $parser->br;
  }elsif( $element_name eq 'for' && $section =~ /^code|codeNNN$/ ){
    my $s;
    $blocks{$section} =~ s/\s+$//;
    Perl::Tidy::perltidy(
        source            => \$blocks{$section},
        destination       => \$s,
        argv              => [qw/-html -pre/, ($section=~/NNN/?'-nnn':()) ],
    );
    $parser->add($s);
    $parser->br;
    $blocks{$section} = '';
    $section = '';
  }elsif( $element_name eq 'for' && $section eq 'pre' ){
    $blocks{$section} =~ s/\s+$//s;
    $parser->add('<pre><span class="c">');
    $parser->add($blocks{$section});
    $parser->add('</span></pre>');
    $parser->br;
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
    $parser->add('</I>');
  }elsif( $element_name eq 'B' ){
    $parser->add('</B>');
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
  }elsif( $mode eq 'Y' ){
    my $s;
    Perl::Tidy::perltidy(
        source            => $text,
        destination       => \$s,
        argv              => [qw/-html -pre -nnn/],
    );
    $out .= $s;
  }elsif( $mode eq 'N' ){
    $out .= sprintf '<sup><a href="#%s">%s</a></sup>', $text, $text;
  }elsif( $mode =~ /^head1/ && $text =~ /^(NAME)$/ ){
    $section = 'title';
  }elsif( $mode =~ /^head1/ && $text =~ /^(AUTHORS?)$/ ){
    $section = 'author';
  }elsif( $mode eq 'sourcedcode' ){
#    $section = $mode;
    die "bad filename $text " unless -r $text;
    $blocks{sourced_file} = $text;
    $out .= sprintf '<a name="%s"></a><h2><a href="%s">%s</a></h2>', ($text)x3;
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
      $parser->add( sprintf('<a href="http://search.cpan.org/search?query=%s">%s</a>',$text,$text) );
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

Version 0.01

=head1 SYNOPSIS

  use Pod::Advent;
  my $pod = shift @ARGV or die "need pod filename";
  my $advent = Pod::Advent->new;
  $advent->parse_file( \*STDIN );

=head1 DESCRIPTION

This module provides a POD formatter that is designed to facilitate the create of submissions for The Perl Advent Calendar (L<http://perladvent.pm.org>) by providing authors with simple markup that will be automatically transformed to full-fill the specific formatting guidelines. This makes it easier for authors to provide calendar-ready submissions, and for the editors to save lots of time in editting submissions.

For example, 'file-, module and program names should be wrapped in <tt>,' and 'the code sample should be appended to the document from the results of a perltidy -nnn -html'. Both of these can be trivially accomplished:

  This entry is for M<Foo::Bar> and the F<scrip.pl> program.

  =sourcedcode mod0.pl

The meta-data of title, date (year & day), and author is now easy to specify as well, and is used to automatically generate the full HTML header (including style) that the calendar entries require before being posted.

=head1 SUPPORTED POD

=head2 Custom Codes

=head3 AE<lt>E<gt>

=head3 ME<lt>E<gt>

=head3 NE<lt>E<gt>

=head2 Custom Directives

=head3 sourcedcode

=head2 Custom Targets

=head3 advent_title

=head3 advent_author

=head3 advent_year

=head3 advent_day

=head3 code

=head3 codeNNN

=head3 pre

=head3 quote

=head3 eds

=head2 Standard Codes

=head3 LE<lt>E<gt>

=head3 FE<lt>E<gt>

=head3 CE<lt>E<gt>

=head3 IE<lt>E<gt>

=head3 BE<lt>E<gt>

=head2 Standard Directives

=head3 headN

=head1 TODO

create test suite

include sample.pod and sample.html

code cleanup (remove the =head1 NAME support, and Y-code support)

code refactoring (package var usage; also maybe make code/directive behavior based on a config data structure)

footnotes

over/item

optional stylesheet

supported pod docs

docs re: html passing through

=head1 METHODS

See L<Pod::Simple> for all of the inherited methods.  Also see L<Pod::Simple::Subclassing> for more information.

=head2 new

Constructor.  See L<Pod::Simple>.

=head1 AUTHOR

David Westbrook, C<< <dwestbrook at gmail.com> >>

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
