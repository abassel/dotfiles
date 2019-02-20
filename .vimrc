color desert


set number
set et
set sw=2
set smarttab
" set smartindent
set incsearch
set hlsearch
set smartcase
set cursorline
" set cursorcolumn
set title
set ruler
set showmode
set showcmd
set ai " Automatically set the indent of a new line (local to buffer)
set tags=./tags;
set grepprg=ack
" set text width so gq-like commands wrap at 100 chars
set tw=100
" new regex engine seems to be really slow, particularly with ruby. Set to previous one
set re=1

set equalalways " Multiple windows, when created, are equal in size
set splitbelow splitright

# https://stackoverflow.com/questions/2514445/turning-off-auto-indent-when-pasting-text-into-vim
set paste

set mouse=a

set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'airblade/vim-gitgutter'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'itchyny/lightline.vim'
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
Plugin 'mattn/emmet-vim'
Plugin 'scrooloose/nerdtree'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'tpope/vim-eunuch'
Plugin 'tpope/vim-surround'
Plugin 'w0rp/ale'
call vundle#end()
filetype plugin indent on

