require('plugins')
vim.cmd([[
set et
set showmode
syntax on
set nu
set ts=2
set sw=2

let @c='I#j'
let @d='"_d'
let @x='"_x'

filetype plugin indent on
set ruler
set backspace=indent,eol,start

au FileType python setl sw=4 ts=4
au FileType make setl noet
au FileType go setl noet
au FileType js setl noet
au FileType ts setl noet
au FileType sh setl et
au FileType jinja setl et
au FileType conf setl et
au BufNewFile,BufRead Jenkinsfile* setf groovy

set tabpagemax=20
set hlsearch
set formatoptions-=cro
au BufRead,BufNewFile *.hcl set filetype=tf
au BufRead,BufNewFile *.pkr.hcl set filetype=tf

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
nmap <Leader>dg1 :diffget 1 <CR>
nmap <Leader>dp1 :diffput 1 <CR>
nmap <Leader>dg2 :diffget 2 <CR>
nmap <Leader>dp2 :diffput 2 <CR>
nmap <Leader>dg3 :diffget 3 <CR>
nmap <Leader>dp3 :diffput 3 <CR>
nmap <Leader>dg4 :diffget 4 <CR>
nmap <Leader>dp4 :diffput 4 <CR>

" from stackoverflow: 
set laststatus=2                             " always show statusbar  
set statusline=  
set statusline+=%-10.3n\                     " buffer number  
set statusline+=%f\                          " filename   
"set statusline+=%h%m%r%w                     " status flags  
set statusline+=\[%{strlen(&ft)?&ft:'none'}] " file type  
set statusline+=%=                           " right align remainder  
" set statusline+=[%3{codeium#GetStatusString()}\ ]\   " codeium!
set statusline+=0x%-8B                       " character value  
set statusline+=%-14(%l,%c%V%)               " line, character  
set statusline+=%<%P                         " file position  
nmap j gj
nmap k gk
let g:ale_python_auto_pipenv = 1
let g:ale_python_pylint_auto_pipenv = 1
let g:ale_python_pylint_options = "--max-line-length 100 --ignore-missing-docstrings"
let g:ale_python_mypy_options = "--strict --ignore-missing-imports" " otherwise it will yell if third party stuff isn't typed. pylint can fill the gap
let g:ale_list_window_size = 5
let g:ale_open_list = 1
let g:ale_set_highlights = 0
let g:ale_floating_preview = 1
" ale syntax highlighting sucks
let g:ale_linters = {
\  'python': ['pylint', 'mypy', 'python'],
\  'go': ['gofmt', 'govet', 'golangci-lint'], 
\  'yaml': [],
\  'markdown': ['remark']
\}
let g:ale_fixers = {
\  'terraform': ['terraform'],
\  'python': ['black'],
\  'lua': ['stylua'],
\}
let g:ale_go_golangci_lint_options = "2>&1"
let g:ale_go_golangci_lint_package = 1
let g:ale_fix_on_save = 1

nmap <Leader>h :ALEHover<CR>
nmap <Leader>af :ALEFix<CR>
nmap <Leader>tfb :Telescope file_browser<CR>
nmap <Leader>tp :Telescope projects<CR>
nmap <Leader>fb :Buffers<CR>

nmap <Leader>ln :lnext<CR>
nmap <Leader>lp :lprevious<CR>
nmap <Leader>lf :lfirst<CR>

nmap <Leader>an :ALENext -wrap -error<CR>
nmap <Leader>ap :ALEPrevious -wrap -error<CR>

" https://vi.stackexchange.com/questions/177/what-is-the-purpose-of-swap-files
set directory^=$HOME/.vim/swpfiles//
set noeb
set novb
set noautoindent " makes pasting damn near impossible, this positioning overrides all stupid, but well meaning autoindents imported from modules
" stole this from the internet https://vim.fandom.com/wiki/Different_syntax_highlighting_within_regions_of_a_file
function! TextEnableCodeSnip(filetype,start,end,textSnipHl) abort
  let ft=toupper(a:filetype)
  let group='textGroup'.ft
  if exists('b:current_syntax')
    let s:current_syntax=b:current_syntax
    " Remove current syntax definition, as some syntax files (e.g. cpp.vim)
    " do nothing if b:current_syntax is defined.
    unlet b:current_syntax
  endif
  execute 'syntax include @'.group.' syntax/'.a:filetype.'.vim'
  try
    execute 'syntax include @'.group.' after/syntax/'.a:filetype.'.vim'
  catch
  endtry
  if exists('s:current_syntax')
    let b:current_syntax=s:current_syntax
  else
    unlet b:current_syntax
  endif
  execute 'syntax region textSnip'.ft.'
  \ matchgroup='.a:textSnipHl.'
  \ keepend
  \ start="'.a:start.'" end="'.a:end.'"
  \ contains=@'.group
endfunction
au FileType groovy    call TextEnableCodeSnip( 'yaml' , 'yaml \"\"\"', '\"\"\"', 'yamlComment')
" using bash to trick treesitter
au FileType groovy    call TextEnableCodeSnip( 'bash' , 'sh \"\"\"', '\"\"\"', 'shComment')
au FileType groovy    call TextEnableCodeSnip( 'yaml' , "yaml '''", "'''", 'yamlComment')
" using bash to trick treesitter
au FileType groovy    call TextEnableCodeSnip( 'bash' , "sh '''", "'''", 'shComment')
au FileType markdown  call TextEnableCodeSnip( 'bash' , "```sh", "```", 'shComment') 
au FileType markdown  call TextEnableCodeSnip( 'groovy' , "```groovy", "```", 'groovyComment') 
au FileType markdown  call TextEnableCodeSnip( 'bash' , "```bash", "```", 'shComment') 
]])

require("telescope").setup {
  find_files = {
    hidden = true
  },
  extensions = {
    file_browser = {
      theme = "ivy",
    },
    projects = {},
  },
}
require('telescope').load_extension('projects')
require("telescope").load_extension "file_browser"
