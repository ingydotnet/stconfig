" No use for Ex mode; use Q for formatting.
map Q gq

map ` !G perl -MText::Autoformat -eautoformat<CR>))
map `j <C-W>j<C-w>_
map `k <C-W>k<C-w>_
map + <C-^>

imap  
 
" Fix delete
if &term == "xterm-color"
  set t_kb=
  fixdel
endif

map \] :up<UP><CR>
map \[ :<UP><CR>

map \\\ :noh<CR>:set nopaste<CR>:set nolist<CR>
map \q :q!<CR>
map \p :set paste<CR>
map \v :!vim .vimrc<CR>:so .vimrc<CR>
map \V :!vim ~/.vimrc<CR>:so ~/.vimrc<CR>
map \vf :!vim <cword><CR>:so <cword><CR>
map \m ggouse Moose;<CR>use namespace::clean -except => 'meta';<CR><ESC>GO__PACKAGE__->meta->make_immutable;<ESC>
map \P Go<CR>__END__<CR><CR>=head1 NAME<CR><CR>Socialtext::Narwhal - Creature of the Sea<CR><CR>=head1 SYNOPSIS<CR><CR>  use Socialtext::Narwhal<CR>$Narwhal->hunt<CR><CR>=head1 DESCRIPTION<CR><CR>Is like a unicorn, but real.<CR><CR>=cut

map \# :s/^/# / <CR> :noh <CR>
map \\# :s/^# // <CR> :noh <CR>
map \/ :s,^,// , <CR> :noh <CR>
map \\/ :s,^// ,, <CR> :noh <CR>

map \1 :w<CR>
map \2 :up<CR>:!perlcheck -Ilib %<CR>
map \3 :up<CR>:call RunLastTest()<CR>
map \5 :up<CR>:call RunLastTest()<CR>
map \6 :up<CR>:!make all install<CR>
map \7 :up<CR>:!make<CR>:call RunLastTest()<CR>

map \d :.!echo -n 'date:    '; date<CR>
map \h :up<CR>:call TryPerlCompile()<CR>

" Like ^] (tag lookup), but only in this file.  Sort of.  It looks for
" 'sub <cword>'.
map \<C-]> /<C-r>='\<sub ' . expand('<cword>') . '\>'<CR><CR>

map \gf :sp <cword><CR>

map \K :!LC_ALL=C perldoc %<CR>

noremap <C-l> :nohls<CR><C-l>
noremap! <C-l> <Esc>:nohls<CR><C-l>a
