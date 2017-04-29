package Hubble;

use Mojo::Base 'Mojolicious';

use Carp ();
use File::Share ();
use Mojo::File;
use Mojo::Pg;
use Mojo::Pg::Migrations;

use Hubble::Model;

has migrations => sub { [] };

has pg => sub {
  my $app = shift;
  my $pg = Mojo::Pg->new($app->config->{pg} || die 'pg url not configured');
  my $migration = $app->add_migration($pg);
  my $file = $app->share->child('hubble.sql');
  $migration->name('hubble')->from_file($file);
  return $pg;
};

has share => sub {
  return Mojo::File->new(File::Share::dist_dir('Hubble'));
};

sub add_migration {
  my ($app, $pg) = @_;
  $pg ||= $app->pg;
  my $migration = Mojo::Pg::Migrations->new(pg => $pg);
  push @{ $app->migrations }, $migration;
  return $migration;
};

sub migrate {
  my $app = shift;
  $_->migrate for @{ $app->migrations };
}

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

