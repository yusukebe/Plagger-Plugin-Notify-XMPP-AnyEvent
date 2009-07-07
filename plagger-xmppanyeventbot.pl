#/usr/bin/perl

use strict;
use warnings;
use AnyEvent::Handle;
use AnyEvent::Socket;
use AnyEvent::XMPP::Client;
use Getopt::Std;
use Encode;
use File::Spec;
use List::Util qw(first);
use Plagger::ConfigLoader;
use YAML;

my %opts; getopt('c',\%opts);
my $path = File::Spec->catfile( $opts{c} )
    or die "usage: ./plagger-xmppanyeventbot.pl -c config.yaml\n";

my $loader = Plagger::ConfigLoader->new;
my $config = $loader->load($path);
my $plugin = first { $_->{module} eq 'Notify::XMPP::AnyEvent' } @{ $config->{plugins} };
my $port = $plugin->{config}->{daemon_port} || 9997;

my $cv = AnyEvent->condvar;
my $cl;

tcp_server undef, $port, sub {
    my ( $fh, $host, $port ) = @_;
    my $handle;
    $handle = AnyEvent::Handle->new(
        fh     => $fh,
        on_eof => sub {
            undef $handle;
        },
    );
    $handle->push_read(
       json => sub {
           my $args = $_[1];
           my $mes = decode( 'utf8', $args->{mes} );
           for my $to ( @{ $args->{to} } ){
               $cl->send_message( $mes, $to );
           }
       }
    );
};

$cl = build_client( $plugin->{config} );
$cv->recv;

sub build_client {
    my $plugin_config = shift;
    my $password = $plugin_config->{password};
    if ($password =~ /^base64::(.*)/) {
        require MIME::Base64;
        $password = MIME::Base64::decode($1);
    }
    my $cl = AnyEvent::XMPP::Client->new( debug => 1 );
    $cl->add_account(
        $plugin_config->{jid},        $password,
        $plugin_config->{server_host}, $plugin_config->{server_port}
    );
    $cl->start;
    return $cl;
}
