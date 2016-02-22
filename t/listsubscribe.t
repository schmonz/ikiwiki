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

sub can_error_on_preprocessing_unknown_list {
	my $output = eval {
		IkiWiki::Plugin::listsubscribe::preprocess(
			listname => 'list_the_zeroth',
		);
	};
	my $error = $@;
	is($output, undef);
	isnt($error, q{});
}

sub can_preprocess_known_list {
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
can_error_on_preprocessing_unknown_list();
can_preprocess_known_list();
done_testing();
