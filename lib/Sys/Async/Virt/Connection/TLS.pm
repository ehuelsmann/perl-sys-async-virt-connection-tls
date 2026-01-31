####################################################################
#
#     This file was generated using XDR::Parse version v1.0.1
#                   and LibVirt version v12.0.0
#
#      Don't edit this file, use the source template instead
#
#                 ANY CHANGES HERE WILL BE LOST !
#
####################################################################


use v5.26;
use warnings;
use experimental 'signatures';
use Future::AsyncAwait;
use Object::Pad ':experimental(inherit_field)';

class Sys::Async::Virt::Connection::TLS v0.4.0;

inherit Sys::Async::Virt::Connection::TCP '$_in', '$_out', '$_socket', '$_url';

use Carp qw(croak);
use Future::IO::TLS;
use Log::Any qw($log);

use Protocol::Sys::Virt::URI; # imports parse_url


async method connect() {
    # disect URL
    my %components = parse_url( $_url );

    await $self->SUPER::connect();

    my $no_verify    = $components{query}->{no_verify};
    my $pkipath      = $components{query}->{pkipath};
    my $tls_priority = $components{query}->{tls_priority};
    my $cacert;
    my $clientcert;
    my $clientkey;

    if ($pkipath) {
        $cacert     = "$pkipath/cacert.pem";
        $clientcert = "$pkipath/clientcert.pem";
        $clientkey  = "$pkipath/clientkey.pem";
    }
    else {
        if ($> != 0) {
            if (-r "$ENV{HOME}/.pki/cacert.pem") {
                $cacert = "$ENV{HOME}/.pki/cacert.pem";
            }
            if (-r "$ENV{HOME}/.pki/libvirt/clientcert.pem"
                and -r "$ENV{HOME}/.pki/libvirt/clientkey.pem") {
                $clientcert = "$ENV{HOME}/.pki/libvirt/clientcert.pem";
                $clientkey  = "$ENV{HOME}/.pki/libvirt/clientkey.pem";
            }
        }
        $cacert     = '/etc/pki/CA/cacert.pem';
        $clientcert = '/etc/pki/libvirt/clientcert.pem';
        $clientkey  = '/etc/pki/libvirt/clientkey.pem';
    }

    my $tls = await Future::IO::start_TLS( $_socket );
    $_socket = $tls;
    $_in = $tls;
    $_out = $tls;
}

method is_secure() {
    return 1;
}

1;


__END__

=head1 NAME

Sys::Async::Virt::Connection::TLS - Connection to LibVirt server over TLS sockets

=head1 VERSION

v0.4.0

=head1 SYNOPSIS

  use v5.26;
  use Future::AsyncAwait;
  use Sys::Async::Virt::Connection::Factory;

  my $factory = Sys::Async::Virt::Connection::Factory->new;
  my $conn    = $factory->create_connection( 'qemu+tls://example.com/system' );

=head1 DESCRIPTION

This module connects to a remote LibVirt server through a TLS socket. This transport
uses an encrypted TLS connection to libvirt, which is the default when no transport
is specified.

This module requires L<Future::IO::Resolver> to operate fully asynchronous;
in case this module is unavailable, the C<getaddrinfo> function from L<Socket>
is used - which is a blocking function call.

=head1 URL PARAMETERS

This connection driver supports these additional parameters,
as per L<LibVirt's documentation|https://libvirt.org/uri.html#tls-transport>.

=over 8

=item * C<tls_priority>

=item * C<no_verify>

=item * C<pkipath>

=back

=head1 CONSTRUCTOR

=head2 new

Not to be called directly. Instantiated via the connection factory
(L<Sys::Async::Virt::Connection::Factory>).

=head1 METHODS

=head2 connect

  await $conn->connect;

=head2 is_secure

  my $bool = $conn->is_secure;

Returns C<true>.

=head1 SEE ALSO

L<LibVirt|https://libvirt.org>, L<Sys::Virt>

=head1 LICENSE AND COPYRIGHT


  Copyright (C) 2024-2026 Erik Huelsmann

All rights reserved. This program is free software;
you can redistribute it and/or modify it under the same terms as Perl itself.
