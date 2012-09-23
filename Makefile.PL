use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
	      NAME                => 'System::NG',
	      AUTHOR              => 'Darren Embry <dse@webonastick.com>',
	      VERSION_FROM        => 'lib/System/NG.pm',
	      ABSTRACT_FROM       => 'lib/System/NG.pm',
	      PL_FILES            => {},
	      LICENSE             => 'perl',
	      PREREQ_PM           => {
				      'Test::More'                 => 0,
				     },
	      dist                => { COMPRESS => 'gzip -9f',
				       SUFFIX => 'gz', },
	      clean               => { FILES => 'System-NG-*' },
	     );
