#!/usr/bin/perl -w

use lib './lib', './t/lib', '../McBain/lib';
use warnings;
use strict;
use Mendoza;
use McBain::WithZeroMQ;

my $api = Mendoza->new;
my $worker = McBain::WithZeroMQ->run(
	port => [11977, 11978],
	min_servers => 3,
	max_servers => 6,
	api => $api
);