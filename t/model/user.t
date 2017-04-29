use Mojo::Base -strict;

use Test2::Bundle::Extended;
use Test::Mojo;

use Mojo::URL;

skip_all 'Set TEST_HUBBLE=postgresql://... to test'
  unless my $pg_url = $ENV{TEST_HUBBLE};

my $schema = 'hubble_t_model_user';
$pg_url = Mojo::URL->new($pg_url)->query([search_path => $schema])->to_unsafe_string;

my $t = Test::Mojo->new('Hubble' => {pg => $pg_url});

my $app = $t->app;
my $pg  = $app->pg;
$pg->db->query("drop schema if exists $schema cascade");
$pg->db->query("create schema $schema");
$app->migrate;

my $model = $app->model->user;
my $id = $model->create({
  username => 'johndoe',
  fullname => 'John Doe',
  password => 'abc123',
});

ok $id, 'id set';

my $expect = {
  id => $id,
  username => 'johndoe',
  fullname => 'John Doe',
  joined   => match(qr/^\d{4}-\d{2}-\d{2}/),
};
is $model->get_one({id => $id}), $expect, 'object retrieved as expected';

ok $model->check_password({id => $id}, 'abc123'), 'password ok';
ok !$model->check_password({id => $id}, 'notz teh passw0rd'), 'password not ok';

$pg->db->query("drop schema $schema cascade");

done_testing;

