#!/usr/bin/perl

use RPC::XML;
use IO::Handle;

# autoflush stdout
$|=1;

# Used to build up RPC calls as they're read from stdin.
my $accum="";

sub rpc_read {
	# Read stdin, a line at a time, until a whole RPC call is accumulated.
	# Parse to XML::RPC object and return.
	while (<>) {
		$accum.=$_;

		# Kinda hackish approach to parse a single XML RPC out of the
		# accumulated input. Perl's RPC::XML library doesn't
		# provide a better way to do it. Relies on calls always ending
		# with a newline, which ikiwiki's protocol requires be true.
		if ($accum =~ /^\s*(<\?xml\s.*?<\/(?:methodCall|methodResponse)>)\n(.*)/s) {
			$accum=$2; # the rest
	
			# Now parse the XML RPC.
			my $parser;
			eval q{
				use RPC::XML::ParserFactory;
				$parser = RPC::XML::ParserFactory->new;
			};
			if ($@) {
				# old interface
				eval q{
					use RPC::XML::Parser;
					$parser = RPC::XML::Parser->new;
				};
			}
			my $r=$parser->parse($1);
			if (! ref $r) {
				die "error: XML RPC parse failure $r";
			}
			return $r;
		}
	}

	return undef;
}

sub rpc_handle {
	# Handle an incoming XML RPC command.
	my $r=rpc_read();
	if (! defined $r) {
		return 0;
	}
	if ($r->isa("RPC::XML::request")) {
		my $name=$r->name;
		my @args=map { $_->value } @{$r->args};
		# Dispatch the requested function. This could be
		# done with a switch statement on the name, or
		# whatever. I'll use eval to call the function with
		# the name.
		my $ret = eval $name.'(@args)';
		die $@ if $@;
	
		# Now send the repsonse from the function back,
		# followed by a newline.
		my $resp=RPC::XML::response->new($ret);
		$resp->serialize(\*STDOUT);
		print "\n";
		# stdout needs to be flushed here. If it isn't,
		# things will deadlock. Perl flushes it
		# automatically when $| is set.
		return 1;
	}
	elsif ($r->isa("RPC::XML::response")) {
		die "protocol error; got a response when expecting a request";
	}
}

sub rpc_call {
	# Make an XML RPC call and return the result.
	my $command=shift;
	my @params=@_;

	my $req=RPC::XML::request->new($command, @params);
	$req->serialize(\*STDOUT);
	print "\n";
	# stdout needs to be flushed here to prevent deadlock. Perl does it
	# automatically when $| is set.
	
	my $r=rpc_read();
	if ($r->isa("RPC::XML::response")) {
		return $r->value->value;
	}
	else {
		die "protocol error; got a request when expecting a response";
	}
}

while (rpc_handle()) {;}

1;
