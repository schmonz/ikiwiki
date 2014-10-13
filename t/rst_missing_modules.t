#!/usr/bin/perl
use warnings;
use strict;

use Test::More;

use IkiWiki;

sub are_all_needed_python_modules_present {
	return (0 == system("python -c 'import docutils.core' 2>/dev/null"));
}

sub can_load_plugin {
	my $plugin_name = shift;
	%config=IkiWiki::defaultconfig();
	$config{srcdir}=$config{destdir}="/dev/null";
	$config{libdir}=".";
	$config{add_plugins}=[$plugin_name]
		if defined $plugin_name;
	eval q{IkiWiki::loadplugins()};
	if ($@) {
		my $err = $@;
		fail("can't load: $err");
	} else {
		pass("can load");
	}
	IkiWiki::checkconfig();
}

sub main {
	if (are_all_needed_python_modules_present()) {
		plan skip_all => 'no needed modules are missing';
	} else {
		plan tests => 2;
	}

	can_load_plugin();
	can_load_plugin('rst');
}

main(@ARGV) unless caller();
