require 5.004;
use strict;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    (MM->can('signature_target') ? (SIGN => 1) : ()),
    'NAME'		=> 'Graph::MaxFlow',
    'VERSION_FROM'	=> 'MaxFlow.pm', # finds $VERSION
    'dist'              => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    'PREREQ_PM'         => { 'Graph' => 0 },
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'MaxFlow.pm', # retrieve abstract from module
       AUTHOR        => 'Walt Mankowski <waltman@cpan.org>') : ()),
);
