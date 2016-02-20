#!/usr/bin/perl
use warnings;
use strict;

use Test::More;

use IkiWiki;

my $installed = $ENV{INSTALLED_TESTS};

my @command;
if ($installed) {
	@command = qw(ikiwiki);
}
else {
	ok(! system("make -s ikiwiki.out"));
	@command = qw(perl -I. ./ikiwiki.out
		--plugin=remark
		--underlaydir=underlays/basewiki
		--set underlaydirbase=underlays
		--templatedir=templates);
}

my $tmp = 't/tmp';
my $srcdir = "$tmp/in";
my $destdir = "$tmp/out";

sub can_htmlize {
	ok(! system("rm -rf $tmp"));
	ok(! system("mkdir $tmp"));

	writefile("slides.remark", $srcdir, "I'm Markdown slides");
	ok(! system(@command, $srcdir, $destdir));

	my $contents = eval {
		readfile("$destdir/slides/index.html");
	};
	if ($@) {
		fail("did not htmlize .remark");
	} else {
		like($contents, qr{<title>});
	}
}

sub can_htmlize_using_template {
	ok(! system("rm -rf $tmp"));
	ok(! system("mkdir $tmp"));

	writefile("slides.remark", $srcdir, "I'm Markdown slides");
	writefile("ordinary.mdwn", $srcdir, "I'm an ordinary page");
	ok(! system(@command, $srcdir, $destdir));

	my $telltale = qr{var slideshow = remark\.create\(\);};
	like(readfile("$destdir/slides/index.html"), $telltale);
	unlike(readfile("$destdir/ordinary/index.html"), $telltale);
}

sub can_htmlize_while_selectively_disabling_typography {
	ok(! system("rm -rf $tmp"));
	ok(! system("mkdir $tmp"));

	writefile("slides.remark", $srcdir, "# Slide 1\n---\n# Slide 2\n- [[Ordinary]]");
	writefile("ordinary.mdwn", $srcdir, "I'm an ordinary page");
	ok(! system(@command, "--plugin=typography", $srcdir, $destdir));

	unlike(readfile("$destdir/slides/index.html"), qr{remark-no-typography});
	like(readfile("$destdir/slides/index.html"), qr{\n---\n});
	like(readfile("$destdir/ordinary/index.html"), qr{I&#8217;m an});
}

can_htmlize();
can_htmlize_using_template();
can_htmlize_while_selectively_disabling_typography();
done_testing();
