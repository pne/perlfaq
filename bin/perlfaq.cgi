#!/usr/bin/perl -wT
# $Id$

use strict;

=head1 NAME

perlfaq.cgi - html-ify search results of perldoc -q

=head1 SYNOPSIS

	http://faq.perl.org/cgi-bin/perlfaq.cgi?terms=number+commas
	
=head1 DESCRIPTION

This script connects an HTML form to the perldoc command.  The
user specifies the search terms, which perldoc finds in the
perlfaq files.  This script takes the output of perldoc and makes
it presentable on the web with appropriate links and markup.

=head1 TO DO

* better define allowable characters in the search terms

* figure out what to do with bad requests

* munge the output of perldoc to HTML

=head1 BUGS

* none identified

=head1 SEE ALSO

L<perldoc>, L<perlfaq>, http://faq.perl.org, http://www.perldoc.com

=head1 AUTHOR

brian d foy <bdfoy@cpan.org>

=cut

use CGI qw(:cgi -debug);

# specify all commands with absolute paths
$ENV{'PATH'} = '';

my $PERLDOC      = '/usr/bin/perldoc';
my $PERLDOC_OPTS = '-q';

my %links = map { 
	("perlfaq$_", 
	qq|<h2><a href="perlfaq$_.pod">Found in</a></h2>| )
	}
	1 .. 9;

my $terms = param( 'terms' );

# collapse all whitespace to a single space
$terms =~ tr/\n\r\t\f / /s;

# remove bad characters by specifying which ones are good
#
# if this is too restrictive, add more good characters after
# careful thought
$terms =~ tr/a-zA-Z0-9 //cd;

#untaint $terms, or error
if( $terms =~ m/^([a-zA-Z0-9 ]+)$/ )
	{
	$terms = $1;
	}
else
	{
	error();
	exit;
	}

print "Content-type: text/html\n\n";

my $text_result = `$PERLDOC $PERLDOC_OPTS $terms 2> /dev/null`;

# rudimentary HTML munging
$text_result =~ s|^=head1\s+Found in .*/perlfaq(\d)\.pod$|$links{"perlfaq$1"}|mg;
$text_result =~ s|^=head2(.*)|<b>$1</b>|mg;

print $text_result;

sub error
	{
	print <<"ERROR";
Content-type: text/html

Put the error message here 
ERROR
	}
