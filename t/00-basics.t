#!perl -T
# -*- perl -*-
use warnings;
use strict;
use Test::More;
use System::NG;

sub ok_system {
	my ($args1, $args2) = @_;
	$args2 //= $args1;

	diag("system @$args1");
	my $result1 = system(@$args1);
	my $q1 = $?;
	diag("  returned result $result1");
	diag("  \$? == $q1");

	diag("system @$args2");
	my $result2 = system_ng(@$args2);
	my $q2 = $?;
	diag("  returned result $result2");
	diag("  \$? == $q2");

	ok($result1 == $result2, "result of system @$args1");
	ok($q1 == $q2, "\$? from system @$args1");
}

ok_system(["true"]);
ok_system(["false"]);
ok_system(["sleep 1"]);
ok_system(["exit 5"]);

done_testing();