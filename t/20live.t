use warnings;
use strict;
use Test::More;
use FindBin '$Bin';
use lib "$Bin/lib";

use Catalyst::Test qw/TestApp/;
use TestApp;
use Class::Load qw/is_class_loaded/;

ok(my $app = TestApp->new, "TestApp can be instantiated");
isa_ok($app, 'TestApp', '$app');

ok(my $model = $app->model('CPI'), 'we can get the model');
isa_ok($model, 'Catalyst::Model::CPI', 'the model');

my %gateways = map { $_ => 1 } $model->available_gateways;

ok(!$gateways{'Business::CPI::Gateway::Test'}, 'Test was NOT found by Module::Pluggable');
ok(!is_class_loaded('Business::CPI::Gateway::Test'), 'Test was NOT loaded');

{
    ok($gateways{'Business::CPI::Gateway::TestGateway1'}, 'TestGateway1 was found by Module::Pluggable');
    ok(is_class_loaded('Business::CPI::Gateway::TestGateway1'), 'TestGateway1 was loaded');
    ok(Business::CPI::Gateway::TestGateway1->does('Business::CPI::Role::Request'), 'the Request role was applied');

    ok(my $g = $model->get('TestGateway1'), 'the gateway can be gotten by the module');
    isa_ok($g, 'Business::CPI::Gateway::TestGateway1', 'the gateway');
    isa_ok($g->req, 'Catalyst::Request', 'the request attribute');
    is($g->user, 'a', 'The configuration parameter `user` was passed correctly to the gateway constructor');
    is($g->key,  '123', '... as well as the key');
}

{
    ok($gateways{'Business::CPI::Gateway::TestGateway2'}, 'TestGateway2 was found by Module::Pluggable');
    ok(is_class_loaded('Business::CPI::Gateway::TestGateway2'), 'TestGateway2 was loaded');
    ok(Business::CPI::Gateway::TestGateway2->does('Business::CPI::Role::Request'), 'the Request role was applied');

    ok(my $g = $model->get('TestGateway2'), 'the gateway can be gotten by the module');
    isa_ok($g, 'Business::CPI::Gateway::TestGateway2', 'the gateway');
    isa_ok($g->req, 'Catalyst::Request', 'the request attribute');
    is($g->user, 'b', 'The configuration parameter `user` was passed correctly to the gateway constructor');
    is($g->key,  '456', '... as well as the key');
}

done_testing;
