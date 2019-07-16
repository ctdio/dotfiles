if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'editorconfig/editorconfig-vim'
Plug 'sheerun/vim-polyglot'
Plug 'mhinz/vim-signify'
Plug 'easymotion/vim-easymotion'
Plug 'ahw/vim-pbcopy'
Plug 'scrooloose/nerdcommenter'
Plug 'joshdick/onedark.vim'
Plug 'vim-airline/vim-airline'
Plug 'junegunn/goyo.vim'

Plug 'mhinz/vim-grepper'
Plug 'wincent/command-t', { 'do': 'cd ruby/command-t/ext/command-t && ruby extconf.rb && make'}

Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install() }}

Plug 'tjvr/vim-nearley'
Plug 'elixir-editors/vim-elixir'
Plug 'leafgarland/typescript-vim'
Plug 'posva/vim-vue'

call plug#end()

" optimization: only use git for signify
let g:signify_vcs_list = [ 'git' ]

filetype plugin indent on

set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set number
set linebreak

set nocompatible

colo onedark

" COC config
set hidden
set nobackup
set nowritebackup

set cmdheight=2
set shortmess+=c

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nmap <leader>rn <Plug>(coc-rename)

nmap <leader>ac  <Plug>(coc-codeaction)

inoremap <silent><expr> <c-space> coc#refresh()

syntax on

set cursorline
set colorcolumn=80

set backspace=indent,eol,start

let g:ctrlp_working_path_mode='r'
set wildignore+=*/tmp
set wildignore+=*/node_modules
set wildignore+=*/elm-stuff
set wildignore+=*/dist
set wildignore+=*/static
set wildignore+=*.so
set wildignore+=*.sw*
set wildignore+=*.zip

set wildmode=longest,list,full
set wildmenu

let g:netrw_liststyle = 3
let g:netrw_banner = 0
let g:netrw_winsize = 20

let g:javascript_plugin_jsdoc = 1
let g:javascript_plugin_flow = 1

" favor custom typescript syntax file over polyglot
let g:polyglot_disabled = [ 'typescript' ]

autocmd BufWritePre * :%s/\s\+$//e

" custom mappings
map , <leader>

" ctrl p to CommandT
map <c-p> :CommandT <enter>
map <c-a> :Grepper <enter>

map <leader>n :Lexplore <enter>
map <leader>a <Plug>(easymotion-s)
map <leader>s <Plug>(easymotion-s2)

map f <Plug>(easymotion-s2)

" grepper
let g:grepper = {}
let g:grepper.ag = { 'grepperg': 'ag --vimgrep' }

" copy selected text to clipboard
let g:vim_pbcopy_local_cmd = 'pbcopy'

set clipboard=unnamed

" Enable zsh shell
set shell=zsh\ -l

let g:ruby_host_prog="/home/charlie/.rbenv/versions/2.6.0/bin/neovim-ruby-host"
