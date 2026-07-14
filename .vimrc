" ============================================================================
" ~/.vimrc — cleaned & portable
" Betty-compliant C settings, vim-plug self-bootstrapping.
" On a new machine: copy this file, open vim, run :PlugInstall
" ============================================================================

" ----------------------------------------------------------------------------
" Leader key — MUST be defined before any mapping that uses <leader>
" ----------------------------------------------------------------------------
let mapleader=" "

" ----------------------------------------------------------------------------
" Vim-plug bootstrap (installs itself if missing)
" ----------------------------------------------------------------------------
let vim_plug_just_installed = 0
let vim_plug_path = expand('~/.vim/autoload/plug.vim')
if !filereadable(vim_plug_path)
	echo "Installing Vim-plug..."
	silent !mkdir -p ~/.vim/autoload
	silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
		\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	let vim_plug_just_installed = 1
endif
if vim_plug_just_installed
	:execute 'source '.fnameescape(vim_plug_path)
endif

" ----------------------------------------------------------------------------
" Plugins  (install: :PlugInstall   clean: :PlugClean   update: :PlugUpdate)
" ----------------------------------------------------------------------------
call plug#begin('~/.vim/plugged')

" Look & feel
Plug 'morhetz/gruvbox'                          " color scheme
Plug 'vim-airline/vim-airline'                  " status bar
Plug 'vim-airline/vim-airline-themes'
Plug 'ryanoasis/vim-devicons'                   " filetype icons (needs a Nerd Font)

" File navigation
Plug 'preservim/nerdtree'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'PhilRunninger/nerdtree-buffer-ops'
Plug 'PhilRunninger/nerdtree-visual-selection'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'                         " :Files :Rg :Buffers etc.

" Git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'                   " correct repo (not vim-scripts)

" Editing helpers
Plug 'tpope/vim-commentary'                     " gcc / <leader>/ to comment
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-eunuch'                         " :Rename :Delete :SudoWrite
Plug 'tmsvg/pear-tree'                          " auto-pair brackets/quotes
Plug 'mbbill/undotree'
Plug 'editorconfig/editorconfig-vim'

" Linting & completion (ALE replaces Syntastic AND YouCompleteMe)
Plug 'dense-analysis/ale'

" Syntax
Plug 'sheerun/vim-polyglot'
Plug 'frazrepo/vim-rainbow'

call plug#end()

" Install plugins automatically on first ever launch
if vim_plug_just_installed
	echo "Installing plugins, please ignore key map error messages"
	:PlugInstall
endif

" ----------------------------------------------------------------------------
" General settings
" ----------------------------------------------------------------------------
syntax enable
set encoding=utf-8
set number
set relativenumber
set nowrap
set mouse-=a
set visualbell
set noerrorbells
set cursorline
set scrolloff=3
set cmdheight=2
set updatetime=300
set shortmess+=c
set signcolumn=yes

" Default indentation (non-C files): 4-wide, real tabs
set tabstop=4
set shiftwidth=4
set softtabstop=4
set noexpandtab
set autoindent
set smartindent
set cindent

" Search
set hlsearch
set incsearch
set ignorecase
set smartcase

" Files & undo
set noswapfile
set nobackup
if has('persistent_undo')
	set undodir=~/.vim/undodir
	set undofile
	if !isdirectory(&undodir)
		call mkdir(&undodir, "p")
	endif
endif

" ----------------------------------------------------------------------------
" Betty / Linux-kernel style — C files only
" (per https://github.com/alx-tools/Betty/wiki/Tools:-Vim)
" ----------------------------------------------------------------------------
augroup betty_c
	autocmd!
	" 8-wide real tabs
	autocmd FileType c,cpp,h setlocal tabstop=8 shiftwidth=8 softtabstop=8 noexpandtab
	" visible 80-column limit
	autocmd FileType c,cpp,h setlocal colorcolumn=81
	" show trailing whitespace and space-indentation (Betty forbids both)
	autocmd FileType c,cpp,h setlocal list listchars=tab:\ \ ,trail:·,lead:·
augroup END

" Strip trailing whitespace on save for C files
autocmd BufWritePre *.c,*.h :%s/\s\+$//e

" ----------------------------------------------------------------------------
" Colors / theme
" ----------------------------------------------------------------------------
set background=dark
if has('gui_running') || (&term =~? 'xterm\|xterm-256\|screen-256\|mlterm\|fbterm')
	if !has('gui_running')
		let &t_Co = 256
	endif
	silent! colorscheme gruvbox
else
	silent! colorscheme delek
endif

" ----------------------------------------------------------------------------
" ALE — linting (replaces Syntastic) and completion (replaces YouCompleteMe)
" ----------------------------------------------------------------------------
let g:ale_completion_enabled = 1
set omnifunc=ale#completion#OmniFunc

" C: compile with the same flags the ALX checker uses
let g:ale_linters = {
	\ 'c': ['gcc'],
	\ 'python': ['pylint'],
	\ }
let g:ale_c_gcc_options = '-Wall -Wextra -Werror -pedantic -std=gnu89'

let g:ale_sign_error = '✗'
let g:ale_sign_warning = '⚠'
let g:ale_echo_msg_format = '[%linter%] %s'
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_on_insert_leave = 1

" Jump between errors
nmap <silent> [e <Plug>(ale_previous_wrap)
nmap <silent> ]e <Plug>(ale_next_wrap)

" Run Betty on the current file without leaving vim
command! Betty !betty %

" ----------------------------------------------------------------------------
" Airline
" ----------------------------------------------------------------------------
let g:airline_theme = 'gruvbox'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline#extensions#ale#enabled = 1
if !exists('g:airline_symbols')
	let g:airline_symbols = {}
endif

" ----------------------------------------------------------------------------
" NERDTree
" ----------------------------------------------------------------------------
let NERDTreeShowHidden = 1
nnoremap <leader>e :NERDTreeToggle<CR>
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <S-f> :NERDTreeFind<CR>
" Close vim if NERDTree is the only window left
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree')
	\ && b:NERDTree.isTabTree() | quit | endif

" ----------------------------------------------------------------------------
" fzf
" ----------------------------------------------------------------------------
let g:fzf_preview_window = ['right:50%', 'ctrl-/']
nnoremap <leader>f :Files<CR>
nnoremap <leader>b :Buffers<CR>

" ----------------------------------------------------------------------------
" Rainbow brackets
" ----------------------------------------------------------------------------
let g:rainbow_active = 1

" ----------------------------------------------------------------------------
" Pear-tree (bracket pairing)
" ----------------------------------------------------------------------------
let g:pear_tree_repeatable_expand = 0
let g:pear_tree_smart_openers = 0
let g:pear_tree_smart_closers = 0
let g:pear_tree_smart_backspace = 0

" ----------------------------------------------------------------------------
" Keybindings
" ----------------------------------------------------------------------------
" Save
nnoremap <leader>w :w<CR>

" System clipboard
vmap <leader>y "+y
vmap <leader>d "+d
nmap <leader>p "+p
nmap <leader>P "+P
vmap <leader>p "+p
vmap <leader>P "+P

" Window navigation
nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>

" Resize splits
nnoremap <silent> <leader>+ :vertical resize +5<CR>
nnoremap <silent> <leader>- :vertical resize -5<CR>

" Move lines up/down
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Comment toggle
nmap <leader>/ :Commentary<CR>
vmap <leader>/ :Commentary<CR>

" Cycle buffers
nnoremap <silent> <tab> :bnext<CR>
nnoremap <silent> <s-tab> :bprevious<CR>

" Undo tree
nnoremap <leader>u :UndotreeToggle<CR>

" Search & replace shortcut
nmap <leader>s :%s//g<Left><Left>

" Clear search highlight
if maparg('<C-L>', 'n') ==# ''
	nnoremap <silent> <C-L> :nohlsearch<CR><C-L>
endif

" GitGutter hunks
nmap ]c <Plug>(GitGutterNextHunk)
nmap [c <Plug>(GitGutterPrevHunk)
nmap <leader>hs <Plug>(GitGutterStageHunk)
nmap <leader>hu <Plug>(GitGutterUndoHunk)
