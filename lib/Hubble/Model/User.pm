package Hubble::Model::User;

use Mojo::Base 'Hubble::Model';

use Passwords ();

sub create {
  my ($self, $query, $cb) = @_;
  my $pass = Passwords::password_hash($query->{password});
  my $sql = <<'  SQL';
    insert into users (username, fullname, password)
    values (?, ?, ?)
    returning id
  SQL
  return $self->query($sql, @{$query}{qw/username fullname/}, $pass)->hash->{id};
}

sub get_many {
  my ($self, $query) = @_;

  my $password = $query->{password} ? 'password,' : '';

  my $sql = <<"  SQL";
    select
      id,
      username,
      fullname,
      $password
      joined
    from users
  SQL

  my (@args, @where);
  for my $field (qw/username id/) {
    if (exists $query->{$field}) {
      push @where, "$field = ?";
      push @args, $query->{$field};
    }
  }
  $sql .= ' where ' . join ' and ', @where if @where;

  for my $param (qw/limit offset/) {
    if (exists $query->{$param}) {
      $sql .= " $param ?";
      push @args, $query->{$param};
    }
  }

  return $self->query($sql, @args)->hashes;
}

sub get_one {
  my ($self, $query) = @_;
  ($query ||= {})->{limit} = 1;
  return $self->get_many($query)->[0];
}

sub check_password {
  my ($self, $user, $password) = @_;
  $user = do {
    local $user->{password} = 1;
    $self->get_one($user);
  } unless $user->{password};
  return Passwords::password_verify($password, $user->{password});
}

1;

