#!/usr/bin/perl
use warnings;
use strict;

use YAML qw/Load LoadFile DumpFile/;
use LWP::Simple;
use FindBin;
use List::MoreUtils qw/any/;

my $branch = shift || 'master';
my $state_file = "$FindBin::Bin/testrunner-bob.yaml";

my $yaml = get("http://testrunner.socialtext.net/stci/$branch/in-progress/publishing-vars.yaml");
exit unless $yaml;
my $parsed = Load($yaml);
exit unless $parsed and $parsed->{overall_results}{total};

my $total = $parsed->{overall_results}{total};
my $passed = $parsed->{overall_results}{passed};
my $failed = $parsed->{overall_results}{failed};
my $failed_pct = sprintf '%0.2f', $failed*100/$total;

my $cur = {total => $total, version => $parsed->{version_string}};

my $state = {};
if (-e $state_file && -r _) {
    $state = LoadFile($state_file);
}
$state->{$branch} ||= {total => '', version => ''};

if (
    any { $state->{$branch}{$_} ne $cur->{$_} } qw(total version)
) {
    my $msg = "TESTRUNNER UPDATE for ${branch}: pass=$passed, fail=$failed($failed_pct%), total=$total";
    warn $msg;
    my $rv = system(qw(wget -q -O /dev/null), "https://irc.socialtext.net:450/bob/$msg");
    warn "rv $rv";
}
$state->{$branch} = $cur;

DumpFile("$state_file.tmp", $state);
rename "$state_file.tmp" => $state_file;
