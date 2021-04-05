" minpac, should make package management much easier
" minpac only needs to run when you want it to run, it does all the work of checking out the code
" and loading the plugins
function! PackInit() abort
  packadd minpac

  call minpac#init()
  call minpac#add('k-takata/minpac', {'type': 'opt'})
  call minpac#add('chimay/wheel', { 'type' : 'start' })
endfunction

" Define user commands for updating/cleaning the plugins.
" Each of them calls PackInit() to load minpac and register
" the information of plugins, then performs the task.
command! PackUpdate call PackInit() | call minpac#update()
command! PackClean  call PackInit() | call minpac#clean()
command! PackStatus packadd minpac | call minpac#status()

" better plugin discoverability see https://github.com/tpope/vim-pathogen
call pathogen#infect()
call pathogen#helptags()


" this overrides a bunch of flags, so we put it first so that it loses precedence
set paste
set autoindent
set et
set showmode
syntax on
set nu
set ts=2
set sw=2

let @c='I#j'
let @d='"_d'
let @x='"_x'
set tabpagemax=20
set hlsearch
set formatoptions-=cro

"modelines are insecure
set modelines=0
runtime ftplugin/man.vim
source $VIMRUNTIME/ftplugin/man.vim
set ruler
set backspace=indent,eol,start

" have encountered some plugins that need this on, leaving it in just in case
filetype plugin indent on

au BufRead,BufNewFile *.pp set filetype=ruby
au BufRead,BufNewFile *.yml.j2 set filetype=yaml.jinja

"au BufRead,BufNewFile *.tf set filetype=terraform
au FileType python setl sw=4 ts=4
au FileType make setl noet
au FileType go setl noet
au FileType js setl noet
au FileType ts setl noet
au FileType sh setl et
au FileType jinja setl et
au FileType conf setl et

" some cscope hacks {
  nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
  nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
  nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
  nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
  nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
  nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
  nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
  nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>
  nmap <C-\>a :cs add .<CR>
  nmap <C-\>r :cs reset <CR>
" }

" for working with cscope
nmap <Leader>ln :lnext<CR>
nmap <Leader>lp :lprevious<CR>
nmap <Leader>lf :lfirst<CR>


" Awesome alias'

" If in a split pane, expands the current pane
let @w='^[10^W<'

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
  let @/=word
  let do_soft_search = "match SoftSearch /" . word . "/"
  exec do_soft_search
endfun

map <Leader>g :call SoftSearch() <CR>
map <Leader>G :match none <CR> :noh <CR>

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
endfun 

" will search for the word at the current cursor position
" will iterate within the same funciton, nN will iterate on that
" pattern as a normal match
map <Leader>H :call SearchInFunction("") <CR>
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

"}

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

" in case you want to search for red text in an error log 
nmap ,r :/\e[0;31m<CR>

" gj and gk are better
nmap j gj
nmap k gk

" nerdtree time
nmap <Leader>no :NERDTree<CR>
nmap <Leader>nc :NERDTreeClose<CR>

" ale
let g:ale_python_auto_pipenv = 1
let g:ale_python_pylint_auto_pipenv = 1
let g:ale_python_pylint_options = "--max-line-length 100 --rcfile ~/.pylint"
let g:ale_list_window_size = 5
let g:ale_open_list = 1
let g:ale_set_highlights = 0
" ale syntax highlighting sucks
let g:ale_linters = {
\  'python': ['pylint', 'python'],
\  'go': ['gofmt', 'govet', 'golangci-lint'], 
\  'yaml': [] 
\}

" the expectation here is that unless you program a per-repo .golangci-lint
" file, everything gets used
let g:ale_go_golangci_lint_options = "2>&1"
let g:ale_go_golangci_lint_package = 1
let g:ale_languagetool_options='-d EN_QUOTES -l en-US'

" https://vi.stackexchange.com/questions/177/what-is-the-purpose-of-swap-files
set directory^=$HOME/.vim/swpfiles//

" good bye annoying bell
set noeb
set novb
