#!/usr/bin/perl -w
use strict;

=head1 NAME

check_urls.pl -- extract and check URLs in text files
	
=head1 SYNOPSIS

check_urls.pl <file list>
	
=head1 DESCRIPTION

This program extracts URLs from the specified text files and
validates the full URL.  The program checks one file at a time,
and one URL at a time.  If the program finds a URL it has 
already checked in the same run, whether or not it found it
in the same file, it does not check it again.

The program attempts to recover from HTTP errors that may
arise from errors in URL extraction.

The program reports of the failures after it checks all of the 
files.

=head1 TO DO

* do something else with redirections.  permanent redirections
should be errors, and temporary ones shouldn't

* make the output template based

=head1 BUGS

* can't handle groups.google.com

=head1 SEE ALSO

Porting/checkURL.pl in the standard distribution (as of 5.7.3)

=head1 AUTHOR

brian d foy <bdfoy@cpan.org>

=cut

use vars qw( %urls %failures );
use HTTP::SimpleLinkChecker;

#HTTP::SimpleLinkChecker::user_agent()->timeout(15);

my $DEBUG   = 0;
my $VERBOSE = 1;
my %Skip = map { $_, 1 } qw(
	http://groups.google.com/groups?group=comp.lang.perl.misc
	);
	
print "ARGV is [@ARGV]\n" if $DEBUG;

foreach my $file ( @ARGV )
	{
	local @ARGV = ( $file );
	my @urls    = ();

	while( <> )
		{				
		push @urls, $2 if m{
			
				([("'])?
					((?:http|ftp)://.*?)
				(\s|\1)
			}xig;
			
		}
		
	$urls{$file} = [ sort keys %{ {map { $_, 1 } @urls} } ];
	}
	
$" = "\n\t";

my @failures;
my %seen = ();
foreach my $key ( sort keys %urls )
	{
	my $redo = 0;
	
	@failures = ();
	
	print "\n======$key\n" if $VERBOSE;

	LINK: foreach my $url ( @{$urls{$key}} )
		{		
		if( exists $Skip{$url} and $VERBOSE )
			{
			print "---\t$url\n\t--->Skipping\n" if $VERBOSE;
			next LINK;
			}
			
		my $code = $seen{$url} || HTTP::SimpleLinkChecker::check_link( $url );
			
		if( $VERBOSE )
			{
			print "$code\t$url\n";
			print "\t---> Saw URL previously\n" if( $DEBUG and $seen{$url} );
			}
		
		if( $code > 299 and not $redo and not $seen{$url} )
			{
			print "\t---> Bad link" if $VERBOSE;
			if( $url =~ m/['"][;,)]*$/ )
				{
				print " (possible code artifact)\n" if $VERBOSE;
				$url =~ s/['"][;,)]*$//;
				$redo = 1;
				redo;
				}
				
			print "\n" if $VERBOSE;
			}
			
		if( $code > 299 )
			{
			push @failures, $url;
			}
			
		$seen{$url} = $code;
		
		$failures{$key} = [ @failures ] if @failures;
		
		$redo = 0;		
		}
	}

print "-" x 73, "\nFAILURE REPORT\n", "-" x 73, "\n" if keys %failures;
	
foreach my $key ( sort keys %failures )
	{
	next unless $failures{$key};
	
	local $" = "\n\t" if $VERBOSE;
	print "\n======$key\n\t@{$failures{$key}}\n" if $VERBOSE;
	}

