#!/usr/bin/perl
package IkiWiki::Plugin::listsubscribe;

use warnings;
use strict;

use IkiWiki;
use IkiWiki::CGI;

sub import {
	hook(type => "getsetup", id => "listsubscribe", call => \&getsetup);
	hook(type => "preprocess", id => "listsubscribe", call => \&preprocess);
	hook(type => "cgi", id => "listsubscribe", call => \&cgi);
}

sub getsetup () {
	return
		plugin => {
			safe => 1,
			rebuild => 1,
			section => "web",
		},
		listsubscribe => {
			type => "string",
			description => "list names and subscription addresses",
			safe => 1,
			rebuild => 1,
		},
}

sub preprocess (@) {
	my %params = @_;
	my $listname = $params{listname};

	defined $listname
		or error(gettext("list not specified"));
	defined $config{listsubscribe}{$listname}
		or error(sprintf(gettext("list %s not available"), $listname));
	length $config{cgiurl}
		or error(gettext("cgi disabled, not creating form"));

	my $list_subscribe_form = template('listsubscribeform.tmpl');
	$list_subscribe_form->param(listsubscribeaction => IkiWiki::cgiurl());
	$list_subscribe_form->param(listsubscribelistname => $listname);
	$list_subscribe_form->param(html5 => $config{html5});
	return $list_subscribe_form->output;
}

sub cgi ($) {
	my $cgi = shift;
	return unless $cgi->param('do') eq 'listsubscribe';

	eval q{use Mail::Sendmail};
	error($@) if $@;
	sendmail(message_from_form($cgi))
		or error(sprintf(gettext("failed to send mail: %s"),
			$Mail::Sendmail::error));
	print response_page($cgi);
	exit 0;
}

sub message_from_form {
	my $cgi = shift;

	my $from	= $cgi->param('listsubscribeaddress')
		or error(gettext("no email address given"));
	my $listname	= $cgi->param('listsubscribelistname')
		or error(gettext("list not specified"));
	my $to		= $config{listsubscribe}{$listname}
		or error(sprintf(gettext("listname %s not available"), $listname));

	return (
		From	=> $from,
		To	=> $to,
		Subject	=> "subscription request",
		Message	=> q{},
	);
}

sub response_page {
	my $cgi = shift;

	return "Content-Type: text/html\n\n" . IkiWiki::cgitemplate(
		$cgi,
		"Subscription request",
		"Request submitted."
		. " When you receive the confirmation email,"
		. " follow the instructions to complete your subscription.\n",
	);
}

1;
