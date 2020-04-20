set showmode
syntax on
set nu
set et
set ts=2
set sw=2

let @c='I#j'
let @d='"_d'
let @x='"_x'
set tabpagemax=20
set hlsearch

"modelines are insecure
set modelines=0
runtime ftplugin/man.vim
source $VIMRUNTIME/ftplugin/man.vim
set ruler
set backspace=indent,eol,start

"let tracesyntaxfile= "~/tracesyntax.vim"
au BufRead,BufNewFile *.trc set filetype=msystrace
au! Syntax msystrace source ~/tracesyntax.vim
au BufRead,BufNewFile *.ec set filetype=msyslog
au! Syntax msyslog source ~/logsyntax.vim

au BufRead,BufNewFile *.json set filetype=javascript
au BufRead,BufNewFile *.pp set filetype=ruby
au FileType python setl sw=4 ts=4
au FileType make setl noet

" some cscope hacks {
  nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
  nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
  nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
  nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
  nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
  nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
  nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
  nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>
" }

" Awesome alias'

" If in a split pane, expands the current pane
let @w='^[10^W<'

" Inserts a hash comment at the beginning of the current line
let @c='I#j'

" Same as regular 'd' in vim, but instead of copying to the default register, it blackholes the text
let @d='"_d'

" Same thing, just with x
let @x='"_x'

" the WhatTheFunc function { "
" This function will help you determine/go to the parent function of the current cursor position
" Designed for C, still useful in other languages
fun! WhatTheFunc(shouldMove)
  let flags = 'bWn'

  if a:shouldMove == 1
    let flags = 'bW'
  endif

  let language = &filetype
  if language == "python"
    let linenum = search ( "^ *def ", flags)
  else
    " do C by default since C syntax is handy with other languages

    " This is matching lines that don't begin with tabs, hashtags, spaces, {}
    " brackets, or colons. It also skips lines that end with a : and 0 or more
    " spaces to avert goto lines posing as functions
    let linenum = search( "^[^ A-Z\t#/{}].*[^:]\s*$", flags)
  endif

  echo linenum ':' getline( linenum )
endfun

map <Leader>f :call WhatTheFunc(0) <CR>
map <Leader>F :call WhatTheFunc(1) <CR>
" }

"some search hacks {
" The idea here is that by default when you search for something in vim, it will
" jump to the location of the next match, which is annoying.  This next little
" hacklet will allow you to hit ',g' and get a set of matches without moving the
" cursor.
highlight SoftSearch ctermbg=black ctermfg=Green

fun! SoftSearch()
  let word = expand("<cword>")
  let do_soft_search = "match SoftSearch /" . word . "/"
  exec do_soft_search
endfun

map <Leader>g :call SoftSearch() <CR>
map <Leader>G :match none <CR>

" quick way to get input from : mode without making a mess
" does a search within the current function, sets the last-pattern to be that pattern
" if nothing is passed in, searches for the word at the current cursor position
fun! SearchInFunction(word)
  call SoftSearch()
  let stopline = search( "^[^ A-Z\t#/{}].*[^:]\s*$", "Wn")
  if empty(a:word)
    let word = expand("<cword>")
  else
    let word = a:word
  endif
  echo stopline
  let foo = search(  word , "W", line(stopline) )
  " sets the last pattern to be this word
  let @/ = word
  if foo == 0
    echo "no more matches"
  else
    echo "next match at line " . foo
  endif
endfun 

" 88 will search for the word at the current cursor position
" 88 will iterate within the same funciton, nN will iterate on that
" pattern as a normal match
map 88 :call SearchInFunction("") <CR>
" }

"some vimdiff hacks {

  nmap dg1 :diffget 1 <CR>
  nmap dp1 :diffput 1 <CR>
  nmap dg2 :diffget 2 <CR>
  nmap dp2 :diffput 2 <CR>
  nmap dg3 :diffget 3 <CR>
  nmap dp3 :diffput 3 <CR>
  nmap dg4 :diffget 4 <CR>
  nmap dp4 :diffput 4 <CR>

" from stackoverflow: 
  set laststatus=2                             " always show statusbar  
  set statusline=  
  set statusline+=%-10.3n\                     " buffer number  
  set statusline+=%f\                          " filename   
  "set statusline+=%h%m%r%w                     " status flags  
  set statusline+=\[%{strlen(&ft)?&ft:'none'}] " file type  
  set statusline+=%=                           " right align remainder  
  set statusline+=0x%-8B                       " character value  
  set statusline+=%-14(%l,%c%V%)               " line, character  
  set statusline+=%<%P                         " file position  
"}

map mm :!make -j6 -C ~/code/Core;<CR>;
nmap <C-\>rr :cs reset<CR>
nmap <C-\>a :cs add ~/code/Core ~/code/Core<CR>
nmap <C-\>r :!cd ~/code/Core;cscope -bR;<CR>
" :cs find d <C-R>=expand("<cword>")<CR><CR>
nmap ,r :/\e[0;31m<CR>

" gj and gk are better
nmap j gj
nmap k gk

" better plugin discoverability see https://github.com/tpope/vim-pathogen
call pathogen#infect()
call pathogen#helptags()

"let g:pymode_python = "python3"
"let g:pymode_lint_on_write = 0
"let g:pymode_folding = 0
"let g:pymode_syntax = 1
"let g:pymode_indent = 0
"let g:pymode_rope_completion = 1
" allows pymode docs to be called twice in a session lol
"set ma

" nerdtree time
nmap <Leader>no :NERDTree<CR>
nmap <Leader>nc :NERDTreeClose<CR>

" minibufexpl
let g:miniBufExplVSplit = 20
nmap <Leader>mo :MBEOpen<CR>
nmap <Leader>mc :MBEClose<CR>

"buf stuff
nmap <Leader>mn :bn!<cr>
nmap <Leader>mp :bp!<cr>
nmap <Leader>mq :bd<cr>

" syntastic
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*
"
"let g:syntastic_loc_list_height=2
"let g:syntastic_always_populate_loc_list = 1
"let g:syntastic_auto_loc_list = 1
"let g:syntastic_check_on_open = 1
"let g:syntastic_check_on_wq = 0
"let g:syntastic_python_checkers=['pylint', 'pep8', 'python3']
"let g:syntastic_python_pylint_args="--disable broad-except,invalid-name"

" ale
let g:ale_python_auto_pipenv = 1
let g:ale_python_pylint_auto_pipenv = 1
let g:ale_python_pylint_options = "--max-line-length 100 --rcfile ~/.pylint"
let g:ale_list_window_size = 5
let g:ale_open_list = 1
let g:ale_set_highlights = 0
let g:ale_linters = {
\  'python': ['pylint', 'python'],
\  'yaml': []
\}

nmap <Leader>ln :lnext<CR>
nmap <Leader>lp :lprevious<CR>

" https://vi.stackexchange.com/questions/177/what-is-the-purpose-of-swap-files
set directory^=$HOME/.vim/swpfiles//
" good bye annoying bell
set noeb
set vb
