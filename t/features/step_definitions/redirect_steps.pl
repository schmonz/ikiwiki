#!/usr/bin/perl

use warnings;
use strict;

use Test::BDD::Cucumber::StepFile;

use Test::WWW::Mechanize;

Given qr/ikiwiki site with the CGI/, sub {
	S->{baseurl} = 'http://localhost:3000';
};

Given qr/a browser/, sub {
	S->{browser} = Test::WWW::Mechanize->new();
};

When qr/hits the redirector/, sub {
	S->{browser}->get_ok(S->{baseurl} . '/cgi-bin/ikiwiki?redir=1');
};

Then qr/always redirects to the same site/, sub {
	S->{browser}->base_is('http://www.schmonz.com/');
};
