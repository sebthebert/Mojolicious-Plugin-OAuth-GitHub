use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Mojolicious::Plugin::OAuth::GitHub',
  VERSION_FROM => 'lib/Mojolicious/Plugin/OAuth/GitHub.pm',
  AUTHOR       => 'A Good Programmer <nospam@cpan.org>',
  PREREQ_PM    => {'Mojolicious' => '5.29'},
  test         => {TESTS => 't/*.t'}
);
