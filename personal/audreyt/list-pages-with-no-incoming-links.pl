#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Socialtext;
use Socialtext::Hub;
use Socialtext::Workspace;
use Socialtext::CategoryPlugin;
use Socialtext::BacklinksPlugin;

my ($tag, $ws_name);
GetOptions(
    'w|workspace=s' => \$ws_name,
    't|tag=s'       => \$tag,
);

($ws_name and $tag) or die "Example $0 -w admin -t welcome\n";

my $ws = Socialtext::Workspace->new(name => $ws_name);
my $hub = Socialtext::Hub->new( current_workspace => $ws );

my @pages = Socialtext::CategoryPlugin->new(hub => $hub)->get_pages_for_category( $tag );
my $backlinks = Socialtext::BacklinksPlugin->new( hub => $hub );

for my $page ( @pages ) {
    my $backlinks = $backlinks->all_backlinks_for_page($page);
    next if @$backlinks;
    print $page->metadata->Subject, $/;
}

