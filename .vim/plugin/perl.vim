set formatoptions-=t

function! RunLastTest()
    if (expand('%:e') == 't')
        let $lasttestfile = expand('%')
        let $lasttestiswiki = 0
    elseif (expand('%:e') == 'wiki')
        let $lasttestfile = expand('%')
        let $lasttestiswiki = 1
    endif
    if (!strlen($lasttestfile))
       execute '!./' . expand('%')
    else
        if ($lasttestiswiki)
            !restart-apache-if-needed; TEST_LESS_VERBOSE=1 st-prove -v $lasttestfile
        else
            !TEST_LESS_VERBOSE=1 st-prove -v $lasttestfile
        endif
    endif
endf

" This lets you put a #: line at the top of some file you're working on with a
" command you'd like executed (maybe a GET or something?) each time you say
" \h.  It's a baby step before writing/running a test, and a little faster.
function! TryPerlCompile()
    let s:ext = expand('%:e')
    let s:command = 'perl -c -Ilib ' . expand('%') . ' && nlwctl -1'
    if (getline(1) =~ '^#:')
        let s:command = s:command . ' && '
                    \ . substitute(getline(1), '^#:', '', '')
    endif
    if (s:ext == 'pm' || s:ext == 'pl' || s:ext == 't' || s:ext == '')
        exec '!' . s:command
    endif
endf

function! QuietPerlCompile()
    let s:old_sp = &sp
    set sp=>&
    silent make
    let &sp = s:old_sp

    cwin
    if (! v:shell_error)
        echo 'syntax ok'
    endif
endf

" Return the module file corresponding to this test file, or the primary test
" corresponding to this module.  Note that this will find Foo.pm from
" Foo-bar.t, but not the other way round.
function! AlternateTestFile(file)
    if (match(a:file, '\.t$') != -1)
        return substitute(substitute(a:file, '^t/', 'lib/', ''), '\(-[^.]\+\)\?\.t$', '.pm', 'm')
    else
        return substitute(substitute(a:file, '^lib/', 't/', ''), '\.pm$', '.t', '')
    endif
endf

" I get tired of typing ':ta Socialtext::<TAB>' and seeing that huge list
" scroll by.  :Stag works like :tag, except it prepends 'Socialtext::' to your
" argument.  :Sstag has the same relationship with :stag.
command! -nargs=1 -complete=custom,CompSTag Stag  execute 'tag'  'Socialtext::' . <q-args>
command! -nargs=1 -complete=custom,CompSTag Sstag execute 'stag' 'Socialtext::' . <q-args>

function! CompSTag(ArgLead, CmdLine, CursorPos)
    return system("stags tags")
endf
