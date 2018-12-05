if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'editorconfig/editorconfig-vim'
Plug 'sheerun/vim-polyglot'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'mhinz/vim-signify'
Plug 'easymotion/vim-easymotion'
Plug 'mhinz/vim-grepper'
Plug 'ahw/vim-pbcopy'
Plug 'scrooloose/nerdcommenter'
Plug 'terryma/vim-multiple-cursors'
Plug 'joshdick/onedark.vim'
Plug 'vim-airline/vim-airline'
Plug 'junegunn/goyo.vim'
Plug 'tjvr/vim-nearley'
Plug 'valloric/youcompleteme', { 'do': './install.py' }

Plug 'leafgarland/typescript-vim'
" Plug 'quramy/vim-js-pretty-template'
" Plug 'herringtondarkholme/yats.vim'
Plug 'posva/vim-vue'
Plug 'quramy/tsuquyomi'
Plug 'shougo/vimproc.vim', {'do' : 'make'}
Plug 'wincent/command-t', { 'do': 'cd ruby/command-t/ext/command-t && ruby extconf.rb && make'}

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

if (!exists('g:ycm_filetype_whitelist'))
  let g:ycm_filetype_whitelist = {'*': 1}
end

if (!exists('g:ycm_semantic_triggers'))
  let g:ycm_semantic_triggers = {}
end

let g:ycm_semantic_triggers['typescript'] = ['.']

if (exists('g:gui_oni'))
  let g:loaded_airline = 1
else
  if (has('autocmd') && !has('gui_running'))
    let s:white = { 'gui': '#ABB2BF', 'cterm': '145', 'cterm16' : '7' }
    " No `bg` setting
    " autocmd ColorScheme * call onedark#set_highlight('Normal', { 'fg': s:white })
  end

  colo onedark
  " colo space-vim-dark
end

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

let NERDTreeRespectWildIgnore = 1
let NERDTreeShowHidden = 1

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

map <leader>n :NERDTree <enter>
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
