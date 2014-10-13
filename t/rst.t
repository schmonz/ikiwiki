#!/usr/bin/perl
use warnings;
use strict;

use Test::More;

require 't/rst_missing_modules.t';

if (are_all_needed_python_modules_present()) {
	plan tests => 3;
} else {
	plan skip_all => 'not all needed modules are present';
}

can_load_plugin('rst');

like(IkiWiki::htmlize("foo", "foo", "rst", "foo\n"), qr{\s*<p>foo</p>\s*});
# regression test for [[bugs/rst fails on file containing only a number]]
my $html = IkiWiki::htmlize("foo", "foo", "rst", "11");
$html =~ s/<[^>]*>//g;
like($html, qr{\s*11\s*});
