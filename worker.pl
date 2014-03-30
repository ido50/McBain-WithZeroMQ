#!/usr/bin/perl -w

use lib 'lib', 't/lib';

BEGIN { $ENV{MCBAIN_WITH} = 'WithZeroMQ'; }
 
use warnings;
use strict;
use Mendoza;
 
Mendoza->new->work();