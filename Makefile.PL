package Apache::RefererBlock;
use ExtUtils::MakeMaker;
use Apache::ExtUtils qw(command_table);
use Apache::src ();

my @directives= (
                 { name     => 'RefBlockDebug',
                   errmsg   => 'On or Off',
                   args_how => 'FLAG',
                   req_override => 'RSRC_CONF'
                 },
                 { name     => 'RefBlockMimeTypes',
                   errmsg   => 'a list of MIME types to watch',
                   args_how => 'ITERATE',
                   req_override => 'RSRC_CONF'
                 },
                 { name     => 'RefBlockAllowed',
                   errmsg   => 'a list of URLs of allowed referers',
                   args_how => 'ITERATE',
                   req_override => 'RSRC_CONF'
                 },
                 { name     => 'RefBlockRedirect',
                   errmsg   => 'a referer, followed by a URL to redirect',
                   args_how => 'TAKE2',
                   req_override => 'RSRC_CONF'
                 },
                );

command_table(\@directives);

WriteMakefile(
    NAME         => 'Apache::RefererBlock',
    AUTHOR       => 'Eric Cholet <cholet@logilune.com>',
    ABSTRACT     => 'block request based upon referer header',
    VERSION_FROM => 'RefererBlock.pm',
    INC          => Apache::src->new->inc,
    PREREQ_PM    => { Test::More       => 0,
                      Test::MockObject => 0,
                    },
    clean        => { FILES => 'RefererBlock.xs' },
    dist         => { COMPRESS => 'gzip -9f',
                      SUFFIX   => 'gz',
                    },
);
