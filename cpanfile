requires 'Mojolicious', '7.29'; # test config overrides
requires 'Mojo::Pg';
requires 'Mojo::TypeModel';
requires 'Passwords';
requires 'File::Share';

on test => sub {
  requires => 'Test2::Suite';
};

