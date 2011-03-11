package Dancer::Session::Cookie;

use strict;
use warnings;
use base 'Dancer::Session::Abstract';

use Crypt::CBC;
use String::CRC32;
use Crypt::Rijndael;

use Dancer::Config 'setting';
use Dancer::ModuleLoader;
use Storable     ();
use MIME::Base64 ();

use vars '$VERSION';
$VERSION = '0.13';

# crydec
my $CIPHER = undef;

sub init {
    my ($class) = @_;

    my $key = setting("session_cookie_key")  # XXX default to smth with warning
      or die "The setting session_cookie_key must be defined";

    $CIPHER = Crypt::CBC->new(
        -key    => $key,
        -cipher => 'Rijndael',
    );
}

sub new {
    my $self = Dancer::Object::new(@_);

    # id is not needed here because the whole serialized session is
    # the "id"
    return $self;
}

sub retrieve {
    my ($class, $id) = @_;

    my $ses = eval {
        # 1. decrypt and deserialize $id
        my $plain_text = _decrypt($id);

        # 2. deserialize
        $plain_text && Storable::thaw($plain_text);
    };

    $ses and $ses->{id} = $id;

    return $ses;
}

sub create {
    my $class = shift;
    return Dancer::Session::Cookie->new(id => 'empty');
}


# session_name was introduced to Dancer::Session::Abstract in 1.176
# we have 1.130 as the minimum
sub session_name {
    my $self = shift;
    return eval { $self->SUPER::session_name } || setting("session_name") || "dancer.session";
}

sub flush {
    my $self = shift;

    # 1. serialize and encrypt session
    delete $self->{id};
    my $cipher_text = _encrypt(Storable::freeze($self));

    my $session_name = $self->session_name;
    Dancer::Cookies->cookies->{$session_name} = Dancer::Cookie->new(
        name  => $session_name,
        value => $cipher_text,
        path  => setting("session_cookie_path") || "/",
        secure=> setting("session_secure"),
    );
    $self->{id} = $cipher_text;
    return 1;
}

sub destroy {
    my $self = shift;
    delete Dancer::Cookies->cookies->{$self->session_name};

    return 1;
}

sub _encrypt {
    my $plain_text = shift;

    my $crc32 = String::CRC32::crc32($plain_text);

    # XXX should gzip data if it grows too big. CRC32 won't be needed
    # then.
    my $res =
      MIME::Base64::encode($CIPHER->encrypt(pack('La*', $crc32, $plain_text)),
        q{});
    $res =~ tr{=+/}{_*-};    # cookie-safe Base64

    return $res;
}

sub _decrypt {
    my $cookie = shift;

    $cookie =~ tr{_*-}{=+/};

    $SIG{__WARN__} = sub {};
    my ($crc32, $plain_text) = unpack "La*",
      $CIPHER->decrypt(MIME::Base64::decode($cookie));
    return $crc32 == String::CRC32::crc32($plain_text) ? $plain_text : undef;
}

1;
__END__

=pod

=head1 NAME

Dancer::Session::Cookie - Encrypted cookie-based session backend for Dancer

=head1 SYNOPSIS

Your F<config.yml>:

    session: "cookie"
    session_cookie_key: "this random key IS NOT very random"

=head1 DESCRIPTION

This module implements a session engine for sessions stored entirely
in cookies. Usually only B<session id> is stored in cookies and
the session data itself is saved in some external storage, e.g.
database. This module allows to avoid using external storage at
all.

Since server cannot trust any data returned by client in cookies, this
module uses cryptography to ensure integrity and also secrecy. The
data your application stores in sessions is completely protected from
both tampering and analysis on the client-side.

=head1 CONFIGURATION

The setting B<session> should be set to C<cookie> in order to use this session
engine in a Dancer application. See L<Dancer::Config>.

A mandatory setting is needed as well: B<session_cookie_key>, which should
contain a random string of at least 16 characters (shorter keys are
not cryptographically strong using AES in CBC mode).

Here is an example configuration to use in your F<config.yml>:

    session: "cookie"
    session_cookie_key: "kjsdf07234hjf0sdkflj12*&(@*jk"

Compromising B<session_cookie_key> will disclose session data to
clients and proxies or eavesdroppers and will also allow tampering,
for example session theft. So, your F<config.yml> should be kept at
least as secure as your database passwords or even more.

Also, changing B<session_cookie_key> will have an effect of immediate
invalidation of all sessions issued with the old value of key.

B<session_cookie_path> can be used to control the path of the session
cookie.  The default is /.

The global B<session_secure> setting is honoured and a secure (https
only) cookie will be used if set.

=head1 DEPENDENCY

This module depends on L<Crypt::CBC>, L<Crypt::Rijndael>,
L<String::CRC32>, L<Storable> and L<MIME::Base64>.

=head1 AUTHOR

This module has been written by Alex Kapranoff.

=head1 SEE ALSO

See L<Dancer::Session> for details about session usage in route handlers.

See L<Plack::Middleware::Session::Cookie>,
L<Catalyst::Plugin::CookiedSession>, L<Mojolicious::Controller/session> for alternative implementation of this mechanism.

=head1 COPYRIGHT

This module is copyright (c) 2009-2010 Alex Kapranoff <kappa@cpan.org>.

=head1 LICENSE

This module is free software and is released under the same terms as Perl
itself.

=cut
