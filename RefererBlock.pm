package Apache::RefererBlock;
use strict;
use Apache::Constants qw(:common);
use vars qw($VERSION);

$VERSION = '0.01';

sub handler
{
	my $r = shift;
	my @referers = split /\s+/, $r->dir_config ("AllowedReferers");
	my @types = split /\s+/, $r->dir_config ("CheckMimeTypes");

	# filter only interesting mime types
	return OK unless grep { $r->content_type eq $_ } @types;
	
	# get the referer
	my $hr = $r->header_in("Referer");

	# allow browsers that don't report a referer
	return OK unless $hr;

	# check referer against allowed ones
	foreach my $referer (@referers) {
		return OK if ($hr =~ /^$referer/i);
	}

	# reject non-authorized referers
	$r->log_reason("rejected referer $hr");
	return FORBIDDEN;
}

1;
__END__

=head1 NAME

Apache::RefererBlock - block request based upon referer header

=head1 SYNOPSIS

In the configuration of your Apache add something like

	PerlModule Apache::RefererBlock
	PerlFixupHandler Apache::RefererBlock
	PerlSetVar AllowedReferers "http://www.mydomain.com http://mydomain.com"
	PerlSetVar CheckMimeTypes "image/gif image/jpeg"

=head1 DESCRIPTION

Apache::RefererBlock will examine each request. If the Mime type of the requested file
is one of those listed in CheckMimeTypes, it will check the referer header. If the referer
doesn't start with one of the strings listed in AllowedReferers, a "Forbidden" error will
be returned.

=head1 AUTHOR

Eric Cholet, cholet@logilune.com

=cut
