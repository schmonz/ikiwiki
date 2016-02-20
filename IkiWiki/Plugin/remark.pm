#!/usr/bin/perl
package IkiWiki::Plugin::remark;

use warnings;
use strict;

use IkiWiki 3.00;

sub import {
	add_underlay("remark");
	hook(type => "filter", id => "remark", call => \&filter);
	hook(type => "htmlize", id => "remark", call => \&htmlize, longname => "Remark.js slides");
	hook(type => "sanitize", id => "remark", call => \&sanitize, last => 1);
	IkiWiki::loadplugin("pagetemplate");
}

sub htmlize (@) {
	my %params=@_;
	return $params{content};
}

sub filter (@) {
	my %params=@_;
	if ($pagesources{$params{page}} =~ /\.remark$/) {
		return
			"[[!pagetemplate template=\"remarkpage.tmpl\"]]"
			. "\n<pre class=\"remark-no-typography\">"
			. "\n$params{content}"
			. "\n</pre>[[!remark-no-typography]]";
	}
	else {
		return $params{content};
	}
}

sub sanitize (@) {
	my %params=@_;
	my $content = $params{content};
	if ($content =~ /<pre class="remark-no-typography">(.*)<\/pre>\[\[!remark-no-typography \]\]/s) {
		$content = $1;
	}

	return $content;
}

1;
