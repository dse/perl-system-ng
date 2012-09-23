# System::NG

provides an enhanced version of the system() call called system_ng().
It returns the same value as system() would.
It affects $? in the same way as system() would.

I wrote this primarily in order to be able to use the
multiple-argument form of the system() call and still be able to do
things like background execution and I/O redirection.

# Examples

    use System::NG;

    system_ng("ls -l");
    system_ng("ls", "-l");

    system_ng(["&"], "xterm");

    system_ng(["<prog.in", ">prog.out", "2>prog.err"], "prog");

# Copyright & License

Copyright 2012 Darren Embry <dse@webonastick.com>, all rights
reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

