#!/usr/bin/perl -w
#
# Cared for by Filipe G. Vieira <>
#
# Copyright Filipe G. Vieira
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

    prune_SNPs.pl v1.0.4

=head1 SYNOPSIS

    perl prune_SNPs.pl --in_file /path/to/input/file [--subset /path/to/subset/file] [--max_dist 100] [--min_LD 0.2] [--field 4] [--sorted]

    --in_file       = File with input network (default STDIN)
    --subset        = File with node IDs to include (one per line)
    --max_dist      = Maximum distance between nodes (input file 3rd column) to assume they are connected (in Kb)
    --min_LD        = Minimum level of LD allowed (as in --field option)
    --field         = Which column from input file to use
    --sorted        = Assumes input first column is sorted by genomic coordinates (usually "sort -k 1,1V")

=head1 DESCRIPTION

    This script will prune a network according to LD and distance between nodes (or any other two arbitrary metrics), 
    ending up in selecting one representative node for each connection cluster. Input file should be tab-sepparated 
    into: node1, node2, dist, LD.

=head1 AUTHOR

    Filipe G. Vieira - fgarrettvieira _at_ gmail _dot_ com

=head1 CONTRIBUTORS

    Additional contributors names and emails here

=cut


# Let the code begin...



use strict;
use Getopt::Long;
use List::Util qw/shuffle/;
use Graph::Easy;
use Math::BigInt;
use IO::Zlib;

my ($in_file, $subset_file, $max_dist, $min_LD, $field, $in_sorted, $debug);
my ($cnt, $edge, $node, $graph, $most_conected_node, $n_edges, $max_n_edges, %subset);

$in_file = '-';
$max_dist = 100;
$min_LD = 0.2;
$field = 4;
$debug = 0;
$cnt = 0;

# Parse args
GetOptions('h|help'             => sub { exec('perldoc',$0); exit; },
           'i|in_file=s'        => \$in_file,
	   's|subset:s'         => \$subset_file,
	   'd|max_dist:s'       => \$max_dist,
           'r|min_LD:s'         => \$min_LD,
           'f|field:s'          => \$field,
	   'sorted!'            => \$in_sorted,
	   'debug!'             => \$debug,
    );


if($in_sorted){
    print(STDERR "### Assuming input first column is sorted by genomic coordinates.\n");
}

# Parse subset file
if($subset_file){
    open(SUBSET, $subset_file) || die("ERROR: cannot open subset file!");
    %subset = map {chomp($_); $_ => 1} <SUBSET>;
    close(SUBSET);
}


# Create graph
$graph = Graph::Easy->new(undirected => 1);
$graph->timeout(60);


# Read file and build network
my $prev_id;
my $FILE = new IO::Zlib;
$FILE->open($in_file, "r") || die("ERROR: cannot open input file!");
while(<$FILE>){
    $cnt++;
    my @interact = split(m/\t/, $_);
    
    # If input is sorted and a new node, 
    if( $in_sorted && defined($prev_id) && $prev_id ne $interact[0] ){
	$node = $graph->node($prev_id);
	$n_edges = $node->edges();
	if($n_edges == 0){
	    print $node->label."\n";
	    $graph->del_node($node);
	}
    }
    $prev_id = $interact[0];

    $graph->add_node($interact[0]) if(!$subset_file || defined($subset{$interact[0]}));
    $graph->add_node($interact[1]) if(!$subset_file || defined($subset{$interact[1]}));

    # Skip if SNP distance more than $max_dist, or LD less than $min_LD
    next if($interact[2] >= $max_dist*1000 || $interact[$field-1] <= $min_LD);
    # Skip if NaN, +Inf, -Inf, ...
    my $x = Math::BigInt->new($interact[$field-1]);
    next if($x->is_nan() || $x->is_inf('+') || $x->is_inf('-'));
    # Skip if not on the subset file
    next unless( !$subset_file || (defined($subset{$interact[0]}) &&  defined($subset{$interact[1]})) );

    $edge = $graph->add_edge_once($interact[0], $interact[1]);
    $edge->set_attribute('label', $interact[$field-1].' / '.$interact[2]) if($debug);
}
$FILE->close;


if(!$in_sorted){
    # Print stats for read nodes and edges
    print(STDERR "### Parsed ".$cnt." interactions between ".$graph->nodes()." nodes.\n");

    # Print out (and delete) unconnected nodes
    foreach $node ( $graph->nodes() ){
	$n_edges = $node->edges();
	if($n_edges == 0){
	    print $node->label."\n";
	    $graph->del_node($node);
	}
    }
}


# Print stats for actually connected nodes and edges
print(STDERR "### Kept ".$graph->edges()." interactions between ".$graph->nodes()." nodes.\n");


# DEBUG
if($debug){
    print(STDERR "### Initial network\n");
    print(STDERR $graph->as_ascii());
}


while(1){
    # Find top-connected node
    $max_n_edges = 0;
    foreach $node ( $graph->nodes() ){
	$n_edges = $node->edges();
	if($n_edges > $max_n_edges){
	    $most_conected_node = $node->name();
	    $max_n_edges = $n_edges;
	}
    }

    # If top node has no edge, break!
    last if($max_n_edges < 1);

    $graph->del_node($most_conected_node);

    if($debug){
	print(STDERR "### Pruned network after most connected node (".$most_conected_node.") removed!\n");
	print(STDERR $graph->as_ascii());
    }
}


# DEBUG
if($debug){
    print(STDERR "### Final network!\n");
    print(STDERR $graph->as_ascii());
}


for $node ($graph->nodes()){
    print $node->label."\n";
}

exit();