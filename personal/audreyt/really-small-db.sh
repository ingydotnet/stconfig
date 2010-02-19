#!/bin/sh
cd $HOME/src/st/socialtext/nlw && perl dev-bin/really-big-db.pl -a 2 -u 1024 -p 20 -e 50 -g 20 --group-ws-ratio 1 --group-user-ratio 3 --view-event-ratio 0 -s 100
