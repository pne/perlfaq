#!/usr/bin/perl -w
# $Id$
use strict;

=head1 NAME

perlfaq_toc.pl -- create perlfaq.pod from /perlfaq\d.pod/

=head1 SYNOPSIS

in the same directory as the /perlfaq\d.pod/ files:

	perlfaq_toc.pod > perlfaq.pod

=head1 DESCRIPTION

The perlfaq.pod file is a table of contents of the various
perlfaq files, and has previously been maintained separately.
It should be able to be created from the other files, and this
is my first attempt at that.

=head1 TO DO

* move the pre- and post- amble to templates

* the POD parsing is rather simple-minded and can be improved

=head1 BUGS

* it can't handle question titles that appear on multiple lines
in the perlfaq pod.

=head1 AUTHOR

brian d foy <bdfoy@cpan.org>

=cut

$/ = undef;

my @files = map { "perlfaq$_.pod" } 1 .. 9;

print <<'PREAMBLE';
=head1 NAME

perlfaq - frequently asked questions about Perl ($Date$)

=head1 DESCRIPTION

The perlfaq is structured into the following documents:


=head2 perlfaq: Structural overview of the FAQ.

This document.

PREAMBLE

foreach my $file ( @files )
	{
	open FILE, $file or die "Could not open $file: $!";
	$_ = <FILE>;
	close FILE;

	my( $title, $short ) = m/=head1 NAME\s+(perlfaq\d)\s+-\s+(.*?)\s+\(\$R/;
	print "=head2 L<$title>: $short\n\n";

	my( $d ) = m/^=head1 DESCRIPTION\s+(.*?)\s+=head[12]/sm;
	$d =~ s/This section(?: of the FAQ)? (?:answers|deals with)(?: questions (?:about|related to))?(?: the)? //;
	$d =~ s/\s+/ /g;
	$d = ucfirst $d;

	print "$d\n\n=over 4\n\n";

	foreach my $q ( m/^=head2\s+(.*)$/mg )
		{
		print "=item *\n\n$q\n\n";
		}

	print "=back\n\n\n";
	}

print <<'POSTAMBLE';
=head1 About the perlfaq documents

=head2 Where to get the perlfaq

This document is posted regularly to comp.lang.perl.announce and
several other related newsgroups.  It is available on many
web sites: http://www.perldoc.com/ and http://perlfaq.cpan.org/ .

=head2 How to contribute to the perlfaq

You may mail corrections, additions, and suggestions to
perlfaq-workers@perl.org .  This alias should not be 
used to I<ask> FAQs.  It's for fixing the current FAQ.
Send questions to the comp.lang.perl.misc newsgroup.

=head2 What will happen if you mail your Perl programming problems to the authors

Your questions will probably go unread, unless they're suggestions of
new questions to add to the FAQ, in which case they should have gone
to the perlfaq-workers@perl.org instead.

You should have read section 2 of this faq.  There you would have
learned that comp.lang.perl.misc is the appropriate place to go for
free advice.  If your question is really important and you require a
prompt and correct answer, you should hire a consultant.

=head1 Credits

When I first began the Perl FAQ in the late 80s, I never realized it
would have grown to over a hundred pages, nor that Perl would ever become
so popular and widespread.  This document could not have been written
without the tremendous help provided by Larry Wall and the rest of the
Perl Porters.

=head1 Author and Copyright Information

Copyright (c) 1997-2002 Tom Christiansen and Nathan Torkington.
All rights reserved.

=head2 Bundled Distributions

This documentation is free; you can redistribute it and/or modify it
under the same terms as Perl itself.

Irrespective of its distribution, all code examples in these files
are hereby placed into the public domain.  You are permitted and
encouraged to use this code in your own programs for fun
or for profit as you see fit.  A simple comment in the code giving
credit would be courteous but is not required.

=head2 Disclaimer

This information is offered in good faith and in the hope that it may
be of use, but is not guaranteed to be correct, up to date, or suitable
for any particular purpose whatsoever.  The authors accept no liability
in respect of this information or its use.

=head1 Changes

=over 4

=item 1/November/2000

A few grammatical fixes and updates implemented by John Borwick.

=item 23/May/99

Extensive updates from the net in preparation for 5.6 release.

=item 13/April/99

More minor touch-ups.  Added new question at the end
of perlfaq7 on variable names within variables.

=item 7/January/99

Small touch ups here and there.  Added all questions in this 
document as a sort of table of contents.

=item 22/June/98

Significant changes throughout in preparation for the 5.005
release.

=item 24/April/97

Style and whitespace changes from Chip, new question on reading one
character at a time from a terminal using POSIX from Tom.

=item 23/April/97

Added http://www.oasis.leo.org/perl/ to L<perlfaq2>.  Style fix to
L<perlfaq3>.  Added floating point precision, fixed complex number
arithmetic, cross-references, caveat for Text::Wrap, alternative
answer for initial capitalizing, fixed incorrect regexp, added example
of Tie::IxHash to L<perlfaq4>.  Added example of passing and storing
filehandles, added commify to L<perlfaq5>.  Restored variable suicide,
and added mass commenting to L<perlfaq7>.  Added Net::Telnet, fixed
backticks, added reader/writer pair to telnet question, added FindBin,
grouped module questions together in L<perlfaq8>.  Expanded caveats
for the simple URL extractor, gave LWP example, added CGI security
question, expanded on the mail address answer in L<perlfaq9>.

=item 25/March/97

Added more info to the binary distribution section of L<perlfaq2>.
Added Net::Telnet to L<perlfaq6>.  Fixed typos in L<perlfaq8>.  Added
mail sending example to L<perlfaq9>.  Added Merlyn's columns to
L<perlfaq2>.

=item 18/March/97

Added the DATE to the NAME section, indicating which sections have
changed.

Mentioned SIGPIPE and L<perlipc> in the forking open answer in
L<perlfaq8>.

Fixed description of a regular expression in L<perlfaq4>.

=item 17/March/97 Version

Various typos fixed throughout.

Added new question on Perl BNF on L<perlfaq7>.

=item Initial Release: 11/March/97

This is the initial release of version 3 of the FAQ; consequently there
have been no changes since its initial release.

=back
POSTAMBLE
