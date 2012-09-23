package System::NG;
require v5.10;
use feature qw(switch);

our $VERSION   = "0.01";

use Exporter;
our @ISA       = qw(Exporter);
our @EXPORT    = qw(system_ng);
our @EXPORT_OK = qw(system_ng);

=head1 NAME

System::NG - enhanced system() call

=head1 SYNOPSIS

    use System::NG;

    system_ng("ls -l");
    system_ng("ls", "-l");

    system_ng(["&"], "xterm");

    system_ng(["<prog.in", ">prog.out", "2>prog.err"], "prog");

=head1 DESCRIPTION

System::NG provides an enhanced system_ng() call that can be used as a
drop-in replacement of Perl's built-in system() call.  system_ng()
provides the ability to run a process in the background as well as
redirect STDIN, STDOUT, and/or STDERR without using the less secure
single-argument form of the system() call.

=head1 EXPORTED FUNCTIONS

=over 4

=item system_ng(LIST);

=item system_ng(ARRAYREF, LIST);

Does exactly the same thing as system(LIST), returns the same value,
and also returns the status in $? like the system call does.

If the first argument is an ARRAYREF, each member of the ARRAYREF
affects the execution of the program as follows:

=over 4

=item "&"

The program is executed in the background, exactly as if you were
running:

    system("xterm &");

=item "<anything"

STDIN is redirected from the specified file or whatever else, exactly
as if you were running:

    system("prog --foo '$file' <prog.in");

but you can do this:

    system(["<prog.in"], "prog --foo '$file'");

or this:

    system(["<prog.in"], "prog", "--foo", $file);

which won't fail if there's an apostrophe ("'") in your $file name.

=item ">anything"

STDOUT is redirected to the specified file or whatever else.  Like:

    system("prog --foo bar >prog.out");

=item "2>anything"

STDERR is redirected to the specified file or whatever else.  Like:

    system("prog --foo bar 2>prog.err");

=back

Other arguments are ignored.

=back

=cut

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

=head1 BUGS

eh?

=head1 AUTHOR

Darren Embry, C<dse at webonastick.com>.

=head1 COPYRIGHT & LICENSE

Copyright 2012 Darren Embry, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
