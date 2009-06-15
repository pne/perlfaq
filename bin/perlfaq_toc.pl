#!/usr/bin/perl -w
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

perlfaq - frequently asked questions about Perl

=head1 DESCRIPTION

The perlfaq comprises several documents that answer the most commonly
asked questions about Perl and Perl programming. It's divided by topic
into nine major sections outlined in this document.

=head2 Where to get the perlfaq

The perlfaq comes with the standard Perl distribution, so if you have Perl
you should have the perlfaq. You should also have the C<perldoc> tool
that let's you read the L<perlfaq>:

	$ perldoc perlfaq

Besides your local system, you can find the perlfaq on the web, including
at http://perldoc.perl.org/ .

The perlfaq is an evolving document and you can read the latest version
at http://faq.perl.org/ . The perlfaq-workers periodically post extracts
of the latest perlfaq to comp.lang.perl.misc.

You can view the source tree at
https://svn.perl.org/modules/perlfaq/trunk/ (which is outside of the
main Perl source tree).  The SVN repository notes all changes to the FAQ
and holds the latest version of the working documents and may vary
significantly from the version distributed with the latest version of
Perl. Check the repository before sending your corrections.

=head2 How to contribute to the perlfaq

You can mail corrections, additions, and suggestions to
C<< <perlfaq-workers AT perl DOT org> >>. The perlfaq volunteers use this
address to coordinate their efforts and track the perlfaq development.
They appreciate your contributions to the FAQ but do not have time to
provide individual help, so don't use this address to ask FAQs.

The perlfaq server posts extracts of the perlfaq to that newsgroup every
6 hours (or so), and the community of volunteers reviews and updates the
answers. If you'd like to help review and update the answers, check out
comp.lang.perl.misc.

=head2 What will happen if you mail your Perl programming problems to the authors?

The perlfaq-workers like to keep all traffic on the perlfaq-workers list
so that everyone can see the work being done (and the work that needs to
be done). The mailing list serves as an official record. If you email the
authors or maintainers directly, you'll probably get a reply asking you
to post to the mailing list. If you don't get a reply, it probably means
that the person never saw the message or didn't have time to deal with
it. Posting to the list allows the volunteers with time to deal with it
when others are busy.

If you have a question that isn't in the FAQ and you would like help with
it, try the resources in L<perlfaq2>.

=head1 CREDITS

Tom Christiansen wrote the original perlfaq then expanded it with the
help of Nat Torkington.  The perlfaq-workers maintain current document
and the dezinens of comp.lang.perl.misc regularly review and update the
FAQ. Several people have contributed answers, corrections, and comments,
and the perlfaq notes those contributions wherever appropriate.

=head1 AUTHOR AND COPYRIGHT

Tom Christainsen wrote the original version of this document.
brian d foy C<< <bdfoy@cpan.org> >> wrote this version. See the
individual perlfaq documents for additional copyright information.

This document is available under the same terms as Perl itself. Code
examples in all the perlfaq documents are in the public domain. Use
them as you see fit (and at your own risk with no warranty from anyone).

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
