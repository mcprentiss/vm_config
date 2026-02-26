scriptencoding utf-8

"SET NOCOMPATIBLE
"SET RUNTIMEPATH=~/vim,$VIM/vimfiles,$VIMRUNTIME

" Define a mapping to :grep for the word under the cursor
"noremap gw :grep <cword> . <cr>

if executable('rg')
    set grepprg=rg\ --vimgrep
    set grepformat=%f:%l:%c:%m
endif

set encoding=utf-8

let mapleader = ' '
let maplocalleader = '\'
set shell=/bin/bash
set timeoutlen=5000                              " leave plenty of time to enter key combinations; 5 seconds

" set autoread                                   " automatically read file updates

" show tabs https://vi.stackexchange.com/questions/422/displaying-tabs-as-characters
" display chars for tabs and trailing spaces
set list
set listchars=tab:>-,trail:_,precedes:<,extends:>

" copy all matches with the last search
" delete matches
nmap dm :%s/<c-r>///g<CR>
" change matches
nmap cm :%s/<c-r>///g<Left><Left>

nnoremap <Leader>vs :source ~/.vimrc<CR>
nnoremap <Leader>ve :vsplit ~/.vimrc<CR>

" https://castel.dev/post/lecture-notes-1/
" jumps to the previous spelling misake, picks the first suggestion 1z=, and
" then jumps back `]a. The <c-g>u in the middle make it possible to undo the
" spelling correction quickly
inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u

" bind jj to esc
inoremap jj <esc>

" https://gist.github.com/mahemoff/8967b5de067cffc67cec174cb3a9f49d
" vim-powered terminal in split window
map <Leader>t :term ++close<cr>
tmap <Leader>t <c-w>:term ++close<cr>

" vim-powered terminal in new tab
map <Leader>T :tab term ++close<cr>
tmap <Leader>T <c-w>:tab term ++close<cr>

" Command to copy the current file's full absolute path.
command CopyFilePath let @+ = expand(has('win32') ? '%:p:gs?/?\\?' : '%:p')

command! Pdf execute "w !pandoc -f org -t pdf | zathura -"

" Generic Programming Support

" quickfix config open quickfix and location-list windows right after a quickfix/location-list command
augroup quickfix
     autocmd!
     autocmd QuickFixCmdPost [^l]* cwindow
     autocmd QuickFixCmdPost    l* cwindow
     autocmd VimEnter        *     cwindow
augroup END

"map <C-j> :cn<CR>
"map <C-k> :cp<CR>

" streamlining grep vim
" https://noahfrederick.com/log/vim-streamlining-grep
" cnoreabbrev <expr> grep  (getcmdtype() ==# ':' && getcmdline() =~# '^grep')  ? 'silent grep'  : 'grep'
" cnoreabbrev <expr> lgrep (getcmdtype() ==# ':' && getcmdline() =~# '^lgrep') ? 'silent lgrep' : 'lgrep'

" https://bluz71.github.io/2018/12/04/fuzzy-finding-in-vim-with-fzf.html
" nnoremap <silent> <Leader>f :Files <C-r>=expand("%:h")<CR>/<CR>

" duplicate a line and comment out original one
nnoremap <leader># YpkI"<Space><Esc>j^

" Buffers
" show buffers
nnoremap gb :ls<CR>:b<Space>

" Search through open buffers with Vim (self.vim), use with :FZFLines
nnoremap <leader>bs :cex []<BAR>bufdo vimgrepadd @@g %<BAR>cw<s-left><s-left><right>

" Close buffer
" nnoremap <leader>q :bw<Enter>

" Close split but keep buffer
" nnoremap <Backspace> <C-w>q<Enter>

" Close buffer but keep split
" nnoremap <leader><Backspace> :bp\|bd \#<Enter>

set printfont=Courier:h8 "select the font to use when printing
command! -range=% HardcopyPdf <line1>,<line2> hardcopy > %.ps | !ps2pdf %.ps && rm %.ps && echo 'Created: %.pdf'

function! s:fzf_snippets()
  call fzf#run({
        \ 'source': 'find ~/snippets/',
        \ 'sink': '-1read',
        \ 'down': '25%',
        \ 'options': ['--prompt', 'Snippets> ']})
endfunction
command! FSnippets call s:fzf_snippets()

" create a file mark at the position of the cursor when you leave a buffer
" 'J jumps to the latest JavaScript buffer

augroup VIMRC
   autocmd!
   autocmd BufLeave *.css  normal! mC
   autocmd BufLeave *.html normal! mH
   autocmd BufLeave *.js   normal! mJ
   autocmd BufLeave *.py   normal! mP
   autocmd BufLeave *.md   normal! mM
   autocmd BufLeave *.tex  normal! mT
   autocmd BufLeave *.vim  normal! mV
augroup END

" vimgrep
function! VisualSelection(direction) range
    let l:saved_reg = @"
    execute 'normal! vgvy'

    let l:pattern = escape(@", '\\/.*$^~[]')
    let l:pattern = substitute(l:pattern, "\n$", '', '')

    if a:direction ==? 'b'
        execute 'normal ?' . l:pattern . '^M'
    elseif a:direction ==? 'gv'
        call CmdLine('vimgrep ' . '/'. l:pattern . '/' . ' **/*.')
    elseif a:direction ==? 'replace'
        call CmdLine('%s' . '/'. l:pattern . '/')
    elseif a:direction ==? 'f'
        execute 'normal /' . l:pattern . '^M'
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" When you press gv you vimgrep after the selected text
noremap <silent> gv :call VisualSelection('gv')<CR>

" Open vimgrep and put the cursor in the right position
noremap <leader>g :vimgrep // **/*.<left><left><left><left><left><left><left>

" Vimgreps in the current file
noremap <leader>G :vimgrep // <C-R>%<C-A><right><right><right><right><right><right><right><right><right>

" When you press <leader>r you can search and replace the selected text
vnoremap <silent> <leader>r :call VisualSelection('replace')<CR>

" start command with double tap of the spacebar
nnoremap <Leader>1 :

" start a shell command without hitting shift
nnoremap <Leader>2 :!

" Execute the Ex command [cmd] (default ":p") on the lines within [range] where {pattern} matches.
nnoremap <Leader>3 :g//#<Left><Left>

" go substitute because the default map for sleeping is silly
nnoremap gs :%s//gc<Left><Left><Left>

" 24 simple text-objects
" ----------------------
" i_ i. i: i, i; i| i/ i\ i* i+ i- i#
" a_ a. a: a, a; a| a/ a\ a* a+ a- a#
for char in [ '_', '.', ':', ',', ';', '<bar>', '/', '<bslash>', '*', '+', '-', '#' ]
    execute 'xnoremap i' . char . ' :<C-u>normal! T' . char . 'vt' . char . '<CR>'
    execute 'onoremap i' . char . ' :normal vi' . char . '<CR>'
    execute 'xnoremap a' . char . ' :<C-u>normal! F' . char . 'vf' . char . '<CR>'
    execute 'onoremap a' . char . ' :normal va' . char . '<CR>'
endfor

" https://vi.stackexchange.com/questions/625/how-do-i-use-vim-as-a-diff-tool
if &diff
    highlight! link DiffText MatchParen
endif

if &diff
    set cursorline
    map ] ]c
    map [ [c
    hi DiffAdd    ctermfg=233 ctermbg=LightGreen guifg=#003300 guibg=#DDFFDD gui=none cterm=none
    hi DiffChange ctermbg=white  guibg=#ececec gui=none   cterm=none
    hi DiffText   ctermfg=233  ctermbg=yellow  guifg=#000033 guibg=#DDDDFF gui=none cterm=none
endif

" remove highlighting
nnoremap <Leader>, :nohl<CR>

if has('patch-8.1.0360')
    set diffopt+=internal,algorithm:patience
endif

" Performance improvements also try syntax off and --noplugins
set nolazyredraw
set renderoptions=type:directx,gamma:1.5,contrast:0.5,geom:1,renmode:5,taamode:1,level:0.5

set synmaxcol=200                      " Don't bother highlighting anything over 200 chars
let did_install_default_menus = 1      " No point loading gvim menu stuff

" search for a keyword in just the part of the file that's currently visible on the screen,
nnoremap <expr> z/ '/\%(\%>'.(line('w0')-1).'l\%<'.(line('w$')+1).'l\)\&'

command! -nargs=+ Cppman silent! call system("tmux split-window cppman " . expand(<q-args>))
autocmd FileType cpp nnoremap <silent><buffer> K <Esc>:Cppman <cword><CR>

" Yank into clipboard
noremap gy "+y

"Repeat last edit n times https://gist.github.com/romainl/db725db7babc84a9a6436180cedee188
nnoremap . :<C-u>exe 'norm! ' . repeat('.', v:count1)<CR>

" http://vim.wikia.com/wiki/GNU/Linux_clipboard_copy/paste_with_xclip
" mapping for F6 and F7, but my position changes on the page when pasting with F7. Use this F7 map to preserve your location on the text file:

vmap <leader>xyy :!xclip -f -sel clip<CR>
map <leader>xpp mz:-1r !xclip -o -sel clip<CR>`z

"Session saving
set sessionoptions=blank,buffers,curdir,folds,help,tabpages,winsize,localoptions

" print pdf preview
command! -complete=file -nargs=1 Rpdf :r !pdftotext -nopgbrk <q-args> -

let &t_ZH="\e[3m"
let &t_ZR="\e[23m"
highlight Comment cterm=italic, gui=italic
highlight Identifier ctermfg=99AA00

" syntax match potionComment "\v#.*$"
" highlight link potionComment Comment

" open filename under cursor in a new window (use current file's working directory)
nmap gf :new %:p:h/<cfile><cr>

" Enable CTRL-A/CTRL-X to work on octal and hex numbers, as well as characters
set nrformats=octal,hex,alpha

" snippet like behavior
nnoremap \temp :-1read $HOME/.vim/temp.snippet<CR>

" sessions https://dockyard.com/blog/2018/06/01/simple-vim-session-management-part-1
let g:session_dir = '~/.vim-sessions'
exec 'nnoremap <Leader>ses :mks! ' . g:session_dir . '/*.vim<C-D><BS><BS><BS><BS><BS>'
exec 'nnoremap <Leader>sesr :so ' . g:session_dir. '/*.vim<C-D><BS><BS><BS><BS><BS>'

" super quick search and replace
nnoremap <Leader>ST      :'{,'}s/\<<C-r>=expand("<cword>")<CR>\>/
nnoremap <Leader>%       :%s/\<<C-r>=expand("<cword>")<CR>\>/

" SHORTCUT TO REFERENCE CURRENT FILE'S PATH IN COMMAND LINE MODE
cnoremap <expr> %% expand('%:h').'/'<cr>
nmap <leader>e :edit %%
nmap <leader>v :view %%

" Highlight VCS conflict markers
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'

" Prevent Vim from clobbering the scrollback buffer. http://www.shallowsky.com/linux/noaltscreen.html
set t_ti= t_te=

" select all easy
nnoremap <leader>SA ggVG<CR>

" moving around window splits in vim
nnoremap <C-j> <C-w><C-j>
nnoremap <C-k> <C-w><C-k>
nnoremap <C-l> <C-w><C-l>
nnoremap <C-h> <C-w><C-h>

" Window splits open below or right of current window
set splitbelow
set splitright

" Derek Wyatt videos https://vimeo.com/user1690209
"
" http://vim.wikia.com/wiki/Vim_Tips_Wiki

" https://vimhelp.appspot.com/ vim docs online
" Disable autocopy of selected text to X clipboard in terminal mode
" set clipboard-=autoselect

" https://vi.stackexchange.com/questions/84/how-can-i-copy-text-to-the-system-clipboard-from-vim
" clipboard
" set clipboard=unnamed,unnamedplus to sync both * and + registers with the default unnamed register.
" set clipboard=unnamed,unnamedplus

set clipboard=unnamedplus

" Syntax for multiple tagi, files in current file, in working directory, and in every parent directory, recursively,
set tags=./tags;.tags;

" search down into subfolders
" provides tab-completion for all file-related tasks
set path+=**

" vim --clean +'set incsearch hlsearch termguicolors' nnn.md
"http://owen.cymru/fzf-ripgrep-navigate-with-bash-faster-than-ever-before/

" --column: Show column number
" --line-number: Show line number
" --no-heading: Do not show file headings in results
" --fixed-strings: Search term as a literal string
" --ignore-case: Case insensitive search
" --no-ignore: Do not respect .gitignore, etc...
" --hidden: Search hidden files and folders
" --follow: Follow symlinks
" --glob: Additional conditions for search (in this case ignore everything in the .git/ folder)
" --color: Search color options

let g:rg_command = '
  \ rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --color "always"
  \ -g "*.{js,json,php,md,styl,jade,html,config,py,cpp,c,go,hs,rb,conf}"
  \ -g "!{.git,node_modules,vendor}/*" '

" text search with :F that uses ripgrep
command! -bang -nargs=* F call fzf#vim#grep(g:rg_command .shellescape(<q-args>), 1, <bang>0)

" search for words in file
inoremap <C-J> <C-X><C-P>

" MAKE QUOTES AND SQUARE BRACKETS INTO MOVEMENTS
" simplifies actions such as di" to dQ, and di] to dia.
onoremap q i'
onoremap Q i"

onoremap ia i]
onoremap aa a]

" let terminal resize scale the internal windows
" augroup VimResized
"   autocmd!
"   autocmd! VimResized * :wincmd =
" augroup

" Automatic reloading of .vimrc on each save
" augroup BufWritePost
"   autocmd!
"   autocmd! bufwritepost .vimrc source %
" augroup

"{{{ -------------------------------- start sanctum geek
" https://sanctum.geek.nz/cgit/dotfiles.git/tree/vim/vimrc?h=how-i-vim

" Allow jumping between windows and tabs to find an open instance of a given buffer with :sbuffer.
if v:version >= 701
  set switchbuf=useopen,usetab
else
  set switchbuf=useopen
endif

" ZZ Quit while checking for changes
" ZQ Quit without checking for changes ( same as ":q!"
" ZW forces a write of the current buffer, but doesn't quit
" ZA forces a write of all buffers but doesn't quit
" ZS quit and save all buffers
" :x and ZZ are equivalent; they only save the file if it has been modified, then quit Vim:

nnoremap ZW :w!<CR>
nnoremap ZA :wa!<CR>
nnoremap ZS :xa<CR>

" Use the tilde as an operator with motions, rather than just swapping the case of the character under the cursor
set tildeop

" When in visual block mode, let me move the cursor anywhere in the buffer;
" don't restrict me only to regions with text
if has('virtualedit')
  set virtualedit+=block
endif

" Tolerate typos like :Wq, :Q, or :Qa and do what I mean, including any
" arguments or modifiers; I fat-finger these commands a lot because I type
" them so rapidly, and they don't correspond to any other commands I use
if has('user_commands')
  command! -bang -complete=file -nargs=? E e<bang> <args>
  command! -bang -complete=file -nargs=? W w<bang> <args>
  command! -bang -complete=file -nargs=? WQ wq<bang> <args>
  command! -bang -complete=file -nargs=? Wq wq<bang> <args>
  command! -bang Q q<bang>
  command! -bang Qa qa<bang>
  command! -bang QA qa<bang>
  command! -bang Wa wa<bang>
  command! -bang WA wa<bang>
endif

" keep my cursor in the same place; this is done by dropping a mark first and then immediately returning
" to it; note that it wipes out your z mark
nnoremap J mzJ`z

" A few very important custom digraphs
if has('digraphs')
  digraph ./ 8230  " Ellipsis (HORIZONTAL ELLIPSIS U+2026)
  digraph 8: 9731  " Snowman (SNOWMAN U+2603)
endif

"}}} -------------------------------- end sanctum geek -------------------

"{{{ -------------------------------- Start Greg Hurrell -----------------
nnoremap <leader>SV :source $MYVIMRC<cr>
" Automatically source vimrc on save.
autocmd! bufwritepost $MYVIMRC source $MYVIMRC

"surrond  text with  " ' (
nnoremap <leader>" viw<esc>a"<esc>bi"<esc>lel
nnoremap <leader>' viw<esc>a'<esc>bi'<esc>lel
nnoremap <leader>( viw<esc>a)<esc>bi(<esc>lel

" change item in set of searched text
nnoremap c* *Ncgn

" Move visual block
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Sometimes I go in visual and would like to search the text, so I mapped to // in visual.
" Of course their is a lot of problem if highlighted text contains kind of regex pattern.
" Search in visual block
vnoremap // y/<C-R>"<CR>

"  https://vim.fandom.com/wiki/Search_for_visually_selected_text
"  <leader>T :%s/\<<C-r><C-w>\>/
" vnoremap <leader>T y:%s/<c-r>"/

" Automatically 'gv' (go to previously selected visual block) after indenting or unindenting.
vnoremap < <gv
vnoremap > >gv

" indent do into visual mode, select lines, press >
xnoremap < <gv
xnoremap > >gv

" a trick to make the man age appear in a Vim window. load the man filetype plugin:
" use the ":Man" command to open a window on a man page or <leader>K cursor

if v:version > 703 || v:version == 703 && has('patch541')
  set formatoptions+=j                 " remove comment leader when joining comment lines
endif

set shortmess+=A                       " ignore annoying swapfile messages
set shortmess+=I                       " no splash screen
set shortmess+=O                       " file-read message overwrites previous
set shortmess+=T                       " truncate non-file messages in middle
set shortmess+=W                       " don't echo "[w]"/"[written]" when writing

set shortmess+=a                       " use abbreviations in messages eg. `[RO]` instead of `[readonly]`
if has('patch-7.4.314')
  set shortmess+=c                     " completion messages
endif
set shortmess+=o                       " overwrite file-written messages
set shortmess+=t                       " truncate file messages at start

set formatoptions+=n                   " smart auto-indenting inside numbered lists
set printoptions=syntax:n,paper:letter " Turn off syntax highlighting for printing and set papersize

" set highlight+=N:DiffText              " make current line number stand out a little
set highlight+=@:ColorColumn           " ~/@ at end of window, 'showbreak'
set highlight+=c:LineNr                " blend vertical separators with line numbers

" highlight visual block
highlight Visual cterm=reverse ctermbg=NONE

if exists('+relativenumber')
  set relativenumber                   " show relative numbers in gutter
endif

set number

if has('linebreak')
  set linebreak                        " wrap long lines at characters in 'breakat'
  let &showbreak=' ↳ '                 " DOWNWARDS ARROW WITH TIP RIGHTWARDS (U+21B3, UTF-8: E2 86 B3)
endif

set sidescrolloff=3                    " same as scrolloff, but for columns
set smarttab                           " <tab>/<BS> indent/dedent in leading whitespace

" if has('termguicolors')
"   set termguicolors                    " use guifg/guibg instead of ctermfg/ctermbg in terminal
" endif

if has('virtualedit')
  set virtualedit=block                " allow cursor to move where there is no text in visual block mode
endif

" swap
set backup
if exists('$SUDO_USER')
  set noswapfile                       " don't create root-owned files
else
  set directory=~/.vimtmp/swap         " keep backup files out of the way
  set swapfile                         " no swap files
endif

" undo
if has('persistent_undo')
  if exists('$SUDO_USER')
    set noundofile                     " don't create root-owned files
  else
    set undolevels=100                 " How many undos
    set undoreload=200                 " number of lines to save for undo
    set undodir=~/.vimtmp/undo         " keep undo files out of the way
    set undodir+=.
    set undofile                       " actually use undo files
  endif
endif

" backup
set backup
if exists('$SUDO_USER')
  set nobackup                         " don't create root-owned files
  set nowritebackup                    " don't create root-owned files
else
  set directory=~/.vimtmp/backup       " keep backup files out of the way
  set backupdir=~/.vimtmp/backup       " keep backup files out of the way
  set backupdir+=.
endif

"make those folders automatically if they don't already exist.
if !isdirectory(expand(&undodir))
     call mkdir(expand(&undodir), "p")
    endif
if !isdirectory(expand(&backupdir))
     call mkdir(expand(&backupdir), "p")
endif
if !isdirectory(expand(&directory))
     call mkdir(expand(&directory), "p")
endif

if has('mksession')
  set viewdir=~/.vimtmp/view           " override ~/.vim/view default
  set viewoptions=cursor,folds         " save/restore just these (with `:{mk,load}view`)
endif

"}}} --------------------- End Greg Hurrell -----------------------------------{{{}}}

" NetRW for :Explore command    http://www.drchip.org/astronaut/vim/index.html#NETRW
let g:netrw_banner                    = 0           " disable annoying banner
let g:netrw_preview                   = 1
let g:netrw_sizestyle                 = 'H'         " Human-readable file sizes
let g:netrw_liststyle                 = 3           " tree view
let g:netrw_browse_split              = 1           " Open files in a split window
let g:netrw_altv                      = 1           " open splits to the right
let g:netrw_winsize                   = 25          " percentage width of the directory explorer
let g:netrw_hide                      = 1           " hide dotfiles by default
let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+'      " hide dotfiles

augroup netrw
    " autocmd!
    " autocmd FileType netrw set nolist
augroup END

" let g:netrw_sort_by                   = 'time'
" let g:netrw_browsex_viewer="xdg-open"
" let g:netrw_browsex_viewer='/usr/bin/firefox'
let g:netrw_browsex_viewer='/usr/bin/brave-browser-stable'
" let g:netrw_sort_direction            = 'reverse'
"
" edit .a folder to open a file browser
" <CR>/v/t to open in an h-split/v-split/tabs
" check |netrw-browse-maps| for more mapings

" autocomplete |ins-completion|
" ^x^n - for just this file
" ^x^f - filenames
" ^x^] - tags
" ^n - for anything specified by the 'complete' option

" Find merge conflict markers
nnoremap <leader>ffc /\v^[<\|=>]{7}( .*\|$)<CR>

" inoremap ( ()<Esc>i
" inoremap { {}<Esc>i

" Map key chord `jk` to <Esc>. via reddit
let g:esc_j_lasttime = 0
let g:esc_k_lasttime = 0
function! JKescape(key)
    if a:key=='j' | let g:esc_j_lasttime = reltimefloat(reltime()) | endif
    if a:key=='k' | let g:esc_k_lasttime = reltimefloat(reltime()) | endif
    return abs(g:esc_j_lasttime - g:esc_k_lasttime) <= 0.05 ? "\b\e" : a:key
endfunction
inoremap <expr> j JKescape('j')
inoremap <expr> k JKescape('k')

" expands %% to current file's directory in command-line mode like :cd %%.
cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<CR>

" [S]plit line (sister to [J]oin lines) still substitutes the line like S would
nnoremap S i<CR><Esc>^mwgk:silent! s/\v +$//<CR>:noh<CR>

" visually select the last paste or change
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

" Open Quickfix window automatically after running :make
" augroup OpenQuickfixWindowAfterMake
"     autocmd!
"     autocmd QuickFixCmdPost [^l]* nested cwindow
"     autocmd QuickFixCmdPost    l* nested lwindow
" "   autocmd for cmake markdown julia python fortran .docx
"
" augroup

" -----------------------------------------------------------------------------
augroup markdown
     autocmd!
"     " MARKDOWN Vim doesn't recognize *.md files as Markdown
     autocmd BufNewFile,BufRead *.{md,mdown,mkd,mkdn,markdown,mdwn} set filetype=markdown
     autocmd BufNewFile,BufRead *.md set ft=markdown wrap linebreak nolist textwidth=0 wrapmargin=0
"     " autocmd BufRead,BufNewFile *.md setlocal spell
     autocmd BufRead,BufNewFile *.md setlocal textwidth=80
     autocmd BufNewFile,BufRead *.md syntax keyword todo TODO
     autocmd BufNewFile,BufRead *.md inoremap <buffer> ;` ```<cr><cr>```<Up><Up>
     let g:vim_markdown_folding_disabled=0
     let g:vim_markdown_initial_foldlevel=1
     let g:vim_markdown_math=1             " for allowing latex in markdown
     let g:markdown_fenced_languages = ['bash=sh', 'django', 'python', 'xml', 'html']
augroup end

" augroup python
"     autocmd!
" " http://wiki.python.org/moin/ViImproved
" " https://github.com/hdima/python-syntax
" " http://www.belchak.com/2011/01/31/code-completion-for-python-and-django-in-vim/
" " https://www.cyberciti.biz/faq/how-to-access-view-python-help-when-using-vim/
" " Append the following configuration for pydoc3 (python v3.x docs). Create a mapping for H key that works in normal mode:
" " nnoremap <buffer> H :<C-u>execute "!pydoc3 " . expand("<cword>")<CR>
"     let g:python_highlight_all = 1
"     let g:python_recommended_style = 0
"     autocmd BufNewFile,BufRead *.py set filetype=python
"     if has('python')
"         autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
"     end
"     autocmd BufRead,BufNewFile *.py syntax on
"     autocmd BufRead,BufNewFile *.py set ai
"     autocmd BufEnter,BufRead *.py setlocal smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
"     autocmd FileType python nnoremap <leader>y :0,$!yapf<CR>
"     " configure shiftwidth, tabstop and softtabstop
"     autocmd FileType python set sw=4
"     autocmd FileType python set ts=4
"     autocmd FileType python set sts=4
"     " config for python_pydoc.vim in ~/.vim/ftplugin/python_pydoc.vim
"     let g:pydoc_cmd = '/usr/bin/pydoc3'
"     " let g:pydoc_cmd = 'python -m pydoc'
    " " If you want to open pydoc files in vertical splits or tabs, give the appropriate command in your .vimrc with:
    " let g:pydoc_open_cmd = 'vsplit'
    " let g:pydoc_highlight=0
" augroup

" augroup fortran
"     " autocmd!
"     autocmd BufNewFile,BufRead *.f setf f77
"     autocmd BufNewFile,BufRead *.f90  setf f90
"     autocmd FileType fortran compiler ifort
"     autocmd BufRead,BufNewFile *.for let b:fortran_fixed_source=1
"     let g:fortran_fold=1
"     " Additionally you can force folding on conditionals and multi line comments though
"     let g:fortran_fold_conditionals=1
"     let g:fortran_fold_multilinecomments=1
"     let g:fortran_free_source=1
"     let g:fortran_do_enddo=1
"     let g:fortran_more_precise=1
"     " fortran_have_tabs must be placed prior to syntax on
"     let g:fortran_have_tabs=1
" augroup

" augroup pandoc
    " autocmd!
    " autocmd BufReadPost *.doc,*.docx,*.rtf,*.odp,*.odt silent %!pandoc "%" -tplain -o /dev/stdout
" augroup

source ~/.vim/startup/ab.vim
" source ~/.vim/startup/django.vim
source ~/.vim/startup/functions.vim
source ~/.vim/startup/mappings.vim
source ~/.vim/startup/settings.vim

let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

"{{{   ---------------- starting plugins ------------------------------------
call plug#begin('~/.vimplugged')
" PlugInstall [name ...] [#threads] Install plugins
" PlugUpdate [name ...] [#threads]  Install or update plugins
" PlugClean[!]                      Remove unused directories (bang version will clean without prompt)
" PlugUpgrade                       Upgrade vim-plug itself
" PlugStatus                        Check the status of plugins
" PlugDiff                          Examine changes from the previous update and the pending changes
" PlugSnapshot[!] [output path]     Generate script for restoring the current snapshot of the plugins

" Generic Programming Support
" Plug 'dense-analysis/ale'           " syntax checker
Plug 'JuliaEditorSupport/julia-vim' " Vim support for Julia
Plug 'rust-lang/rust.vim'           " Vim support for Rust
" Plug 'tpope/vim-commentary'         " easy commenting
" Plug 'tpope/vim-fugitive'           " vim git integration
Plug 'majutsushi/tagbar'            " displays tags in a window, ordered by scope
Plug 'RRethy/vim-illuminate'        " automatically highlighting other uses of the word under the cursor
Plug 'meain/vim-printer'            " Quickly print/log the variable in your favourite language
Plug 'voldikss/vim-browser-search'  " add google, ddga, wikipedia searches
Plug 'tyru/open-browser.vim'        " Open URI with your favorite browser from your most favorite editor
Plug 'AndrewRadev/sideways.vim'     " move function arguments (and other delimited-by-something items) left and right.
Plug 'dstein64/vim-startuptime'     " A Vim plugin for profiling Vim's startup time

Plug 'dart-lang/dart-vim-plugin'    " for dart programming
Plug 'thosakwe/vim-flutter'         " flutter framework

" Utilities
" Plug 'tpope/vim-eunuch'                     " Vim sugar for shell commands
Plug 'tpope/vim-surround'                   " surround editing
Plug 'tpope/vim-unimpaired'                 " useful bracket key bindings git, svn
Plug 'ervandew/supertab'                    " auto-completion for programming
Plug 'kopischke/vim-fetch'                  " open vim and fetch line and column numbers in file names
Plug 'justinmk/vim-sneak'                   " Like f, but you provide 2 characters instead of 1 Provides improvements to f/t
Plug 'Shougo/unite.vim'                     " unite and create user interfaces
Plug 'Shougo/vimproc.vim', {'do' : 'make'}  " interactive command execution in Vim, compile with make
Plug 'sunaku/vim-dasht'                     " Vim plugin for dasht integration
Plug 'dbakker/vim-lint'                     " check your .vimrc for errors
" Plug 'lfv89/vim-interestingwords'           " highlighting and navigating through different words in a buffer
Plug 'jez/vim-superman'                     " Read Unix man pages with Vim

" Text-objects
Plug 'wellle/targets.vim'                   " add text objects to give you more targets 'in' text objects, e.g. vin\" to select inside next quotes
" Plug 'kana/vim-textobj-user'                " Vim plugin: Create your own text objects
" Plug 'kana/vim-textobj-indent'              " Vim plugin: Text objects for indented blocks of lines
" Plug 'bps/vim-textobj-python'               " Text objects for Python.
" Plug 'vim-scripts/argtextobj.vim'           " Text objects for arguments
" Plug 'kana/vim-textobj-function'          " Vim plugin: Text objects for functions
" Plug 'Julian/vim-textobj-variable-segment'      " eg. viv
" Plug 'jceb/vim-textobj-uri'               " Text objects for dealing with URIs

" find ~/.vim -name *.vim|xargs python ~/.vim/bundle/vim-lint/vimlint/vimlint.py > out.txt
Plug 'tmux-plugins/vim-tmux'        " navigation between tmux panes and vim splits
Plug 'benmills/vimux'               " interact with tmux from vim
" Plug 'airblade/vim-gitgutter'       " git diff in the gutter and stages/undoes hunks

" Markdown / Writing
Plug 'lervag/vimtex'                " provides support for writing LaTeX documents
Plug 'junegunn/goyo.vim'            " Distraction-free writing in Vim.
Plug 'junegunn/limelight.vim'       " Highlighting of text under cursor
Plug 'dpelle/vim-LanguageTool'      " LanguageTool grammar checker

" buffer plugins
" Plug 'qpkorr/vim-bufkill'          " Unload/delete/wipe a buffer, keep its window, display last accessed buffer
" Plug 'jlanzarotta/bufexplorer'     " switch between buffers by using the one of the default public interfaces

" Theme / Interface
Plug 'fxn/vim-monochrome'                                           " vim-monochrome

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': { -> fzf#install() } } "fuz
Plug 'junegunn/fzf.vim'                                             " fuzzy finder
Plug 'pbogut/fzf-mru.vim'                                           " MRU (most-recently-used) cache recently opened files
Plug 'vimwiki/vimwiki', { 'branch': 'master' }                      " personal Wiki for Vim

call plug#end()

let g:plug_window = 'vertical topleft new'
let g:plug_pwindow = 'above 12new'

" Enabled periodically, but not by default:
" Plug 'https://github.com/editorconfig/editorconfig-vim' EditorConfig plugin for Vim
" Plug 'skywind3000/asyncrun.vim'     " Run Async Shell Commands in Vim 8.0 and Output to Quickfix Window
" Plug 'kshenoy/vim-signature'        " toggle, display and navigate marks
" Plug 'machakann/vim-sandwich        " set of operator and textobject plugins to search/select/edit sandwiched textobjects
" Plug 'tpope/vim-abolish'            " easily search for, substitute, and abbreviate multiple variants of a word
" Plug 'tommcdo/exchange.vim'         " Easy text exchange operator for Vim
" Plug 'Shougo/denite.nvim'           " Dark powered asynchronous unite all interfaces for Neovim/Vim8
" Plug 'plasticboy/vim-markdown'      " vim support for Markdown
" Plug 'suan/vim-instant-markdown'    " Instant Markdown previews from VIm!
" Plug 'hinz/vim-startify'            " The fancy start screen for Vim
" Plug 'reedes/vim-pencil'            " Rethinking Vim as a tool for writing
" Plug 'tpope/vim-rhubarb'           "  GitHub extension for fugitive.vim
" Plug 'hinz/vim-galore'              " All things Vim!
" Plug 'tyru/capture.vim'             " Show Ex command output in buffer
" Plug 'romainl/vim-qf'               " Tame the quickfix window
" Plug 'chriskempson/base16-vim'      " base16 terminal theme
" Plug 'puremourning/vimspector'      " vimspector - A multi-language debugging system for Vim
" Plug 'ap/vim-css-color'             " Preview colours in source code while editing
" Plug 'Yggdroot/indentLine'          " display the indention levels with thin vertical lines
" Plug 'sheerun/vim-polyglot'         " A collection of language packs for Vim.
" Plug 'psliwka/vim-dirtytalk'        " spellcheck dictionary for programmers
" Plug 'sysid/vimwiki-nirvana'        " functionality by providing a custom handler for links
" Plug 'jdhao/better-escape.vim'      " escape insert mode quickly with customized key combinations

" allows you to configure % to match more than just single characters.
" Load stock matchit.vim if no newer version available potential replacement andymass/vim-matchup
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &runtimepath) ==# ''
   runtime! macros/matchit.vim
endif

" https://vimtricks.com/p/accessing-man-pages/
runtime ftplugin/man.vim

" andymass/vim-matchup - even better % navigate and highlight matching words modern matchit and matchparen replacement
" matchit plugin  makes "%" command jump to matching HTML tags, if/else/endif in Vim scripts packadd! matchit *1/
" Match all forms of brackets in pairs (including angle brackets)
set matchpairs=(:),{:},[:],<:>

set omnifunc=syntaxcomplete#Complete  " for omnicompletion <C-x><C-o>

"                          PLUGIN CONFIG
"                         base16colorspace=256
" ------------------------------------------------------------------------
" if filereadable(expand('~/.vimrc_background'))
  " let g:base16colorspace=256
  " source ~/.vimrc_background
  " colorscheme base16-grayscale-dark
" endif

" vim-monochrome                                          " Monochrome color scheme for Vim
" ------------------------------------------------------------------------
colorscheme monochrome

" ale                                                     " Check/fix syntax, with linters and Language Server Protocol
" ------------------------------------------------------------------------

let g:ale_linters_explicit = 1                        " Only run linters named in ale_linters settings
let g:ale_enabled = 1                                 " use :ALEToggle to activate it

let g:ale_sign_error = '*'
let g:ale_sign_warning = '?'

let g:ale_echo_msg_error_str = 'E'                    " Shorten error/warning flags
let g:ale_echo_msg_warning_str = 'W'

" move to next error/warning
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

" use the quickfix list instead of the loclist?
" let g:ale_open_list = 0
" let g:ale_loclist = 0
" let g:ale_set_loclist = 1
" let g:ale_set_quickfix = 1

" use linting, fixing.  :ALEFix :ALELint

" Linting
let g:ale_linters = {'python': ['flake8'], 'vim': ['vint']}
let g:ale_lint_on_enter = 0                                     " Lint on Open
let g:ale_lint_on_save = 1                                      " Lint on Save
let g:ale_lint_on_text_changed = 'never'                        " Don't lint dynamically

" Fixing
let b:ale_fixers = { '*' : ['trim_whitespace' ], 'python' : ['black'] }
" let b:ale_fixers = { '*' : ['trim_whitespace' ], 'python' : ['black'] }
" let b:ale_fixers = { '*' : ['remove_trailing_lines', 'trim_whitespace' ], 'python' : ['black', 'isort'] }

" julia-vim                                               " Vim support for Julia

" vim-commentary                                          " Comment stuff out
" ------------------------------------------------------------------------

"augroup vim-comment
"    autocmd!
"    autocmd FileType julia setlocal commentstring=#\ %s
"    autocmd FileType sh setlocal commentstring=#\ %s
"    autocmd FileType markdown setlocal commentstring=#\ %s
"    autocmd FileType python setlocal commentstring=#\ %s
"    autocmd FileType f77 setlocal commentstring=c\ %s
"    autocmd FileType f90 setlocal commentstring=!\ %s
"    autocmd FileType tex setlocal commentstring=%\ %s
" autocmd FileType c,cpp,java,scala let b:comment_leader = '// '
"augroup end

noremap <silent> ,cc :<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<CR>/<CR>:nohlsearch<CR>
noremap <silent> ,cu :<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<CR>//e<CR>:nohlsearch<CR>

" vim-fugitive                                            " A Git wrapper so awesome, it should be illegal
" --------------------------------------------------------------------
nnoremap <leader>ga :Git add %:p<CR><CR>
nnoremap <leader>gb :Git branch<Space>
nnoremap <leader>gc :Gcommit -v -q<CR>
nnoremap <leader>gco :GCheckout<CR>
nnoremap <leader>gd :Gdiff<CR>
nnoremap <leader>gdt :Git difftool<CR><CR>
nnoremap <leader>gdtc :Git difftool --cached<CR><CR>
nnoremap <leader>ge :Gedit<CR>
nnoremap <leader>ggl :Gpull<CR>
nnoremap <leader>ggp :Gpush<CR>
nnoremap <leader>gl :silent! Glog<CR>:bot copen<CR>
nnoremap <leader>gm :Gmove<Space>
nnoremap <leader>go :Git checkout<Space>
nnoremap <leader>gp :Ggrep<Space>
nnoremap <leader>gr :Gread<CR>
nnoremap <leader>gst :Gstatus<CR>
nnoremap <leader>gt :Gcommit -v -q %:p<CR>
nnoremap <leader>gw :Gwrite<CR><CR>

" tagbar                                                  " displays tags in a window, ordered by scope
" --------------------------------------------------------------------
let g:tagbar_ctags_bin = '/home/mp466/.universal-ctags/ctags'

" vim-illuminate                                          " automatically highlighting other uses of the word under the cursor
" --------------------------------------------------------------------
" Time in milliseconds (default 250)
let g:Illuminate_delay = 250

" Don't highlight word under cursor (default: 1)
let g:Illuminate_highlightUnderCursor = 1

" vim-printer                                             " A Git wrapper so awesome, it should be illegal
" --------------------------------------------------------------------
let g:vim_printer_print_below_keybinding = '<leader>p'
let g:vim_printer_print_above_keybinding = '<leader>P'

" open-browser.vim
let g:netrw_nogx = 1 " disable netrw's gx mapping.
nmap gx <Plug>(openbrowser-smart-search)
vmap gx <Plug>(openbrowser-smart-search)

"                          Utility
" vim-eunuch'                                             " Vim sugar for shell commands that need it the most
" vim-surround'                                           " surround editing
" vim-unimpaired'                                         " useful bracket key bindings

" supertab'                                               " auto-completion for programming
" --------------------------------------------------------------------
" let g:SuperTabDefaultCompletionType = '<C-X><C-O>'
" tab   - forward selection
" s-tab - backward selection

let g:SuperTabDefaultCompletionType = 'context'
let g:SuperTabContextDefaultCompletionType = '<c-n>'

" indentLine                                              " display the indention levels with thin vertical lines
" --------------------------------------------------------------------
" let g:indentLine_fileTypeExclude=['help','markdown','vimwiki']
" let g:indentLine_setColors = 0                      " highlight conceal color with your colorscheme
" let g:indentLine_char = '┃'                         " BOX DRAWINGS HEAVY VERTICAL (U+2503, UTF-8: E2 94 83)

" vim-fetch                                               " open vim and fetch line and column numbers in file names

" vim-sneak                                               " Extended f, F, t and T (or vim-sneak)
" --------------------------------------------------------------------
"Like f, but you provide 2 characters instead of 1
""Provides improvements to f/t
Plug 'justinmk/vim-sneak'
let g:sneak#s_next = 1
map f <Plug>Sneak_f
map F <Plug>Sneak_F
map t <Plug>Sneak_t
map T <Plug>Sneak_T

" unite.vim'                                              " unite and create user interfaces
" vimproc.vim'                                            " interactive command execution, compile with make
" vim-lint'                                               " check your .vimrc for errors

" vim-dasht                                               " vim plugin for dasht integration
" --------------------------------------------------------------------

" search related docsets
" nnoremap <Leader>d :Dasht<Space>

" search ALL the docsets
" nnoremap <Leader><Leader>k :Dasht!<Space>

" Search docsets for words under cursor:
" nnoremap <silent> <Leader>K :call Dasht(dasht#cursor_search_terms())<Return>
" nnoremap <Leader> <Leader>K :call Dasht(dasht#cursor_search_terms())<Return>

" search ALL the docsets
" nnoremap <silent> <Leader><Leader>K :call Dasht(dasht#cursor_search_terms(), '!')<Return>

" Search docsets for your selected text:
" vnoremap <Leader>K y:<C-U>call Dasht(getreg(0))<Return>

" search ALL the docsets
" vnoremap <Leader><Leader>K y:<C-U>call Dasht(getreg(0), '!')<Return>k

" When in vim, also search vim:
" let g:dasht_filetype_docsets = {} " filetype => list of docset name regexp
" let g:dasht_filetype_docsets['vim'] = ['vim']

" When in C++, also search C, Boost, and OpenGL:
" let g:dasht_filetype_docsets['cpp'] = ['^c$', 'boost', 'OpenGL']

" When in Python, also search NumPy, SciPy, and Pandas:
" let g:dasht_filetype_docsets['python'] = ['(num|sci)py', 'pandas', 'Python_3']

" When in HTML, also search CSS, JavaScript, Bootstrap, and jQuery:
" let g:dasht_filetype_docsets['html'] = ['css', 'js', 'bootstrap']

" create window below current one (default)
" let g:dasht_results_window = 'new'

" vim-interestingwords                                    " highlighting and navigating through different words
" -------------------------------------------------------------------------
" nnoremap <silent> <leader>k :call InterestingWords('n')<cr>
" nnoremap <silent> <leader>K :call UncolorAllWords()<cr>
" nnoremap <silent> n :call WordNavigation(1)<cr>
" nnoremap <silent> N :call WordNavigation(0)<cr>

" vim-superman                                            " Read Unix man pages with Vim
"-------------------------------------------------------------------------
" complete -o default -o nospace -F _man vman


" vim-gitgutter                                           " a diff in the gutter and stages/undoes and partial hunks
"-------------------------------------------------------------------------
" Use fontawesome icons as signs
" let g:gitgutter_sign_added = '+'
" let g:gitgutter_sign_modified = '>'
" let g:gitgutter_sign_removed = '-'
" let g:gitgutter_sign_removed_first_line = '^'
" let g:gitgutter_sign_modified_removed = '<'
" let g:gitgutter_max_signs = 500  " default value

" fzf                                                     " A command-line fuzzy finder
"-------------------------------------------------------------------------
" in .vim/startup/mapping.vim
" sets path for fzf
set runtimepath +=~/.fzf

" Open files in horizontal split
nnoremap <silent> <leader>S :call fzf#run({ 'down': '40%', 'sink': 'botright split' })<CR>
" Open files in vertical horizontal split
nnoremap <silent> <leader>E :call fzf#run({ 'right': winwidth('.') / 2, 'sink':  'vertical botright split' })<CR>

" fzf.vim                                                 " fzf plugin
" ------------------------------------------------------------------------

" This is the default extra key bindings
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

" [Buffers] Jump to the existing window if possible
let g:fzf_buffers_jump = 1

" [Tags] Command to generate tags file
let g:fzf_tags_command = 'ctags -R'

" [[B]Commits] Customize the options used by 'git log':
let g:fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'

nnoremap <silent> <leader>ff  :Files<CR>                  " open fzf files in a directory
nnoremap <silent> <leader>ft  :Filestypes<CR>             " open fzf filestypes
nnoremap <silent> <leader>fgf :GFiles<CR>                 " Git files (git ls-files)
nnoremap <silent> <leader>fgf :GFiles?<CR>                " Git files (git status)
nnoremap <silent> <leader>fht :Helptags<CR>               " searchable helptags
nnoremap <silent> <leader>fhb :History:<CR>               " buffer history
nnoremap <silent> <leader>fhs :History/<CR>               " search history
nnoremap <silent> <leader>fbl :BLines<CR>                 " lines in current buffer
nnoremap <silent> <leader>fm  :Marks<CR>                  " for marked lines
nnoremap <silent> <leader>f]  :Tags<CR>                   " tags across project
nnoremap <silent> <leader>fb] :BTags<CR>                  " tags in the current buffer
nnoremap <silent> <leader>fb  :Buffers<CR>                " for open buffers
nnoremap <silent> <leader>fc  :Commits<CR>                " Git commits (requires fugitive.vim)
nnoremap <silent> <leader>fbc :BCommits<CR>               " Git commits for the current buffer
nnoremap <silent> <leader>fa  :Ag<CR>                     " ag search results
nnoremap <silent> <leader>fw  :Windows<CR>                " Windows

" SPACE DASH mapping will open the fuzzy finder just for the directory containing the currently edited file.
nnoremap <silent> <leader>b  :Files <C-r>=expand("%:h")<CR>/<CR>

" fzf-mru.vim                                             " MRU (most-recently-used) cache recently opened files
" ------------------------------------------------------------------------
nnoremap <silent> <leader>m :FZFMru<CR>
" only list files within current directory.
let g:fzf_mru_relative = 1

" Markdown / Writing

" vimtex                                                  " for editing LaTeX files.
" -------------------------------------------------------------------
let g:tex_flavor='latex'
let g:vimtex_view_method='zathura'
let g:vimtex_quickfix_mode=1

let g:latex_view_general_viewer = 'zathura'
let g:vimtex_quickfix_open_on_warning = 0
" let g:vimtex_quickfix_mode = 2
let g:vimtex_compiler_method = 'latexmk'

" TOC settings
let g:vimtex_toc_config = {
      \ 'name' : 'TOC',
      \ 'layers' : ['content', 'todo', 'include'],
      \ 'resize' : 1,
      \ 'split_width' : 40,
      \ 'todo_sorted' : 0,
      \ 'show_help' : 1,
      \ 'show_numbers' : 1,
      \ 'mode' : 2,
      \}

" augroup tex
"     autocmd!
"    autocmd filetype tex nnoremap <F1> :VimtexCompile<CR>
"    autocmd filetype tex nnoremap <F2> :VimtexView<CR>
"augroup

" nnoremap <localleader>lt :call vimtex#fzf#run()<cr>

"" configure concelment
" https://castel.dev/fpost/lecture-notes-1/
" set conceallevel=1
" let g:tex_conceal='abdmg'
"
" let g:vimtex_view_general_options  = ''
" let g:vimtex_view_general_options_latexmk = ''

" goyo                                                    " Distraction-free writing in Vim
" ------------------------------------------------------------------------
nnoremap <leader>z :set nolist<CR>:Goyo<CR>
let g:goyo_height = 120
let g:goyo_width = 120
" let g:goyo_linenr = 100

function! s:goyo_enter()
  " silent !tmux set status off
  " silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
  set noshowmode
  set noshowcmd
  set scrolloff=999
  Limelight
  let g:limelight_default_coefficient=0.7
endfunction

function! s:goyo_leave()
  " silent !tmux set status on
  " silent !tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z
  set showmode
  set showcmd
  set scrolloff=5
  Limelight!
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

" autocmd! User GoyoEnter Limelight
" autocmd! User GoyoLeave Limelight!

" limelight                                               " Highlighting of text under cursor
" ------------------------------------------------------------------------
" Color name (:help cterm-colors) or ANSI code
let g:limelight_conceal_ctermfg = 'gray'
let g:limelight_conceal_ctermfg = 240
"
" Color name (:help gui-colors) or RGB color
let g:limelight_conceal_guifg = 'DarkGray'
let g:limelight_conceal_guifg = '#777777'

" Default: 0.5
let g:limelight_default_coefficient = 0.7
" Number of preceding/following paragraphs to include (default: 0)
let g:limelight_paragraph_span = 1

" Beginning/end of paragraph
"   When there's no empty line between the paragraphs
"   and each paragraph starts with indentation
let g:limelight_bop = '^\s'
let g:limelight_eop = '\ze\n^\s'
"
" Highlighting priority (default: 10)
" Set it to -1 not to overrule hlsearch
let g:limelight_priority = -1

" LanguageTool                                            " grammar checker
" ------------------------------------------------------------------------
let g:languagetool_jar='/opt/LanguageTool/LanguageTool-5.0/languagetool-commandline.jar'
let g:languagetool_lang='en-US'

" targets.vim                                             " adds text objects to give you more targets
" ------------------------------------------------------------------------
let g:targets_aiAI = 'aiAI'

" vim-instant-markdown                                    "
" --------------------------------------------------------------------
let g:instant_markdown_autostart = 0    " disable autostart
" map <leader>md :InstantMarkdownPreview<CR>

" vim-browser-search                                      " Perform a quick web search for the text
" --------------------------------------------------------------------
nmap <silent> <leader>h <Plug>SearchNormal
vmap <silent> <leader>h <Plug>SearchVisual

let g:browser_search_default_engine = 'google'

let g:browser_search_engines = {
  \ 'google':'https://google.com/search?q=%s',
  \ 'github':'https://github.com/search?q=%s',
  \ 'stackoverflow':'https://stackoverflow.com/search?q=%s',
  \ 'bing': 'https://www.bing.com/search?q=%s',
  \ 'duckduckgo': 'https://duckduckgo.com/?q=%s',
  \ 'wikipedia': 'https://en.wikipedia.org/wiki/%s',
  \ 'youtube':'https://www.youtube.com/results?search_query=%s&page=&utm_source=opensearch',
  \ 'baidu':'https://www.baidu.com/s?ie=UTF-8&wd=%s'
  \ }

" vimux                                                   " vim plugin to interact with tmux
" -------------------------------------------------------------------
" Prompt for a command to run
map <leader>vp :VimuxPromptCommand<CR>
" Run last command executed by VimuxRunCommand
"
map <leader>vl :VimuxRunLastCommand<CR>
" Zoom the tmux runner pane
map <leader>vz :VimuxZoomRunner<CR>
" Close the tmux runner pane
map <leader>vc :VimuxCloseRunner<CR>
" Inspect runner pane
map <leader>vi :VimuxInspectRunner<CR>

" vimwiki                                                 " Personal Wiki for Vim
" -------------------------------------------------------------------
if !exists('g:syntax_on')
    filetype plugin indent on
    syntax on
    syntax enable
endif

" vimwiki diary template
nnoremap <leader>l :r ~/.vim/vimwiki/diary/template.md<CR>

let g:vimwiki_global_ext = 1
" let g:vimwiki_ext2syntax = {'.md': 'markdown'}

" Makes vimwiki markdown links as [text](text.md) instead of [text](text)
let g:vimwiki_markdown_link_ext = 1

" will prevent any link shortening
let g:vimwiki_url_maxsave = 0

let g:wiki_1 = {}
let wiki_1.path = '~/.vim/vimwiki/'
let wiki_1.path_html = '~/.vim/vimwiki/site'
let wiki_1.syntax = 'markdown'
let wiki_1.ext = '.md'
" let wiki_1.auto_tags = 1
let wiki_1.template_path = 'markdown'
let wiki_1.template_default = 'default'
let wiki_1.template_ext = '.html'
"let wiki_1.custom_wiki2html = '/home/mp466/.vim/scripts/wiki2html.sh'
"let wiki_1.nested_syntaxes = {'vimwiki': 'markdown'}

let g:vimwiki_list = [wiki_1]

function! VimwikiFindIncompleteTasks()
  vimgrep /- \[ \]/ %:p
  lopen
endfunction

function! VimwikiFindAllIncompleteTasks()
  VimwikiSearch /- \[ \]/
  lopen
endfunction

noremap <Leader>wa :call VimwikiFindAllIncompleteTasks()<CR>
noremap <Leader>wx :call VimwikiFindIncompleteTasks()<CR>

"}}}  ---------------- ending plugins ------------------------------------

" --------------------------------------------------------------------
highlight TechWordsToAvoid ctermbg=red ctermfg=white

function! MatchTechWordsToAvoid()
   match TechWordsToAvoid /\c\<\(obviously\|basically\|fix\|simply\|various\|very\|
   \  excellent\|interestingly\|significantly\|
   \  mostly\|largely\|huge\|tiny\|quite\|
   \  exceedingly\|quite\|remarkably\|few\|surprisingly\|
   \  substantially\|clearly\|vast\|relatively\|completely\|
   \  clearly\|just\|however\|todo\|many\|various\|fairly\|several\|extremely\)\>/
endfunction

"                           words to avoid
autocmd FileType markdown call MatchTechWordsToAvoid()
autocmd BufWinEnter *.md call MatchTechWordsToAvoid()
autocmd InsertEnter *.md call MatchTechWordsToAvoid()
autocmd InsertLeave *.md call MatchTechWordsToAvoid()
autocmd BufWinLeave *.md call clearmatches()

" underline cursorline
highlight clear CursorLine
highlight CursorLine gui=underline cterm=underline
highlight StatusLine cterm=underline ctermfg=8 ctermbg=None
highlight StatusLineNC cterm=underline ctermfg=8 ctermbg=None

"  remove color on links
" highlight Underlined ctermfg=white ctermbg=white
highlight Underlined None

"                       spelling  (needs to be at the end of .vimrc)
" ------------------------------------------------------------------------
" set spell spelllang=en_us
set spelllang=en_us
" length of list returned
set spellsuggest=10
set dictionary+=/usr/share/dict/words

" Spell checking  http://vimdoc.sourceforge.net/htmldoc/spell.html
noremap <leader>ss :setlocal spell!<cr>
" Move next misspelled forward
noremap <leader>sn ]s
" Move next misspelled back
noremap <leader>sp [s
" add word under cursor to dictionary
noremap <leader>sa zg
" suggest correctly spelled words
noremap <leader>s? z=
" take first suggestion for spelling correction
noremap <leader>s! z=1<CR><CR>

" Spelling clear bold
highlight clear SpellBad
" highlight Spell Bad term=standout ctermfg=1 term=underline cterm=underline
highlight SpellBad term=underline cterm=underline
" highlight clear Spell Cap
highlight SpellCap term=underline cterm=underline
" highlight clear Spell Rare
highlight SpellRare term=underline cterm=underline
" highlight clear Spell Local
highlight SpellLocal term=underline cterm=underline

" first mutt for my mail - it turns spell checking
" autocmd FileType mail setlocal spell spelllang=en_us

" activates spell check for Git commit messages
" autocmd BufRead COMMIT_EDITMSG setlocal spell spelllang=en_us
" autocmd set spelling on for Markdown files
" autocmd BufNewFile,BufRead *.md,*.mkd,*.markdown set spell spelllang=en_us

" Vim doesn't recognize *.md files as Markdown automatically. syntax highlighting and activate spell checking .md
" autocmd BufNewFile,BufRead *.md setfiletype=markdown spell

" '10 : marks will be remembered for up to 10 previously edited files
" "50 : will save up to 100 lines for each register
" :20 : up to 20 lines of command-line history will be remembered
" %   : saves and restores the buffer list
" n   : where to save the viminfo files
set viminfo='10,\"50,:20,%,n~/.vimtmp/viminfo

" include a dash, or : in keywords, commands like "w" consider "upper-case" to be one word.
set iskeyword+=:,_

" Put these lines at the very end of your vimrc file.

" Load all plugins now.
" Plugins need to be added to runtimepath before helptags can be generated.
packloadall

" Load all of the helptags now, after plugins have been loaded.
" All messages and errors will be ignored.
silent! helptags ALL
