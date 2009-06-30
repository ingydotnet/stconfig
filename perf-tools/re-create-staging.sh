#!/bin/bash
cd `dirname $0`;
./grab-data.pl --filter='www2 perf' --datafile='staging-perf.yaml'
./create-charts.pl --datafile='staging-perf.yaml' --prefix='staging'
