package #
    Business::CPI::Gateway::TestGateway1;
use Moo;
extends 'Business::CPI::Gateway::Base';

has user => (is => 'ro');
has key  => (is => 'ro');

sub notify {}

1;
