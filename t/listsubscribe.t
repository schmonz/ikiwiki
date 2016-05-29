#!/usr/bin/perl
use warnings;
use strict;

use Test::More;

use IkiWiki;

BEGIN { use_ok("IkiWiki::Plugin::listsubscribe"); }

sub _startup {
	%config = IkiWiki::defaultconfig();
	$config{srcdir} = 't/tmp';
	$config{templatedir} = 'templates';
	$config{cgiurl} = q{not empty};
	$config{listsubscribe} = {
		list_the_first => 'list-the-first-subscribe@noodles.appendage',
		neato_list => 'foo@bar.baz',
	};
	is(IkiWiki::checkconfig(), 1);
}

sub unknown_list_gives_error {
	my $output = eval {
		IkiWiki::Plugin::listsubscribe::preprocess(
			listname => 'list_the_zeroth',
		);
	};
	my $error = $@;
	is($output, undef);
	isnt($error, q{});
}

sub known_list_gives_something {
	my $output = eval {
		IkiWiki::Plugin::listsubscribe::preprocess(
			listname => 'list_the_first',
		);
	};
	my $error = $@;
	like($output, qr{list_the_first});
	is($error, q{});
}

_startup();
unknown_list_gives_error();
known_list_gives_something();
done_testing();
