#!/usr/bin/perl
package IkiWiki::Plugin::piggyauth;

use warnings;
use strict;
use IkiWiki 3.00;

sub import {
	hook(type => "getsetup", id => "piggyauth", call => \&getsetup);
	hook(type => "auth", id => "piggyauth", call => \&auth);
}

sub getsetup () {
	return
		plugin => {
			safe => 1,
			rebuild => 0,
			section => "auth",
		},
}

sub is_a_full_philo ($) {
	my $cuid = shift;

	# XXX check whitelist
	# XXX what about my local password file? separate auth plugin
	return 1;

	return undef;
}

sub auth ($$) {
	my ($q, $session) = @_;

	return unless $q->param('user');
	# XXX return unless the referrer checks out
	# anything else in the Columbia session we can check for?
	my $username = $q->param('user');
	return unless defined $username;

	$session->param(name => $username) if is_a_full_philo($username);
}

1;
