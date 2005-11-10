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

The perlfaq is divided into several documents based on topics.  A table
of contents is at the end of this document.

=head2 Where to get the perlfaq

Extracts of the perlfaq are posted regularly to
comp.lang.perl.misc.  It is available on many web sites:
http://www.perldoc.com/ and http://faq.perl.org/

=head2 How to contribute to the perlfaq

You may mail corrections, additions, and suggestions to
perlfaq-workers@perl.org .  This alias should not be used to
I<ask> FAQs.  It's for fixing the current FAQ. Send
questions to the comp.lang.perl.misc newsgroup.  You can
view the source tree at http://cvs.perl.org/cvsweb/perlfaq/
(which is outside of the main Perl source tree).  The CVS
repository notes all changes to the FAQ.

=head2 What will happen if you mail your Perl programming problems to the authors

Your questions will probably go unread, unless they're
suggestions of new questions to add to the FAQ, in which
case they should have gone to the perlfaq-workers@perl.org
instead.

You should have read section 2 of this faq.  There you would
have learned that comp.lang.perl.misc is the appropriate
place to go for free advice.  If your question is really
important and you require a prompt and correct answer, you
should hire a consultant.

=head1 Credits

The original perlfaq was written by Tom Christiansen, then expanded
by collaboration between Tom and Nathan Torkington.  The current
document is maintained by the perlfaq-workers (perlfaq-workers@perl.org).
Several people have contributed answers, corrections, and comments.

=head1 Author and Copyright Information

Copyright (c) 1997-2005 Tom Christiansen, Nathan Torkington, and 
other contributors noted in the answers.

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

=head1 Table of Contents

=over 4

=item perlfaq  - this document

=item perlfaq1 - General Questions About Perl

=item perlfaq2 - Obtaining and Learning about Perl

=item perlfaq3 - Programming Tools

=item perlfaq4 - Data Manipulation

=item perlfaq5 - Files and Formats

=item perlfaq6 - Regular Expressions

=item perlfaq7 - General Perl Language Issues

=item perlfaq8 - System Interaction

=item perlfaq9 - Networking


=back


=head1 The Questions


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
POSTAMBLE
