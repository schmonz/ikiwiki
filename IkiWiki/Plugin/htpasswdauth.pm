#!/usr/bin/perl
package IkiWiki::Plugin::htpasswdauth;

use warnings;
use strict;
use IkiWiki 3.00;

sub import {
	hook(type => "checkconfig", id => "htpasswdauth", call => \&checkconfig);
	hook(type => "getsetup", id => "htpasswdauth", call => \&getsetup);
	hook(type => "auth", id => "htpasswdauth", call => \&auth);
	hook(type => "formbuilder_setup", id => "htpasswdauth",
		call => \&formbuilder_setup);
}

sub checkconfig () {
	if (! defined $config{htpasswdauth_baseurl}) {
		$config{htpasswdauth_baseurl} = 'https://wind.columbia.edu/';
	}
	if (! defined $config{htpasswdauth_loginurl}) {
		$config{htpasswdauth_loginurl} = $config{htpasswdauth_baseurl} .
			'login';
	}
	if (! defined $config{htpasswdauth_logouturl}) {
		$config{htpasswdauth_logouturl} = $config{htpasswdauth_baseurl} .
			'logout';
	}
	if (! defined $config{htpasswdauth_validateurl}) {
		$config{htpasswdauth_validateurl} = $config{htpasswdauth_baseurl} .
			'validate?ticketid=';
	}
	if (! defined $config{htpasswdauth_whitelist}) {
		$config{htpasswdauth_whitelist} =
			"minister_of_internet_truth/all-users.txt";
	}
}

sub getsetup () {
	return
		plugin => {
			safe => 1,
			rebuild => 0,
			section => "auth",
		},
		wind_baseurl => {
			type => "string",
			example => "https://wind.example.tld/",
			description => "base URL to WIND service",
			safe => 1,
			rebuild => 0,
		},
}

sub auth ($$) {
	my $q = shift;
	my $session = shift;

	return unless $q->param('ticketid');
	my $username = get_username_for_ticket($q->param('ticketid'));
	return unless defined $username;

	error("<b>$username</b> is not a known full Philo. To gain" .
	      " access, talk to the MiniTru.")
		unless is_a_full_philo($username);

	$session->param(name => $username);
}

sub formbuilder_setup (@) {
	my %params = @_;

	my $form = $params{form};
	my $session = $params{session};
	my $cgi = $params{cgi};

	if ($form->title eq "signin") {
		if (scalar keys %{$IkiWiki::hooks{auth}} == -1) {	# XXX
			eval q{use URI::Escape q{uri_escape_utf8};};
			if ($@) {
				debug("unable to load URI::Escape, " .
				      "can't redirect directly to WIND ($@)");
			}
			IkiWiki::redirect($cgi, $config{htpasswdauth_loginurl} .
					  '?destination=' .
					  uri_escape_utf8(IkiWiki::cgiurl(
							  do => "postsignin")));
		}
		else {
			$form->action($config{htpasswdauth_loginurl});
			$form->field(
				name => "destination",
				type => 'hidden',
				value => IkiWiki::cgiurl(do => "postsignin"),
			);
		}
		if ($form->submitted && $form->submitted eq "Logout") {
			$session->delete();
			IkiWiki::redirect($cgi, $config{htpasswdauth_logouturl} .
					  '?destination=' . IkiWiki::cgiurl())
		}
	}

}

sub get_username_for_ticket ($) {
	my $ticket = shift;

	eval q{
		use LWP::Simple 'get';
		use XML::Simple;
	};
	if ($@) {
		debug("unable to load {LWP,XML}::Simple, " .
		      "can't validate WIND tickets ($@)");
		return undef;
	}
	
	my $response = LWP::Simple::get($config{htpasswdauth_validateurl}.$ticket);
	my $ref = XMLin($response);
	if (exists $ref->{'wind:authenticationSuccess'}) {
		return $ref->{'wind:authenticationSuccess'}{'wind:user'};
	}

	return undef;
}

sub is_a_full_philo ($) {
	my $uni = shift;

	# XXX also check local password file, separate auth plugin

	open WHITELIST, srcfile($config{htpasswdauth_whitelist})
		|| error "whitelist not found";
	my $ret = grep(/^$uni$/, <WHITELIST>);
	close WHITELIST;
	return $ret;
}

1;
