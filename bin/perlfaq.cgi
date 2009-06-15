#!/usr/bin/perl -wT

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

* we need an output template.  

* better define allowable characters in the search terms

* i haven't paid to much attention to cross reference linking,
but i haven't gotten that far.

* figure out what to do with bad requests

* multiple paragraphs of verbatim text each get their own
<PRE></PRE>.  i'd like to fix that -- perhaps with a second
pass at the data.

=head1 BUGS

* I haven't tested the POD -> HTML stuff very well, so i've probably
missed all sorts of edge cases.

=head1 SEE ALSO

L<perldoc>, L<perlfaq>, http://faq.perl.org, http://www.perldoc.com

=head1 AUTHOR

brian d foy <bdfoy@cpan.org>

=cut

use CGI qw(:cgi -debug);
use IO::Scalar;

# specify all commands with absolute paths
$ENV{'PATH'} = '';

my $PERLDOC      = '/usr/bin/perldoc';
my $PERLDOC_OPTS = '-q';

my %links = map { 
	("perlfaq$_", 
	qq|<h2><a href="perlfaq$_.pod">Found in</a></h2>| )
	}
	1 .. 9;

@links{ qw(srand rand) } = map {
	qq|<a href="$_">$_</a>| } qw(srand rand);
	
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
	error( 'Could not untaint data' );
	}

print "Content-type: text/html\n\n";

# needs error recovery
open my $pipe, "$PERLDOC $PERLDOC_OPTS $terms 2> /dev/null |"
	or error( "Could not open pipe to perldoc: $!\n" );

my $parser = MyParser->new();
error( "Not a parser!" ) unless $parser->isa('Pod::Parser');

my $text_result = '';
my $output = IO::Scalar->new( \$text_result );

$parser->parse_from_filehandle( $pipe, $output );

print $text_result;

sub error
	{
	my $message = shift;
	
	print <<"ERROR";
Content-type: text/html

$message 
ERROR

	exit;
	}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
BEGIN {
package MyParser;
use Pod::Parser;
use HTML::Entities;

use base qw(Pod::Parser);

sub _trim { $_[0] =~ s/\s+$// };
sub _htmlify { HTML::Entities::encode_entities( $_[0] ) }

sub interpolate_and_encode
	{
    my($self, $text, $line_num) = @_;
    my %parse_opts = ( -expand_seq => 'interior_sequence',
    	-expand_text => sub { my $self = shift;
    	HTML::Entities::encode_entities( shift ) } );
    my $ptree = $self->parse_text( \%parse_opts, $text, $line_num );
    return  join "", $ptree->children();
	}
	
sub command 
	{ 
	my( $parser, $command, $paragraph, $line_num ) = @_;

	_trim( $paragraph );
	_htmlify( $paragraph );
		
	my $expansion = '';
	
	if( $command =~ m/head(\d)/)
		{ 
		my $num = $1 + 1;
		$expansion = "<h$num>" .  
			$parser->interpolate_and_encode($paragraph, $line_num) . 
			"</h$num>\n\n";
		}
	
	my $out_fh = $parser->output_handle();
	
	print $out_fh $expansion;
	}


sub verbatim 
	{ 
	my( $parser, $paragraph, $line_num ) = @_;

	_trim( $paragraph );
	_htmlify( $paragraph );
		
	my $out_fh = $parser->output_handle();

	print $out_fh "<pre>\n$paragraph\n</pre>\n\n";
	}


sub textblock 
	{ 
	my( $parser, $paragraph, $line_num ) = @_;

	_trim( $paragraph );
		
	my $out_fh = $parser->output_handle();
	my $expansion = $parser->interpolate_and_encode($paragraph, $line_num);
	print $out_fh "<p>\n$expansion\n</p>\n\n";
	}


sub interior_sequence 
	{ 
	my( $parser, $command, $argument ) = @_;

	_trim( $argument );
	_htmlify( $argument );
		
	my $out_fh = $parser->output_handle();

	return "<b>$argument</b>"                     if ($command eq 'B');
	return "<code>$argument</code>"               if ($command eq 'C');
	return "<i>$argument</i>"                     if ($command eq 'I');
	return qq|<a href="$argument">$argument</a>|  if ($command eq 'L');
	}
}
