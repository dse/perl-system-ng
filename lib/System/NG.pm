package System::NG;
require v5.10;
use feature qw(switch);

@EXPORT = qw(system_ng);

# usage: 
#   system_ng("ls -l");
#   system_ng([">/dev/null", "2>/dev/null"], "ls -l");
sub system_ng {
	my $bg, $in, $out, $err;
	my $process = sub {
		my $arg = shift();
		given ($arg) {
			when (/^\s*>\s*/)  { $out = $'; }
			when (/^\s*<\s*/)  { $in  = $'; }
			when (/^\s*2>\s*/) { $err = $'; }
			when ("&")         { $bg  = 1;  }
		}
	};
	while (scalar(@_) && ref($_[0])) {
		my $ref = shift();
		if ($ref eq "SCALAR") {
			&$process($$ref);
		}
		elsif ($ref eq "ARRAY") {
			foreach my $arg (@$ref) {
				&$process($arg);
			}
		}
	}
	my $pid = fork();
	if ($pid) {
		if (!$bg) {
			if (waitpid($pid) == -1) {
				warn("no such child process\n");
			}
			return $?;
		}
	}
	elsif (defined $pid) {
		given ($in) {
			when ("/dev/null") { close(STDIN); }
			when (defined) { open(STDIN, "<", $in) or die $!; }
		}
		given ($out) {
			when ("/dev/null") { close(STDOUT); }
			when (defined) { open(STDOUT, ">", $out) or die $!; }
		}
		given ($err) {
			when ("/dev/null") { close(STDERR); }
			when (defined) { open(STDERR, ">", $err) or die $!; }
		}
		exec(@args);
	}
	else {
		warn("fork unsuccessful\n");
	}
}

1;
