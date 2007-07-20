# $Id$

package Graph::MaxFlow;

require Exporter;
use Graph;
use List::Util 'min';

@ISA = qw(Exporter);
@EXPORT_OK = qw(max_flow);

$VERSION = '0.01';

use strict;
use warnings;

# really edmonds-karp since I'm finding the shortest path from s to t
# each time
sub max_flow {
    my ($g, $source, $sink) = @_;
    my $result = $g->deep_copy_graph;

    while (my $path = shortest_path($result, $source, $sink)) {
        last unless @$path;

        print "path = @$path\n";

        # find min weight in path
        my @weights;
        for my $i (0..$#$path - 1) {
            push @weights, $result->get_edge_weight($path->[$i], $path->[$i+1]);
        }
        my $min = min(@weights);

        # subtract that from every edge in the path
        for my $i (0..$#$path - 1) {
            my $weight = $result->get_edge_weight($path->[$i], $path->[$i+1]);
            $result->set_edge_weight($path->[$i], $path->[$i+1], $weight-$min);
        }

        print_flow($result);
    }

    # convert weights from residual to actual flow
    for my $e ($result->edges) {
        my $new = $result->get_edge_weight(@$e);
        my $old = $g->get_edge_weight(@$e);
#        print "@$e, $old, $new\n";
        $result->set_edge_weight(@$e, $old - $new);
    }
    print_flow($result);

    return $result;
}

# do a breadth-first search over edges with positive weight
sub shortest_path {
    my ($g, $from, $to) = @_;

    my %parent;
    my @next;
    $parent{$from} = undef;
    $next[0] = $from;
    my $found = 0;

    while (@next) {
        my $u = shift @next;
        if ($u eq $to) {
            $found = 1;
            last;
        }

        for my $v ($g->successors($u)) {
            next if exists $parent{$v};
            next unless $g->get_edge_weight($u, $v) > 0;
            $parent{$v} = $u;
            push @next, $v;
        }
    }

    # reconstruct path
    my @path;
    if ($found) {
        my $u = $to;
        while (defined $parent{$u}) {
            unshift @path, $u;
            $u = $parent{$u};
        }
        unshift @path, $from;
    }

    return \@path;
}

sub print_flow {
    my $g = shift;

    print "g = $g\n";

    for my $e ($g->edges) {
        printf "%s->%s, %d\n", $e->[0], $e->[1], $g->get_edge_weight(@$e);
    }
}

1;

=head1 NAME

Graph::MaxFlow - compute maximum flow between 2 vertices in a graph

=head1 SYNOPSIS

  use Graph::MaxFlow qw(max_flow);

  my $g = new Graph;
  # construct graph
  my $flow = max_flow($g, "source", "sink");

=head1 DESCRIPTION

Computes the maximum flow in a graph.

=head1 FUNCTIONS

This module provides the following functions:

=over 4

=item max_flow($g, $s, $t)

Computes the maximum flow in the graph $g between vertices $s and $t
using the Edmonds-Karp algorithm.  $g must be a directed graph where
the edge weights indicate the capacity of each edge.  $s and $t must
be vertices in the graph.

The return value is a new directed graph which has the same vertices
and edges as $g, but where the edge weights have been adjusted to
indicate the flow along each edge.

=back

=head1 AUTHOR

Walt Mankowski, E<lt>waltman@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2007 by Walt Mankowski

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=head1 ACKNOWLEDGEMENTS

The algorithms are adapted from Introduction to Algorithms, Second
Edition, Cormen-Leiserson-Rivest-Stein, MIT Press.

=cut
