#!/usr/bin/perl

use warnings;
use strict;

use Test::BDD::Cucumber::StepFile;

use Test::WWW::Mechanize;

Given qr/ikiwiki site with the CGI/, sub {
	# Outside the test script, I have:
	# - Installed ikiwiki from pkgsrc
	# - Used it to build my personal wiki (with CGI enabled)
	# - Started bozohttpd on localhost:80 (with CGI enabled)
	# - Configured `libdir` to point at this here checked-out git branch
	# - Configured `add_plugins` to contain my Perl (or whatever) plugin
	#
	# At some point, I'll want these tests to:
	# - Not need (or use) ikiwiki software installed on the system
	# - Not need (or use) an existing wiki instance
	# - Not need (or use) a previously running webserver
	# - Not possibly interfere with regular operation of my real wiki!
	S->{baseurl} = 'http://localhost';
};

Given qr/a browser/, sub {
	S->{browser} = Test::WWW::Mechanize->new();
};

When qr/hits the redirector/, sub {
	S->{browser}->get_ok(S->{baseurl} . '/cgi-bin/ikiwiki?do=redir');
};

Then qr/always redirects to the same site/, sub {
	S->{browser}->base_is('http://www.schmonz.com/');
};
