#!/usr/bin/perl

package IkiWiki::Plugin::netbsdextrasetup;

use warnings;
use strict;
use IkiWiki;

sub import {
	hook(type => "checkconfig", id => "netbsdextrasetup",
		call => \&checkconfig);
}

sub checkconfig {
	if (!defined $config{openid_whitelist}) {
		error("netbsdextrasetup: openid_whitelist not defined");
	}
	$config{locked_pages} = 'ikiwiki or ikiwiki/*' . eval {
		my $nonefound = ' or user(*://*)';
		open(WL, $config{openid_whitelist}) || return $nonefound;
		my $lp = '';
		while(<WL>) {
			chomp;
			next if (/^#/);
			my @fields = split(/\t/);
			next if (4 != @fields);
			my $openid = $fields[3];
			next unless ($openid =~ /.*:\/\/.*/);
			$lp .= "user($openid) or ";
		}
		if ($lp eq '') {
			return $nonefound;
		} else {
			$lp = ' or (user(*://*) and !(' . $lp;
			$lp =~ s/ or $/))/;
		}
		return $lp;
	};
}

1
