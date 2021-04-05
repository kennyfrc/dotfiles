" Kenn's settings
syntax on

" Tabbing creates 4 spaces
set tabstop=4

" Ensure that once you hit enter, it automatically indents
set autoindent

" Ensure that your cursor stays in the middle as much as possible
set scrolloff=999

" Ensure that whenever doing splits, it does it either below or to the right
set splitbelow
set splitright

" Nicely formatted windows
set winwidth=84
" We have to have a winheight bigger than we want to set winminheight. But if
" we set winheight to be huge before winminheight, the winminheight set will
" fail.
set winheight=5
set winminheight=5
set winheight=999

