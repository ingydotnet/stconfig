#!/usr/bin/perl
use strict;
use warnings;
use YAML qw/LoadFile/;
use URI::GoogleChart;
use Getopt::Long;

my $datafile = 'www-perf.yaml';
my $prefix   = 'prod';
GetOptions(
    'datafile=s' => \$datafile,
    'prefix=s'   => \$prefix,
);

my $data = LoadFile($datafile);
$data = [ sort {$b->{date} cmp $a->{date}} @$data ];

my @charts;
my @total_ffs;
my $day_count = 0;
my %path_times;
my $first_piechart;
for my $day (@$data) {
    my @day_pie_data;
    my $ffs_total = 0;
    for my $path (keys %{ $day->{paths} }) {
        my $pd = $day->{paths}{$path};
        push @day_pie_data, {
            median => $pd->{'median'},
            label  => $path,
        };
        $ffs_total += $pd->{'ffs score'} || 0;
        $path_times{$path} += $pd->{median};
    }
    @day_pie_data = sort { $b->{median} <=> $a->{median} } @day_pie_data;
    @day_pie_data = splice @day_pie_data, 0, 10;

    my $chart = URI::GoogleChart->new("pie", 600, 300,
        rotate => -90,
        data => [ map { $_->{median} } @day_pie_data ],
        label => [ map { $_->{label} } @day_pie_data ],
    );
    $first_piechart ||= $chart;

    if ($day_count < 5) {
        push @charts, {
            name => "$day->{date} median times",
            uri => $chart,
        };
    };
    $day_count++;

    unshift @total_ffs, $ffs_total;
}

my @paths = sort { $path_times{$b} <=> $path_times{$a} } keys %path_times;
my @slow_paths = splice @paths, 0, 10;

unshift @charts, _slow_path_chart($data, \@slow_paths);
my @recent_data = splice @$data, 0, 5;
unshift @charts, _slow_path_chart(\@recent_data, \@slow_paths);


my $ffs_sparkchart = URI::GoogleChart->new("sparklines", 280, 100,
    data => \@total_ffs,
    title => 'Relative request load over time',
);
unshift @charts, {
    name => 'FFS over time',
    uri  => $ffs_sparkchart,
};

my $base_dir = "$ENV{HOME}/public_html/perf";
mkdir $base_dir;
open(my $ffsfh, ">$base_dir/$prefix-ffs.html") or die $!;
print $ffsfh qq{<html><body><img src="$ffs_sparkchart"></body></html>};
close $ffsfh;

open(my $fh, ">$base_dir/$prefix.html") or die $!;
print $fh <<EOT;
<html>
  <head><title>Perf data</title></head>
  <body>
EOT
for my $c (@charts) {
    my $name = $c->{name};
    my $uri = $c->{uri};
    print $fh qq{<h2>$name</h2>\n<img src="$uri"><br />\n};
}
print $fh "</body>\n</html>\n";
close $fh;

exit;

sub _slow_path_chart {
    my $data = shift;
    my $paths = shift;
    my $num_days = scalar(@$data);
    my @data;
    my @colors = qw(ff0000 00ff00 0000ff ffff00 00ffff ff00ff
                    770000 007700 000077 777700 007777 770077);
    for my $p (@$paths) {
        my @pathdata;
        for my $day (@$data) {
            my $d = $day->{paths}{$p};
            my $ffs = ($d->{calls}||0) * ($d->{median}||0);
            unshift @pathdata, $ffs;
        }
        push @data, \@pathdata;
    }
    my $title = "Slowest paths over time (past $num_days days)";
    my $chart = URI::GoogleChart->new("lines", 900, 300,
        data => \@data,
        label => $paths,
        color => \@colors,
        range_show => 'left',
        title => $title,
    );
    return {
        name => $title,
        uri  => $chart,
    };
}



__DATA__

if (0) {
$chart = URI::GoogleChart->new("lines", 600, 300,
    data => [
        [100, 700],
        [700, 100],
    ],
    range_show => 'left',
    range_round => 1,
    title => 'o hai',
    label => ['up', 'down'],
    color => [qw/red blue/],
);
}

