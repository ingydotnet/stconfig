export LANG="C"
TZ='America/Los_Angeles'; export TZ
# This is crufty.  As soon as everyone using bash has moved their personal
# stuff to ~/stconfig-{before,after}, we can slurp ~/.bashrc_st into this file
[ -r ~/.bashrc_st ] && source ~/.bashrc_st
[ -r ~/.stconfig-after ] && source ~/.stconfig-after
eval $(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib 2>/dev/null)
alias te="tail -f $HOME/.nlw/log/apache-perl/nlw-error.log"
alias ta="tail -f $HOME/.nlw/log/apache-perl/access.log"
alias tne="tail -f $HOME/.nlw/log/nginx/error.log"
alias tna="tail -f $HOME/.nlw/log/nginx/access.log"
alias bashrc='vim ~/.bashrc && source ~/.bashrc'
alias ll='ls -lAG'
alias resource='source ~/.bashrc'
alias l='ls -CF'
alias viz='vim z'
alias re="$HOME/src/st/socialtext/nlw/dev-bin/nlwctl restart"
export ST_TEST_SKIP_DB_CACHE=1
export EMAIL='Audrey Tang <audrey.tang@socialtext.com>'
alias nomake="touch -t 202010100000 $HOME/.nlw/root/storage/make_ran"
alias remake="touch $HOME/.nlw/root/storage/make_ran"
