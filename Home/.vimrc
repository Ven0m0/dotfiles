set nocompatible encoding=utf-8 background=dark t_Co=256 termguicolors ttyfast
set number relativenumber mouse=a smartcase ignorecase spell incsearch hlsearch nowrap linebreak
set smartindent autoindent expandtab shiftwidth=2 softtabstop=2 tabstop=2 smarttab
set showcmd showmode gcr=a:blinkon0 visualbell autoread ruler autochdir showmatch hidden
set scrolloff=8 sidescrolloff=15 sidescroll=1 lazyredraw clipboard=unnamed
set noswapfile nobackup nowb foldmethod=indent foldnestmax=3 nofoldenable
set wildmode=list:longest wildmenu ttimeout ttimeoutlen=1
set wildignore=*.o,*.obj,*~,*vim/backups*,*sass-cache*,*DS_Store*,vendor/cache/**,*.gem,log/**,tmp/**,*.png,*.jpg,*.gif
set listchars=tab:>-,trail:~,extends:>,precedes:<,space:.
filetype plugin indent on
syntax on

autocmd BufWritePre *.{py,f90,f95,for} :%s/\s\+$//e
autocmd FileType make setlocal noexpandtab
if $TERM == 'alacritty' | set ttymouse=sgr | endif
if has('gui_running')
  set guifont=Roboto\ Mono\ 11 guioptions-=m guioptions-=T guioptions-=r guioptions-=L
  colorscheme tender
endif

nnoremap p p=`]<C-o>
nnoremap P P=`]<C-o>
nnoremap <leader>f :FZF<CR>
nnoremap <leader>s :w<CR>
nnoremap <leader>wq :wq<CR>
nnoremap <leader>n :bnext<CR>
nnoremap <leader>p :bprev<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>Q :qa!<CR>
nnoremap <leader>l :set number!<CR>
nnoremap <leader>r :set relativenumber!<CR>
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l

call plug#begin()
Plug 'junegunn/fzf'
call plug#end()

let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"
