#!/usr/bin/perl
#
#$Id: basic.t,v 1.2 2005/03/11 16:20:01 eric Exp $

use strict;
use Test::MockObject;

# Apache::Constants doesn't work offline
BEGIN {
    my %ac = (
        OK        => 0,
        REDIRECT  => 302,
        FORBIDDEN => 403,
    );
    {
        require Exporter;
        $INC{'Apache/Constants'} = 1;
        @Apache::Constants::ISA = 'Exporter';
        @Apache::Constants::EXPORT = keys %ac;
        while (my ($k, $v) = each %ac) {
            no strict 'refs';
            *{"Apache::Constants::$k"} = sub { $v };
        }
        Apache::Constants->import;
    }
}
my @tests = (
    { cfg     => { types => [qw(image/gif image/jpeg)] },
      referer => '',
      ctype   => 'text/html',
      status  => OK,
    },
    { cfg     => { types => [qw(image/gif image/jpeg)] },
      referer => '',
      ctype   => 'image/gif',
      status  => OK,
    },
    { cfg     => { types => [qw(image/gif image/jpeg)] },
      referer => 'http://example.com/',
      ctype   => 'image/gif',
      status  => FORBIDDEN,
    },
    { cfg     => { types => [qw(image/gif image/jpeg)], referers => [ 'http://example.com/' ] },
      referer => 'http://example.com/foo',
      ctype   => 'image/gif',
      status  => OK,
    },
    { cfg     => { types => [qw(image/gif image/jpeg)], referers => [ 'http://example.com/' ] },
      referer => 'http://example.org/foo',
      ctype   => 'image/gif',
      status  => FORBIDDEN,
    },
    { cfg     => { types => [qw(image/gif image/jpeg)], redir => { 'http://example.com/' => 'http://example.org/bar' } },
      referer => 'http://example.com/foo',
      ctype   => 'image/gif',
      status  => REDIRECT,
      location => 'http://example.org/bar',
    },
    { cfg     => { types => [qw(image/gif image/jpeg)], redir => { 'http://example.com/' => 'http://example.org/bar' } },
      referer => 'http://example.org/foo',
      ctype   => 'image/gif',
      status  => FORBIDDEN,
    },
);
use Test::More;
plan tests => 1 + scalar(@tests) + scalar(grep $_->{location}, @tests);

# fake some context
our $context;
my $headers_out = Test::MockObject->new;
$headers_out->mock(set => sub { $context->{redirected} = $_[2] });

my $r = Test::MockObject->new;
$r->mock(content_type  => sub { $context->{ctype} })
  ->mock(header_in     => sub { $context->{referer} })
  ->set_always(headers_out => $headers_out);

Test::MockObject->fake_module('Apache::ModuleConfig',
    get => sub { return $context->{cfg} },
);

use_ok('Apache::RefererBlock');

for $context (@tests) {
    $context->{redirected} = '';
    is(Apache::RefererBlock::handler($r), $context->{status});
    is($context->{redirected}, $context->{location}) if $context->{location};
}
