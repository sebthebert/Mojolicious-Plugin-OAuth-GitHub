package Mojolicious::Plugin::OAuth::GitHub;

=encoding utf8

=head1 NAME

Mojolicious::Plugin::OAuth::GitHub - Mojolicious Plugin

=head1 SYNOPSIS

	# Mojolicious
	$self->plugin('OAuth::GitHub');

	# Mojolicious::Lite
	plugin 'OAuth::GitHub';

=head1 DESCRIPTION

L<Mojolicious::Plugin::OAuth::GitHub> is a L<Mojolicious> plugin.
It provides GitHub Oauth authentification.

More information about GitHub OAuth: 
https://developer.github.com/v3/oauth/

It adds two routes to your application:
/oauth/github/auth
/oauth/github/authcallback

=head1 METHODS

L<Mojolicious::Plugin::OAuth::GitHub> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=cut

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::UserAgent;

our $VERSION = '0.02';

my $GH_OAUTH_URL = 'https://github.com/login/oauth'; 
my ($gh_client_id, $gh_client_secret, $gh_state) = (undef, undef, undef);

=head2 register

	$plugin->register(Mojolicious->new);

Register plugin in L<Mojolicious> application.

=cut

sub register 
{
	my ($self, $app) = @_;

	my $config = $app->plugin('JSONConfig');
	$gh_client_id = $config->{oauth}->{github}->{client_id};
    $gh_client_secret = $config->{oauth}->{github}->{client_secret};
	$gh_state = 'random_state'; 
	#TODO makes it random !

	my $routes = $app->routes;
	# adds 2 routes for OAuth GitHub
	$routes->get('/oauth/github/auth')
        ->to(cb => \&oauth_github_auth);
	$routes->get('/oauth/github/authcallback')
        ->to(cb => \&oauth_github_authcallback);
}

sub oauth_github_auth
{
	my $self = shift;

	$self->redirect_to("$GH_OAUTH_URL/authorize?"
		. "&client_id=${gh_client_id}&state=$gh_state");
}

sub oauth_github_authcallback
{
    my $self = shift;

	my $code = $self->param('code');
	#TODO check state
	my $state = $self->param('state');

	my $ua = Mojo::UserAgent->new;
	my $tx = $ua->post("$GH_OAUTH_URL/access_token" => form => {
        client_id     => $gh_client_id,
        client_secret => $gh_client_secret,
        code          => $code,
       	state         => $state,
        });

	foreach my $param (split(/&/, $tx->res->body))
	{
		my ($key, $value) = split(/=/, $param);
		$self->session('github_access_token' => $value)
			if ($key eq 'access_token');
	}
	
	$self->redirect_to("/");
	#$self->render(text => "GitHub Acces Token: " . $conf{access_token});
}

1;

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=head1 AUTHOR

Sebastien Thebert <stt@onetool.pm>

=cut
