package Apache::RefererBlock;
use strict;
use Apache::ModuleConfig ();
use DynaLoader ();
use Apache::Constants qw(REDIRECT OK FORBIDDEN);
use vars qw($VERSION);

$VERSION = '0.04';

if ($ENV{MOD_PERL}) {
	no strict;
	@ISA = qw(DynaLoader);
	__PACKAGE__->bootstrap($VERSION);
}

sub RefBlockDebug ($$$) {
	my ($cfg, $parms, $flag) = @_;
	$cfg->{debug} = $flag;
}
sub RefBlockMimeTypes ($$@) {
	my ($cfg, $parms, $type) = @_;
	push @{ $cfg->{types} }, $type;
}
sub RefBlockAllowed ($$@) {
	my ($cfg, $parms, $url) = @_;
	push @{ $cfg->{referers} }, $url;
}
sub RefBlockRedirect ($$$$) {
	my ($cfg, $parms, $referer, $url) = @_;
	$cfg->{redir}{$referer} = $url;
}

sub handler {
	my $r = shift;
	my $debug = 0;
	my @referers = ();
	my @types = ();
	my %redir = ();
	if (my $cfg = Apache::ModuleConfig->get($r)) {
		$debug = $cfg->{debug} if $cfg->{debug};
		@types = @{ $cfg->{types} } if $cfg->{types};
		@referers = @{ $cfg->{referers} } if $cfg->{referers};
		%redir = %{ $cfg->{redir} } if $cfg->{redir};
	}
	# filter only interesting mime types
	return OK unless grep { $r->content_type eq $_ } @types;
	
	# get the referer
	my $hr = $r->header_in("Referer");

	# allow browsers that don't report a referer
	return OK unless $hr;

	# check referer against allowed ones
	foreach my $referer (@referers) {
		return OK if $hr =~ /^\Q$referer\E/i;
	}

	# redirect or reject non-authorized referers
	foreach my $referer (keys %redir) {
		if ($hr =~ /^\Q$referer\E/i) {
			$r->headers_out->set(Location => "$redir{$referer}");
			$r->log_reason("referer redirected: $hr") if $debug;
			return REDIRECT;
		}
	}
	$r->log_reason("referer rejected: $hr") if $debug;
	return FORBIDDEN;
}

1;
__END__

=head1 NAME

Apache::RefererBlock - block request based upon referer header

=head1 SYNOPSIS

In your Apache configuration file, add something like

	PerlModule Apache::RefererBlock
	PerlFixupHandler Apache::RefererBlock
	RefBlockMimeTypes image/gif image/jpeg
	RefBlockAllowed http://www.mydomaine.com http://mydomaine.com
	RefBlockRedirect http://www.badguyse.com http://www.badguyse.com/images/bigpicture.gif
	RefBlockRedirect http://www.realbadguyse.com http://www.xxx.xxx/samples/tts.jpg
	RefBlockDebug On

All directives are optional.

=head1 DESCRIPTION

Apache::RefererBlock will examine each request. If the MIME type of the requested file
is one of those listed in RefBlockMimeTypes, it will check the request's "Referer" header.
If the referrer starts with one of the strings listed in RefBlockAllowed, access is granted.
Otherwise, if there's a RefBlockRedirect directive for the referrer, a redirect is issued.
Otherwise, a "Forbidden" (403) error is returned.

Requests with an empty Referer header will be granted, to accomodate old browsers.

=head1 AVAILABILITY

The latest version can be fetched from <http://www.logilune.com/eric/RefererBlock.html>.

=head1 AUTHOR

Eric Cholet, <cholet@logilune.com>

=head1 COPYRIGHT

Copyright (c) 1998 Eric Cholet.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
