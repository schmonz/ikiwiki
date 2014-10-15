#!/usr/bin/perl
package IkiWiki::Plugin::urlredirect;

use warnings;
use strict;
use IkiWiki 3.00;

sub import {
	hook(type => "cgi", id => 'urlredirect',  call => \&cgi);
}

sub urlredirect ($) {
	my $q = shift;

	IkiWiki::redirect($q, 'http://www.schmonz.com/');

	exit;
}

sub cgi ($) {
	my $cgi = shift;
	my $do = $cgi->param('do');

	if (defined $do && $do eq 'redir') {
		urlredirect($cgi);
	}
}

1;
