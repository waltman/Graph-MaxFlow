# $Id$

package Graph::MaxFlow;

require Exporter;
use Graph;

@ISA = qw(Exporter);
@EXPORT_OK = qw(max_flow);

$VERSION = '0.01';

use strict;
use warnings;

# Edmonds-Karp algorithm to find the maximum flow in $g between
# $source and $sink
sub max_flow {
    my ($g, $source, $sink) = @_;
    my $result = $g->deep_copy_graph;

    while (1) {
        # find the shortest augmenting path between $source and $sink
        my $path = shortest_path($result, $source, $sink);
        last unless @$path;

        # find min weight in path
        my $min;
        for my $i (0..$#$path - 1) {
            my $weight = $result->get_edge_weight($path->[$i], $path->[$i+1]);
            $min = $weight if !defined $min || $weight < $min;
        }

        # subtract that from every edge in the path
        for my $i (0..$#$path - 1) {
            my $weight = $result->get_edge_weight($path->[$i], $path->[$i+1]);
            $result->set_edge_weight($path->[$i], $path->[$i+1], $weight-$min);
        }

    }

    # convert weights from residual to actual flow
    for my $e ($result->edges) {
        my $new = $result->get_edge_weight(@$e);
        my $old = $g->get_edge_weight(@$e);
        $result->set_edge_weight(@$e, $old - $new);
    }

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

    # loop until we either reach $to or run out of nodes in the @next queue
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

1;

=head1 NAME

Graph::MaxFlow - compute maximum flow between 2 vertices in a graph

=head1 SYNOPSIS

  use Graph::MaxFlow qw(max_flow);

  my $g = new Graph;
  # construct graph
  my $flow = max_flow($g, "source", "sink");

=head1 DESCRIPTION

Computes the maximum flow in a graph, represented using Jarkko
Hietaniemi's Graph.pm module.

=head1 FUNCTIONS

This module provides the following function:

=over 4

=item max_flow($g, $s, $t)

Computes the maximum flow in the graph $g between vertices $s and $t
using the Edmonds-Karp algorithm.  $g must be a Graph.pm object, and
must be a directed graph where the edge weights indicate the capacity
of each edge.  The edge weights must be nonnegative.  $s and $t must
be vertices in the graph.  The graph $g must be connected, and for
every vertex v besides $s and $t there must be a path from $s to $t
that passes through v.

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
