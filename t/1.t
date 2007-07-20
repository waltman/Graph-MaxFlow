# $Id$

use strict;
use Test::More tests => 12;
use Graph;

BEGIN { use_ok('Graph::MaxFlow', qw(max_flow)) }

my $g = new Graph;

$g->add_weighted_edge("s",  "v1", 16);
$g->add_weighted_edge("s",  "v2", 13);
$g->add_weighted_edge("v1", "v2", 10);
$g->add_weighted_edge("v1", "v3", 12);
$g->add_weighted_edge("v2", "v1", 4);
$g->add_weighted_edge("v2", "v4", 14);
$g->add_weighted_edge("v3", "v2", 9);
$g->add_weighted_edge("v3", "t",  20);
$g->add_weighted_edge("v4", "v3", 7);
$g->add_weighted_edge("v4", "t",  4);

my $flow = max_flow($g, "s", "t");

is($flow, "s-v1,s-v2,v1-v2,v1-v3,v2-v1,v2-v4,v3-t,v3-v2,v4-t,v4-v3");
is($flow->get_edge_weight("v3", "v2"), 0);
is($flow->get_edge_weight("v1", "v3"), 12);
is($flow->get_edge_weight("v3", "t"),  19);
is($flow->get_edge_weight("v4", "t"),  4);
is($flow->get_edge_weight("v1", "v2"), 0);
is($flow->get_edge_weight("v4", "v3"), 7);
is($flow->get_edge_weight("s",  "v2"), 11);
is($flow->get_edge_weight("v2", "v1"), 0);
is($flow->get_edge_weight("s",  "v1"), 12);
is($flow->get_edge_weight("v2", "v4"), 11);
