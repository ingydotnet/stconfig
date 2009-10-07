#!/usr/bin/speedy
#
# Prereq: aptitude install speedy-cgi-perl
#
use strict;
use warnings;
use lib '/home/audreyt/src/st/socialtext/nlw/lib';

use Socialtext::Cache;
use Cache::MemoryCache;

BEGIN {
    $Socialtext::Cache::DefaultExpiresIn = '30m';
    $Socialtext::Cache::CacheClass = 'Cache::MemoryCache';
}

use Socialtext::String;
use Socialtext::Pluggable::Adapter;
use Socialtext::Pluggable::Plugin;
use Socialtext::Pluggable::Plugin::Agile;
use XML::Simple;
use CGI ':standard';

our $agile ||= Socialtext::Pluggable::Plugin::Agile->new;

my $content = param('content') || '';

if ($content =~ /(\d+)/) {
    print header(-type => 'text/html', -charset => 'UTF-8');
    print link_bz($1);
}
else {
    print header(-type => 'text/plain', -charset => 'UTF-8');
    print $content;
}
exit;

sub link_bz {
    my $id = shift;
    my $desc = desc_for_id($id);
    return qq{<a title="$desc" href="https://bugs.socialtext.net:555/show_bug.cgi?id=$id">Bug $id</a>};
}

sub desc_for_id {
    my $id = shift;

    local $@;
    eval {
        my %bug = %{ XMLin(fetch_bug_xml_for_id($id))->{bug} } or die;
        my @fields = map {$_ ? "\u\L$_" : ()} @bug{qw/ bug_severity priority resolution bug_status /};
        push @fields, (split(/\s+/, $bug{assigned_to}{name}))[0] if $bug{bug_status} eq 'ASSIGNED';
        my $desc = Socialtext::String::html_escape( $bug{short_desc} );
        "$desc (" . join('&nbsp;', map { Socialtext::String::html_escape($_) } @fields) . ')';
    } or '';
}

sub fetch_bug_xml_for_id {
    my $id = shift;

    return $agile->_fetch_bug_xml(
        "id-$id" => {
            'field0-0-0' => 'bug_id',
            'type0-0-0'  => 'equals',
            'value0-0-0' => $id,
        }
    );
}

# vim: ft=perl
