" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim

call plug#begin('~/.vim/plugged')

Plug 'editorconfig/editorconfig-vim'
Plug 'sheerun/vim-polyglot'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'mhinz/vim-signify'
Plug 'easymotion/vim-easymotion'
Plug 'xolox/vim-misc'
Plug 'xolox/vim-notes'
Plug 'mhinz/vim-grepper'
Plug 'ahw/vim-pbcopy'

" NOTE: go to where this plugin was installed '~/.vim/plugged/command-t' and
" run 'make rake'
Plug 'wincent/command-t'

call plug#end()            " required

filetype plugin indent on    " required

set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set number

set nocompatible              " be iMproved, required

filetype off                  " required
colo delek
syntax on

let g:ctrlp_working_path_mode='r'
set wildignore+=**/tmp
set wildignore+=**/node_modules
set wildignore+=**/dist
set wildignore+=**/static
set wildignore+=*.so
set wildignore+=*.sw*
set wildignore+=*.zip

set wildmode=longest,list,full
set wildmenu

let g:javascript_plugin_jsdoc = 1

autocmd BufWritePre * :%s/\s\+$//e

" custom mappings
map , <leader>

" ctrl p to CommandT
map <c-p> :CommandT <enter>

map <leader>n :NERDTree <enter>
map <leader>a <Plug>(easymotion-s)
map <leader>s <Plug>(easymotion-s2)

" grepper
let g:grepper = {}
let g:grepper.ag = { 'grepperg': 'git grep -nI' }
"
" copy selected text to clipboard
let g:vim_pbcopy_local_cmd = "pbcopy"
