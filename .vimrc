"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Core Settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible              " Use Vim defaults instead of 100% vi compatibility

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plug plugins
call plug#begin()

Plug 'sheerun/vim-polyglot'
Plug 'phanviet/vim-monokai-pro'

call plug#end()

filetype plugin indent on     " Enable file type detection and do language-dependent indenting
syntax enable                 " Enable syntax highlighting without overriding custom colors

" Leader key (Space is easy to reach with both thumbs)
let mapleader = " "

" Enable mouse support in all modes
set mouse=a

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Editor Behavior
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tab and indentation settings
set tabstop=2               " Width of tab character
set softtabstop=2          " Fine tunes amount of whitespace to be inserted
set shiftwidth=2           " Amount of whitespace to use for auto-indentation
set expandtab              " Use spaces instead of tabs

" Map Shift-Tab in different modes
" For normal mode
nnoremap <S-Tab> <<
" For insert mode
inoremap <S-Tab> <C-d>
" For visual mode
vnoremap <S-Tab> <gv

" Ensure tab behavior is consistent
inoremap <Tab> <Space><Space>

" Search
set incsearch                " Show matches while typing search pattern
set ignorecase               " Ignore case in search patterns
set smartcase                " Override ignorecase if search pattern contains uppercase

" Editor Display
set ruler                    " Show cursor position at bottom
set showmode                 " Show current mode in command-line
set number                   " Show line numbers
set relativenumber           " Show relative line numbers for easy movement
set scrolloff=4              " Min number of lines to keep above/below cursor
set sidescrolloff=8          " Min number of columns to keep left/right of cursor
set hidden                   " Allow switching buffers without saving
set backspace=2              " Modern backspace behavior

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Cursor and File Position Memory
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Jump to last position when reopening a file
autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Key Mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Visual Mode - Better indenting (keeps selection after indent)
vmap < <gv
vmap > >gv

" Window Navigation - Use Ctrl + hjkl to switch between windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Terminal settings
" Map both Ctrl+S and a terminal-friendly Command+S equivalent
noremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>
vnoremap <C-s> <Esc>:w<CR>

" Buffer Navigation
nnoremap <leader>n :bnext<CR>        " Next buffer
nnoremap <leader>p :bprevious<CR>    " Previous buffer
nnoremap <leader>d :bdelete<CR>      " Delete current buffer

" Clear Search Highlighting
nnoremap <Esc> :noh<CR>

" Window Splitting
nnoremap <leader>v <C-w>v            " Split window vertically
nnoremap <leader>s <C-w>s            " Split window horizontally

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Appearance
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set termguicolors
colorscheme monokai_pro
let loaded_matchparen = 1             " Disable parentheses matching highlighting

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Text Editing Improvements
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Create undo break-points for easier undo/redo
inoremap , ,<C-g>u
inoremap . .<C-g>u
inoremap ! !<C-g>u
inoremap ? ?<C-g>u

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set path for find
set path+=**
set wildmenu
set wildmode=longest:full,full


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Quickfix Enhancements + Better grepping
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Quick Reference
" <Esc>      - Close quickfix window from any pane (or clear search highlight)
" <leader>rg - Grep search (regular expression mode)
" <leader>rf - Grep search (literal/fixed string mode)
" ]f         - Jump to next file in quickfix results
" [f         - Jump to previous file in quickfix results
" <leader>rt - Search in specific file types (e.g., py,js,rs)
" <leader>rh - Search in current file's directory only
" <leader>rw - Search for word under cursor (hello_world -> hello)
" <leader>rW - Search for WORD under cursor (hello_world -> hello_world)
" <leader>rd - Search in specific directory
" <leader>qf - Filter existing quickfix results
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Configure Vim to use ripgrep for grep
if executable('rg')
    set grepprg=rg\ --vimgrep\ --smart-case\ --follow
    set grepformat=%f:%l:%c:%m
endif

" Helper function to execute grep and open quickfix
function! ExecuteGrepAndOpen(command)
    let output = execute(a:command)
    if !empty(output) && output !~# '^E\d\+:'
        copen
        " Force syntax refresh
        syntax sync fromstart
        " Alternative method if needed:
        " syntax off | syntax on
    else
        echo output
    endif
endfunction

" Also add this to the quickfix autocommands to ensure proper highlighting
augroup grep_quickfix
    autocmd!
    autocmd FileType qf setlocal nonumber norelativenumber nowrap foldcolumn=0
    " Refresh syntax when entering quickfix window
    autocmd BufEnter quickfix syntax sync fromstart
    " Refresh syntax when leaving quickfix window
    autocmd BufLeave quickfix syntax sync fromstart
augroup END
" Close quickfix with Esc, otherwise clear search highlight
nnoremap <silent> <Esc> :call CloseQuickfixOrNoh()<CR>

function! CloseQuickfixOrNoh()
    if !empty(filter(getwininfo(), 'v:val.quickfix'))
        cclose
    else
        noh
    endif
endfunction

" Grep and open quickfix after pressing Enter
nnoremap <leader>rg :call GrepAndOpenQuickfix()<CR>
nnoremap <leader>rf :call GrepAndOpenQuickfix('literal')<CR>

function! GrepAndOpenQuickfix(...)
    let search_type = get(a:, 1, 'normal')
    if search_type == 'literal'
        let command = 'grep! -F '
    else
        let command = 'grep '
    endif
    let search_term = input(command)
    call ExecuteGrepAndOpen(command . search_term)
endfunction

" Navigate through grouped matches
function! QuickfixGroupNext()
    let l:current_file = expand('%:p')
    let l:current_line = line('.')
    let l:qf_list = getqflist()
    let l:next_file = ''
    
    for item in l:qf_list
        if item.bufnr != bufnr(l:current_file) && 
                    \ fnamemodify(bufname(item.bufnr), ':p') > l:current_file
            let l:next_file = fnamemodify(bufname(item.bufnr), ':p')
            break
        endif
    endfor
    
    if l:next_file != ''
        execute 'cfirst'
        while expand('%:p') != l:next_file && !empty(getqflist())
            execute 'cnext'
        endwhile
    endif
endfunction

" Navigate to next/previous file in quickfix
nnoremap ]f :call QuickfixGroupNext()<CR>
nnoremap [f :cpfile<CR>

" Search in specific file types
function! GrepFileType()
    let extensions = input('File extensions (e.g., rb,js,ts,html): ')
    let pattern = input('Search pattern: ')
    let glob_pattern = '{**/*.' . join(split(extensions, ',\s*'), ',**/*.') . '}'
    call ExecuteGrepAndOpen('grep --glob "' . glob_pattern . '" ' . pattern)
endfunction
nnoremap <leader>rt :call GrepFileType()<CR>

" Search in current file's directory only
function! GrepHere()
    let pattern = input('Search in current dir: ')
    call ExecuteGrepAndOpen('grep ' . pattern . ' ' . expand('%:h'))
endfunction
nnoremap <leader>rh :call GrepHere()<CR>

" Search for word under cursor
nnoremap <leader>rw :call ExecuteGrepAndOpen('grep <cword>')<CR>

" Search for WORD under cursor (includes punctuation)
nnoremap <leader>rW :call ExecuteGrepAndOpen('grep <cWORD>')<CR>

" Search in specific directory
function! GrepDir()
    let dir = input('Directory: ', '', 'dir')
    let pattern = input('Search pattern: ')
    call ExecuteGrepAndOpen('grep ' . pattern . ' ' . dir)
endfunction
nnoremap <leader>rd :call GrepDir()<CR>

" Filter quickfix list
function! FilterQuickfix()
    let pattern = input('Filter pattern: ')
    if pattern != ''
        let qf_list = getqflist()
        call filter(qf_list, 'v:val.text =~ ' . string(pattern))
        call setqflist(qf_list)
    endif
endfunction
nnoremap <leader>qf :call FilterQuickfix()<CR>
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Incremental search
set incsearch
set hlsearch

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Save to system clipboard
set clipboard=unnamed
" Make p and P always use the yank register (register 0)
nnoremap y "*y
nnoremap Y "*Y
vnoremap y "*y
nnoremap yy "*yy

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Auto-detect comment style based on filetype
augroup commenting_blocks_of_code
    autocmd!
    " Programming Languages
    autocmd FileType c,cpp,java,javascript,typescript,rust,go let b:comment_char = '//'
    autocmd FileType python,ruby,perl,sh,zsh,bash,fish        let b:comment_char = '#'
    autocmd FileType vim                                      let b:comment_char = '"'
    
    " Web Development
    autocmd FileType html,xml                                 let b:comment_char = '<!--'
    autocmd FileType html,xml                                 let b:comment_end = ' -->'
    autocmd FileType css,scss,less                           let b:comment_char = '/*'
    autocmd FileType css,scss,less                           let b:comment_end = ' */'
    
    " Config files
    autocmd FileType yaml,toml,dockerfile                     let b:comment_char = '#'
    autocmd FileType json                                     let b:comment_char = '//'
    autocmd FileType sql                                      let b:comment_char = '--'
    
    " Default for unknown filetypes
    autocmd FileType * if !exists('b:comment_char')          | let b:comment_char = '#' | endif
augroup END

" Initialize comment_end for filetypes that don't use it
autocmd FileType * if !exists('b:comment_end') | let b:comment_end = '' | endif

" Improved comment function
function! CommentLines() range
    let l:save_cursor = getpos(".")
    let l:first_line = getpos("'<")[1]
    let l:last_line = getpos("'>")[1]
    
    " Get minimum indentation level
    let l:min_indent = -1
    for l:line_num in range(l:first_line, l:last_line)
        let l:line = getline(l:line_num)
        if l:line !~ '^\s*$'  " Skip empty lines
            let l:indent = len(matchstr(l:line, '^\s*'))
            if l:min_indent == -1 || l:indent < l:min_indent
                let l:min_indent = l:indent
            endif
        endif
    endfor
    
    " If no valid lines found, return
    if l:min_indent == -1
        return
    endif
    
    " Add comments at the minimum indentation level
    for l:line_num in range(l:first_line, l:last_line)
        let l:line = getline(l:line_num)
        if l:line !~ '^\s*$'  " Skip empty lines
            let l:indent = repeat(' ', l:min_indent)
            let l:rest_of_line = strpart(l:line, l:min_indent)
            call setline(l:line_num, l:indent . b:comment_char . ' ' . l:rest_of_line)
        endif
    endfor
    
    call setpos('.', l:save_cursor)
endfunction

" Improved uncomment function
function! UncommentLines() range
    let l:save_cursor = getpos(".")
    let l:first_line = getpos("'<")[1]
    let l:last_line = getpos("'>")[1]
    
    for l:line_num in range(l:first_line, l:last_line)
        let l:line = getline(l:line_num)
        " Match comment pattern with any leading whitespace
        let l:pattern = '^\(\s*\)' . escape(b:comment_char, '/*') . '\s\?'
        if l:line =~ l:pattern
            let l:new_line = substitute(l:line, l:pattern, '\1', '')
            call setline(l:line_num, l:new_line)
        endif
    endfor
    
    call setpos('.', l:save_cursor)
endfunction

" Visual mode mappings
vnoremap <leader>c :call CommentLines()<CR>
vnoremap <leader>u :call UncommentLines()<CR>

" Block comment mappings for languages that support it
vnoremap <leader>cb :call CommentBlock()<CR>
vnoremap <leader>ub :call UncommentBlock()<CR>

" Block comment functions (unchanged)
function! CommentBlock()
    let l:ft = &filetype
    if l:ft == 'javascript' || l:ft == 'typescript' || l:ft == 'css' || l:ft == 'scss' || l:ft == 'less' || l:ft == 'java' || l:ft == 'c' || l:ft == 'cpp'
        execute "'<,'>s!^!/* !"
        execute "'<,'>s!$! */!"
    elseif l:ft == 'html' || l:ft == 'xml'
        execute "'<,'>s!^!<!-- !"
        execute "'<,'>s!$! -->!"
    endif
    noh
endfunction

function! UncommentBlock()
    let l:ft = &filetype
    if l:ft == 'javascript' || l:ft == 'typescript' || l:ft == 'css' || l:ft == 'scss' || l:ft == 'less' || l:ft == 'java' || l:ft == 'c' || l:ft == 'cpp'
        execute "'<,'>s!/\* !!g"
        execute "'<,'>s! \*/!!g"
    elseif l:ft == 'html' || l:ft == 'xml'
        execute "'<,'>s!<!-- !!g"
        execute "'<,'>s! -->!!g"
    endif
    noh
endfunction

" Status Line
set laststatus=2

hi User1 ctermfg=green ctermbg=black
hi User2 ctermfg=yellow ctermbg=black
hi User3 ctermfg=red ctermbg=black
hi User4 ctermfg=blue ctermbg=black
hi User5 ctermfg=white ctermbg=black

set statusline=
set statusline +=%1*\ %n\ %*            "buffer number
set statusline +=%5*%{&ff}%*            "file format
set statusline +=%3*%y%*                "file type
set statusline +=%4*\ %<%F%*            "full path
set statusline +=%2*%m%*                "modified flag
set statusline +=%1*%=%5l%*             "current line
set statusline +=%2*/%L%*               "total lines
set statusline +=%1*%4v\ %*             "virtual column number
set statusline +=%2*0x%04B\ %*          "character under cursor


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tips:
" - Leader key is space
" - Use Ctrl+hjkl to navigate between windows
" - Use leader+v for vertical split, leader+s for horizontal split
" - Use leader+n/p to switch buffers
" - Use Ctrl+s to save
" - Use Esc to clear search highlighting
" - Relative numbers help with movement commands (5j, 3k, etc.)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

