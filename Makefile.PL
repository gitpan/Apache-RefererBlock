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
    'NAME'	=> 'Apache::RefererBlock',
    'VERSION_FROM' => 'RefererBlock.pm', # finds $VERSION
    'LIBS'	=> [''],   # e.g., '-lm' 
    'DEFINE'	=> '',     # e.g., '-DHAVE_SOMETHING' 
    'INC'       => Apache::src->new->inc,
);
