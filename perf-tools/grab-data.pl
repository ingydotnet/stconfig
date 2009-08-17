#!/usr/bin/perl
use strict;
use warnings;
use Socialtext::Resting::Getopt qw/get_rester/;
use Socialtext::WikiObject;
use YAML qw/DumpFile/;
use Getopt::Long;

my $R = get_rester(workspace => 'dev-tasks',
    server => 'https://www2.socialtext.net');

my $filter = 'www perf';
my $datafile = 'www-perf.yaml';
GetOptions(
    'filter=s' => \$filter,
    'datafile=s' => \$datafile,
);

$R->accept('perl_hash');
my $pages = $R->get_taggedpages('perf blog');

$pages = [ map { $_->{name} } grep {$_->{name} =~ m/$filter/i} @$pages ];
my @recent = splice @$pages, 0, 45;

$R->accept('text/x.socialtext-wiki');
my @data;
for my $page (@recent) {
    my $wo = Socialtext::WikiObject->new(
        rester => $R, page => $page,
    );

    my $table = $wo->{items}[0]{'request summary'}{table};
    my $headings = shift @$table;

    (my $date = $page) =~ s/^.+\s//;
    my %daydata = (date => $date, paths => {});
    for my $row (@$table) {
        my $i = 0;
        my %rowdata;
        for my $col (@$headings) {
            $col =~ s/^\*(?:\% > )?(.+)\*$/$1/;
            $rowdata{lc $col} = $row->[$i++];
        }
        $rowdata{median} = 0 unless $rowdata{median} =~ m/^[\d.]+$/;
        unless (defined $rowdata{'ffs score'}) {
            $rowdata{'ffs score'} = $rowdata{calls} * $rowdata{'3s'} 
                                    * $rowdata{median};
        }
        my $path = delete $rowdata{path};
        $daydata{paths}{$path} = \%rowdata;
    }
    push @data, \%daydata;
}

DumpFile($datafile, \@data);
