#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install;

name 'Pod-JSchema';
all_from 'lib/Pod/JSchema.pm';

requires 'parent';
requires 'Moose';
requires 'HTML::Entities';
requires 'Pod::Parser';
requires 'Module::Pluggable';
requires 'JSON';
requires 'JSON::PP';

install_script glob('bin/*');
#auto_install;
WriteAll;

