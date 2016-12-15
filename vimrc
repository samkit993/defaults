" Thanks John (criticjo)
" Plug Scripts +++ {{{
" Installation:
"   mkdir -p ~/.vim/autoload
"   curl -fLo ~/.vim/autoload/plug.vim \
"     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
call plug#begin('~/.vim/plugged')

Plug 'jvirtanen/vim-octave'
Plug 'bling/vim-airline'
Plug 'mhinz/vim-startify'
Plug 'powerman/vim-plugin-viewdoc'
Plug 'rking/ag.vim' , { 'on': ['Ag', 'AgBuffer', 'AgFile'] } "AgAdd AgFromSearch
Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' }
Plug 'Shougo/vimshell'
Plug 'Shougo/neocomplete'
Plug 'fatih/vim-go'
Plug 'junegunn/vim-easy-align'

Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-vinegar' "for improved file browsing
Plug 'tpope/vim-surround' "csXX, dsX, ysMX, yssX
Plug 'tpope/vim-abolish' "Abbreviation, substitution, coercion
Plug 'tpope/vim-repeat' "tpope plugin repeat
Plug 'derekwyatt/vim-scala'

call plug#end()
" Plug Scripts --- }}}

filetype plugin indent on
colorscheme desertEx 
syntax enable

" Global Options +++ {{{
" -= UI =-
set display+=lastline " Show as much of last line as possible
set foldmethod=marker
set hidden " Buffers can be hidden keeping its changes
set laststatus=2
set number
set relativenumber " Relative line numbering
set ruler " Show line and column numbers
set scrolloff=1
set showcmd
set wildmenu " Enhanced command line suggestions
set wildmode=longest,full

" -= Usability =-
set autoindent
set backspace=indent,eol,start
set incsearch " Show results simultaneously while typing a search command
set nrformats-=octal " For use with <C-A> and <C-X>
set timeoutlen=2000 " <leader> will have 2000ms timeout

" -= History management =-
set directory=~/.vim/swps
set history=256
set undofile
set undodir=~/.vim/undos
set undolevels=256	" Maximum number of changes that can be undone
set undoreload=2048	" Maximum number lines to save for undo on a buffer reload

" -= Formatting =-
set shiftwidth=4
set tabstop=4

" -= For Ctags =-
set tags=tags;/

" -= Session-saves =- :help :mksession
set ssop-=options " Do not store global and local values

" -= Spellcheck =-
set spellfile=~/.vim/spell/en.utf-8.add
set spelllang=en
" Global Options --- }}}

" Plugin Options +++ {{{
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#whitespace#mixed_indent_algo = 1
let g:airline_theme = 'bubblegum'
"alttheme: 'powerlineish' "hi VertSplit ctermfg=233 ctermbg=233 cterm=NONE

let g:surround_no_insert_mappings = 1
let g:viewdoc_openempty = 0

" Prevent vinegar from mapping 'minus'
noremap - -
" Plugin Options --- }}}

" Keymaps +++ {{{
" URL/XML/CString En/Decode maps: [u ]u [x ]x [y ]y
" CScope maps: <C-\>X <C-@>X <C-@><C-@>X

" Don't go to Ex mode, open cmd-line window instead.
noremap Q q:
noremap Y y$
noremap <A-n> :cn<CR>
noremap <A-p> :cp<CR>

inoremap <C-A> <C-O>^
inoremap <C-E> <C-O>$
inoremap <C-B> <S-Left>
inoremap <C-F> <S-Right>
" Make <C-U> undoable
inoremap <C-U> <C-G>u<C-U>
inoremap qj <Esc>

vnoremap qj <Esc>

" C-mode: <C-B> Home; <C-E> End; <C-F> C-window; <C-H> backspace
"		  <C-C> C-exit; <C-D> list-opts; <C-U> clear-back; <C-W> del-word
cnoremap <C-A> <Home>
" idea from tpope/vim-rsi
cnoremap <expr> <C-D> getcmdpos()>strlen(getcmdline())? "<C-D>": "<Del>"
cnoremap <C-B> <S-Left>
cnoremap <C-F> <S-Right>
cnoremap <expr> <C-K> getcmdpos()>strlen(getcmdline()) ? "<UP>" :
		\ getcmdpos()<2 ? "<C-E><C-U>" : "<C-\>egetcmdline()[0:getcmdpos()-2]<CR>"
cnoremap <C-J> <Down>
cnoremap <C-H> <Space><BS><Left>
cnoremap <C-L> <Space><BS><Right>

map <leader>y "+y
noremap <leader>Y "+y$
noremap <leader>p o<Esc>"+p
noremap <leader>P O<Esc>"+p
noremap <leader>b :e %:p:h<CR>
noremap <leader>cd :cd %:p:h<CR>
noremap <leader>do :DiffOrig<CR>
noremap <leader>hl :set invhlsearch<CR>
noremap <leader>m :MouseToggle<CR>
noremap <leader>n :<C-U>exe 'b ' . GetModifiableBuffer(v:count, 1)<CR>
noremap <leader>N :<C-U>exe 'b ' . GetModifiableBuffer(v:count, -1)<CR>
noremap <leader>o :Startify<CR>
noremap <leader>q :bp<BAR>bd #<CR>
noremap <leader>Q :qall<CR>
noremap <leader>s :set invspell<CR>
noremap <leader>u :UndotreeToggle<CR>
noremap <leader>vo :VisibleOnly<CR>
noremap <leader>w :w<CR>

autocmd FileType man\|help noremap <buffer> d <C-D>
autocmd FileType man\|help noremap <buffer> u <C-U>
autocmd FileType netrw noremap <buffer> qq <C-^>
autocmd FileType netrw nmap <buffer> <Space> mf
autocmd FileType rust setlocal makeprg=cargo\ run
" Keymaps --- }}}

" Custom commands +++ {{{
if has('mouse')
	command! MouseToggle if &mouse=="" | set mouse=a
				\ | else | set mouse= | endif
endif

" See the diff between the current buffer and the file on disk.
command! DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
				\ | wincmd p | diffthis

command! -nargs=* VisibleOnly call CloseHiddenBuffers()
" Custom commands --- }}}

" GetModifiableBuffer +++ {{{
" Get the nth modifiable buffer, relative to the current one if direction=±1,
" or relative to the first modiable buffer
function! GetModifiableBuffer(n, direction)
	let dir = a:direction
	let n = a:n
	let curbufnr = bufnr('%')
	if n == 0 && dir != 0 && &modifiable
		let n = 1
	endif
	let endbufnr = bufnr('$')
	if dir == 0
		let curbufnr = 0
		let dir = 1
	endif
	if dir == -1
		let bufrange = [0] + reverse(range(1, endbufnr - 1))
	else
		let bufrange = range(0, endbufnr - 1)
	endif
	let total = 0
	let mbufs = []
	for bi in bufrange
		let buf = (curbufnr - 1 + bi)%endbufnr + 1
		if buflisted(buf) && getbufvar(buf, "&modifiable")
			if n == len(mbufs)
				return buf
			endif
			let mbufs += [buf]
		endif
	endfor
	if len(mbufs) == 0
		return curbufnr
	else
		return mbufs[n%len(mbufs)
	endif
endfun
" GetModifiableBuffer --- }}}

" CloseHiddenBuffers +++ {{{
" src: http://stackoverflow.com/questions/2974192/
function! CloseHiddenBuffers()
	" figure out which buffers are visible in any tab
	let visible = {}
	for t in range(1, tabpagenr('$'))
		for b in tabpagebuflist(t)
			let visible[b] = 1
		endfor
	endfor
	" close any buffer that are loaded and not visible
	let l:tally = 0
	for b in range(1, bufnr('$'))
		if buflisted(b) && bufwinnr(b)<1
			let l:tally += 1
			exe 'bd ' . b
		endif
	endfor
	echon "Deleted " . l:tally . " buffers"
endfun
" CloseHiddenBuffers --- }}}

