use inc::Module::Install;
name 'Plagger-Plugin-Notify-XMPP-AnyEvent';
all_from 'lib/Plagger/Plugin/Notify/XMPP/AnyEvent.pm';

requires 'Plagger';
requires 'AnyEvent';
requires 'AnyEvent::XMPP::Client';
requires 'File::Spec';
requires 'Getopt::Std';
requires 'List::Util';
requires 'YAML';

auto_include;
WriteAll;
