#!/usr/bin/perl
use warnings;
use strict;
use Cwd qw(getcwd);
use Test::More;

my $installed = $ENV{INSTALLED_TESTS};

my @command;
if ($installed) {
	@command = qw(ikiwiki);
}
else {
	ok(! system("make -s ikiwiki.out"));
	@command = ("perl", "-I".getcwd, qw(./ikiwiki.out
		--underlaydir=underlays/basewiki
		--set underlaydirbase=underlays
		--templatedir=templates));
}

ok(! system("rm -rf t/tmp t/tinyblog/.ikiwiki"));
ok(! system("mkdir t/tmp"));
ok(! system(@command, qw(--plugin inline --url=http://example.com
		--cgiurl=http://example.com/ikiwiki.cgi --rss --atom
		t/tinyblog t/tmp/out)));
# This guid should never, ever change, for any reason whatsoever!
my $guid="http://example.com/post/";
ok(length `egrep '<guid.*>$guid</guid>' t/tmp/out/index.rss`);
ok(length `egrep '<id>$guid</id>' t/tmp/out/index.atom`);

done_testing();
