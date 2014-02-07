#!/usr/bin/perl
# Nimble markup language
package IkiWiki::Plugin::nimble;

use warnings;
use strict;
use IkiWiki 3.00;
use Encode;

sub import {
	hook(type => "getsetup", id => "nimble", call => \&getsetup);
	hook(type => "htmlize", id => "nbl", call => \&htmlize, longname => "Nimble");
}

sub getsetup () {
	return
		plugin => {
			safe => 1,
			rebuild => 1, # format plugin
			section => "format",
		},
}

sub htmlize (@) {
	my %params=@_;
	my $content = decode_utf8(encode_utf8($params{content}));

	eval q{use Text::Nimble};
	return $content if $@;
	return Text::Nimble::render(html => $content);
}

1
