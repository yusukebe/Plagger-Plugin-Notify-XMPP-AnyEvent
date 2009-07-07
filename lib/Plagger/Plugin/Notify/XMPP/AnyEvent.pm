package Plagger::Plugin::Notify::XMPP::AnyEvent;
use strict;
use base qw( Plagger::Plugin );
use AnyEvent::Socket;
use AnyEvent::Handle;
use Encode;

our $VERSION = '0.01';

sub register {
    my ( $self, $context ) = @_;
    $context->register_hook(
        $self,
        'plugin.init'   => \&initialize,
        'publish.entry' => \&notify_entry,
    );
}

sub initialize {
    my ( $self, $context ) = @_;
}

sub notify_entry {
    my ( $self, $context, $args ) = @_;
    my $port = $self->conf->{daemon_port} || 9997; # default port is 9997
    my $title = encode( 'utf8', $args->{entry}->{title} );
    my $cv = AnyEvent->condvar;
    tcp_connect "localhost", $port, sub {
        my ($fh) = @_ or die "unable to connect: $!";
        my $handle;
        $handle = AnyEvent::Handle->new( fh => $fh, );
        $handle->push_write( json => { mes => $title, to => $self->conf->{to} } );
        $cv->send;
    };
    $cv->recv;
}

1;



__END__

=head1 NAME

Plagger::Plugin::Notify::XMPP::AnyEvent -

=head1 SYNOPSIS

  use Plagger::Plugin::Notify::XMPP::AnyEvent;

=head1 DESCRIPTION

Plagger::Plugin::Notify::XMPP::AnyEvent is

=head1 AUTHOR

Yusuke Wada E<lt>yusuke at kamawada.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
