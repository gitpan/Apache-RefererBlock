use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Apache::RefererBlock',
    'VERSION_FROM' => 'RefererBlock.pm', # finds $VERSION
    dist => {
               SUFFIX => 'gz',
               COMPRESS => 'gzip -9',
             }

);
