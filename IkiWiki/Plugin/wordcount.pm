#!/usr/bin/perl
package IkiWiki::Plugin::wordcount;

use warnings;
use strict;
use IkiWiki 3.00;

sub import {
	hook(type => "getsetup", id => "wordcount", call => \&getsetup);
	hook(type => "preprocess", id => "wordcount", call => \&preprocess);
	hook(type => "sanitize", id => "wordcount", call => \&sanitize);
	hook(type => "pagetemplate", id => "wordcount", call => \&pagetemplate);
	hook(type => "format", id => "wordcount", call => \&format);
}

sub getsetup () {
	return
		plugin => {
			description => "word-count directive",
			safe => 1,
			rebuild => 1,
			section => "meta",
		},
}

sub wordcount {
	my $content=shift;
	return scalar split(/\s+/, $content);
}

my $token='%%%IKIWIKI_PLUGIN_WORDCOUNT%%%';
my $wordcount=0;
my $needed_for_directive=0;
#my $needed_for_template=0;

sub preprocess (@) {
	my %params=@_;
	$needed_for_directive=1;
	return $token;
}

sub sanitize (@) {
	my %params=@_;
	my $content=$params{content};

	my $text_content;
	eval q{
		use HTML::Strip;
		$text_content=HTML::Strip->new()->parse($content);
	};
	$text_content=$content if ($@);

	if ($needed_for_directive) {
		$wordcount=wc($text_content) - wc($token);
		$needed_for_directive=0;
		#debug("wordcount $params{page} for $params{destpage} = $wordcount (by directive)");
		$content =~ s|$token|$wordcount|g;
	}
	else {
		$wordcount=wc($text_content);
		#debug("wordcount $params{page} for $params{destpage} = $wordcount");
	}

	return $content;
}

sub pagetemplate (@) {
	my %params=@_;
	my $template=$params{template};

	if ($template->query(name => "wordcount")) {
		#$needed_for_template=1;
		$template->param(wordcount => $token);
	}
}

sub format (@) {
	my %params=@_;
	my $content=$params{content};
	#return $content unless $needed_for_template;
	#$needed_for_template=0;

	$content =~ s|$token|$wordcount|g;
	return $content;
}

1
