#!/usr/bin/speedy
#
# Prereq: aptitude install speedy-cgi-perl
#
use strict;
use warnings;
use lib '/home/audreyt/src/st/socialtext/nlw/lib';

use Socialtext::String;
use Socialtext::Pluggable::Adapter;
use Socialtext::Pluggable::Plugin;
use Socialtext::Pluggable::Plugin::Agile;
use XML::Simple;
use CGI ':standard';

print header(-type => 'text/plain', -charset => 'UTF-8');

our $agile ||= Socialtext::Pluggable::Plugin::Agile->new;

my $content = param('content') or exit;
$content =~ s/{bz:\s*(\d+)\s*}/link_bz($1)/eg;
print $content;
exit;

sub link_bz {
    my $id = shift;
    my $desc = desc_for_id($id);
    return qq{<a title="$desc" href="https://bugs.socialtext.net:555/show_bug.cgi?id=$id">Bug $id</a>};
}

sub desc_for_id {
    my $id = shift;
    eval {
        Socialtext::String::html_escape( XMLin(fetch_bug_xml_for_id($id))->{bug}{short_desc} )
    } or '';
}

sub fetch_bug_xml_for_id {
    my $id = shift;

    return Socialtext::Pluggable::Plugin::Agile->new->_fetch_bug_xml(
        "id-$id" => {
            'field0-0-0' => 'bug_id',
            'type0-0-0'  => 'equals',
            'value0-0-0' => $id,
        }
    );
}

