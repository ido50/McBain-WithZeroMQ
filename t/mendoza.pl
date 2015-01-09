#!/usr/bin/perl -w

use lib './lib', './t/lib';
use warnings;
use strict;
use Mendoza;
use McBain::WithZeroMQ;

my $api = Mendoza->new;
my $worker = McBain::WithZeroMQ->new($api);

$worker->work;