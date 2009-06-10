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
my $parsed = Load($yaml);

my $passed = $parsed->{overall_results}{passed};
my $failed = $parsed->{overall_results}{failed};

PostNotification("Testrunner", 'test', "Tests on $branch", "$passed Passed, $failed Failed");
