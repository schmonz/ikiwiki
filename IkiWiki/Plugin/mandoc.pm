#!/usr/bin/perl
package IkiWiki::Plugin::mandoc;

use warnings;
use strict;
use IkiWiki 3.00;
use Encode;
use IPC::Open2;

sub import {
	hook(type => "getsetup", id => "mandoc", call => \&getsetup);
	hook(type => "htmlize", id => $_, call => \&htmlize, keepextension => 1)
		foreach ('man', 1..9);
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

	my $pid = open2(*MANDOCOUT, *MANDOCIN, 'mandoc', '-Thtml');
	binmode($_, ':utf8') foreach (*MANDOCOUT, *MANDOCIN);

	print MANDOCIN $content;
	close MANDOCIN;
	my @html_output = <MANDOCOUT>;
	close MANDOCOUT;
	waitpid $pid, 0;

	my $html = join('', @html_output);
	my $link_prefix = $config{usedirs} ? '../' : '';
	my $link_suffix = $config{usedirs} ? '/' : '';
	$html =~ s|<a class="link-man">(.+?)\((.)\)</a>|<a class="link-man" href="$link_prefix$1.$2$link_suffix">$1($2)</a>|g;

	return $html;
}

1
