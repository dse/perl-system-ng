package System::NG;
require v5.10;
use feature qw(switch);
use Exporter;

our $VERSION = "0.01";
our @ISA       = qw(Exporter);
our @EXPORT    = qw(system_ng);
our @EXPORT_OK = qw(system_ng);

# usage: 
#   system_ng("ls -l");
#   system_ng([">/dev/null", "2>/dev/null"], "ls -l");
sub system_ng {
	my ($bg, $in, $out, $err);
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
		if (ref($ref) eq "SCALAR") {
			&$process($$ref);
		}
		elsif (ref($ref) eq "ARRAY") {
			foreach my $arg (@$ref) {
				&$process($arg);
			}
		}
	}
	my $pid = fork();
	if ($pid) {
		if (!$bg) {
			my $wait = waitpid($pid, 0);
			given ($wait) {
				when (-1)   { warn("no such child process\n"); }
				when (0)    { warn("some processes are still running\n"); }
				when ($pid) { return $?; }
			}
		} else {
			return 0;
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
		exec(@_) or die("cannot exec @_\n");
	}
	else {
		die("cannot fork\n");
	}
}

1;
