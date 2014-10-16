#!/usr/bin/perl
package IkiWiki::Plugin::urlredirect_perl_native;

use warnings;
use strict;
use IkiWiki 3.00;

sub import {
	hook(type => "cgi", id => 'urlredirect_perl_native', call => \&cgi);
}

sub urlredirect_perl_native ($) {
	my $q = shift;

	IkiWiki::redirect($q, 'http://www.schmonz.com/');

	exit;
}

sub cgi ($) {
	my $cgi = shift;
	my $do = $cgi->param('do');

	if (defined $do && $do eq 'redir') {
		urlredirect_perl_native($cgi);
	}
}

1;
