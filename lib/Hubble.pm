package Hubble;

use Mojo::Base 'Mojolicious';

use Carp ();
use File::Share ();
use Mojo::File;
use Mojo::Pg;
use Hubble::Model;

has pg => sub {
  my $app = shift;
  my $pg = Mojo::Pg->new($app->config->{pg} || die 'pg url not configured');
  my $file = $app->share->child('hubble.sql');
  $pg->migrations->name('hubble')->from_file($file);
  return $pg;
};

has share => sub {
  return Mojo::File->new(File::Share::dist_dir('Hubble'));
};

sub startup {
  my $app = shift;
  $app->plugin(Config => {
    default => {
      pg => undef,
    },
  });

  my $pg = $app->pg;

  my $model = Hubble::Model->new(pg => $pg);
  $app->plugin(TypeModel => {base => $model});
}

1;

