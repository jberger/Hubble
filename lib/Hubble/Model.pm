package Hubble::Model;

use Mojo::Base 'Mojo::TypeModel';

use Hubble::Model::User;

# pseudo-attribute
sub db {
  my $self = shift;
  if (@_) {
    $self->{db} = shift;
    return $self;
  }
  return $self->{db} if $self->{db};
  return $self->pg->db;
}

has pg => sub { die 'pg is required' };

sub copies { state $copies = ['pg'] }

sub types {
  state $types = {
    user => 'Hubble::Model::User',
  };
}

sub query { shift->db->query(@_) }

1;

=head1 ATTRIBUTES

L<Hubble::Model> inherits all attributes from L<Mojo::TypeModel> and implements the following new ones.

=head2 db

An instance of a L<Mojo::Pg::Database> object.
If manually set then it will always return the same instance.
Otherwise it will fetch a new DB connection from L</pg>.

This is especially useful so that more than one model may share the same transaction.

  my $tx = $db->begin;
  $bmc_model->db($db);
  $dhcp_model->db($db);
  # do work on both instances
  $tx->commit;

It is encouraged all queries made by the model layer be performed by the database as returned by this attribute so that this type of interaction is respected.
The L</query> method takes this into account.

N.B. It is encouraged that you not reuse models after this point so that the database connections can return to the pool.

=head1 METHODS

L<Hubble::Model> inherits all methods from L<Mojo::TypeModel> and implements the following new ones.

=head2 query

  my $q = $model->query( $sql, @placeholders );

Performs a database query via L<Mojo::Pg::Database/query>.
It uses the value of L</db> which is necessary in case the query is performed as a part of transaction containing multiple model queries.

