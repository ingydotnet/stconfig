#!/bin/bash
cd `dirname $0`;
./grab-data.pl
./create-charts.pl
