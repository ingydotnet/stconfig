#!/usr/bin/perl
use warnings;
use strict;

use Mac::Growl ':all';
use YAML;
use LWP::Simple;

my $branch = shift || 'master';

my @notifications = qw(test);

RegisterNotifications("Testrunner", \@notifications, \@notifications);

my $yaml = get("http://testrunner.socialtext.net/stci/$branch/in-progress/publishing-vars.yaml");
exit unless $yaml;
my $parsed = Load($yaml);
exit unless $parsed and $parsed->{overall_results}{total};

my $passed = $parsed->{overall_results}{passed};
my $failed = $parsed->{overall_results}{failed};

# You can configure some growl styles to make the messages a different color
# based on the priority level
# -2 = very low (all tests passing)
# -1 = moderate
#  0 = normal
#  1 = high (some failures)
#  2 = emergency (> 2% failing after 4000 tests)

my $prio = -2;
$prio = 1 if $failed;
$prio = 2 if $passed and ($failed/$passed > 0.02 && $passed > 4000);

my $sticky = 0;

PostNotification("Testrunner", 'test', "Tests on $branch", "$passed Passed, $failed Failed", $sticky, $prio);
