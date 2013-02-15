#!/usr/bin/perl
# Mark-Jason Dominus's MOD (Modified POD) as used for
# [Higher-Order Perl](http://hop.perl.plover.com/book/)
package IkiWiki::Plugin::mod;

use warnings;
use strict;
use IkiWiki 3.00;
use Encode;

sub import {
	hook(type => "getsetup", id => "mod", call => \&getsetup);
	hook(type => "htmlize", id => "mod", call => \&htmlize, longname => "MOD");
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
	return $content if $@;

	rudely_and_hackily_skip_mathescapes_problems();
	eval q{use Mod::HTML};
	return $content if $@;

	my $driver = Mod::HTML->new('text')
		or die "Couldn't create driver for text: $!; aborting.\n";
	$driver->setparam('startchapter', 1);
	return $driver->do_text($content);
}

sub rudely_and_hackily_skip_mathescapes_problems {
	system("touch mathescapes");
}

1
