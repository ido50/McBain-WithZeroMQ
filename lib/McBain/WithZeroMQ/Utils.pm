package McBain::WithZeroMQ::Utils;

BEGIN {
	use Exporter 'import';
	@EXPORT_OK = qw/zmq_broker zmq_client/;
}

use warnings;
use strict;

use ZMQ::LibZMQ3;
use ZMQ::Constants qw/ZMQ_ROUTER ZMQ_DEALER ZMQ_POLLIN ZMQ_RCVMORE ZMQ_SNDMORE ZMQ_REQ/;

our $MAX_MSGLEN = 255;

sub zmq_broker {
	my ($fport, $bport) = @_;

	# Prepare our context and sockets
	my $context = zmq_init();
	my $frontend = zmq_socket($context, ZMQ_ROUTER);
	my $backend = zmq_socket($context, ZMQ_DEALER);
	zmq_bind($frontend, 'tcp://*:'.$fport);
	zmq_bind($backend, 'tcp://*:'.$bport);

	# Initialize poll set
	my @poll = (
		{
			socket => $frontend,
			events => ZMQ_POLLIN,
			callback => sub {
				while (1) {
					# Process all parts of the message
					my $message = zmq_recvmsg($frontend);
					my $more = zmq_getsockopt($frontend, ZMQ_RCVMORE);
					zmq_sendmsg($backend, $message, $more ? ZMQ_SNDMORE : 0);
					last unless $more;
				}
			}
		}, {
			socket => $backend,
			events => ZMQ_POLLIN,
			callback => sub {
				while (1) {
					# Process all parts of the message
					my $message = zmq_recvmsg($backend);
					my $more = zmq_getsockopt($backend, ZMQ_RCVMORE);
					zmq_sendmsg($frontend, $message, $more ? ZMQ_SNDMORE : 0);
					last unless $more;
				}
			}
		}
	);

	while (1) {
		zmq_poll(\@poll);
	}
}

sub zmq_client {
	my ($port, $payload) = @_;

	my $context = zmq_init();

	# Socket to talk to server
	my $requester = zmq_socket($context, ZMQ_REQ);
	zmq_connect($requester, 'tcp://localhost:'.$port);

	# send the request
	zmq_send($requester, $payload, -1);

	# receive the reply
	my $size = zmq_recv($requester, my $buf, $MAX_MSGLEN);
	my $string = $size >= 0 ? substr($buf, 0, $size) : '';
	print $string, "\n";
}
