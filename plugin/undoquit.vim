if exists('g:loaded_undoquit') || &cp
  finish
endif

" The plugin requires Vim 7.4
if v:version < 704
  finish
endif

let g:loaded_undoquit = '0.1.0' " version number
let s:keepcpo = &cpo
set cpo&vim

if !exists('g:undoquit_mapping')
  let g:undoquit_mapping = '<c-w>u'
endif

autocmd QuitPre * call undoquit#SaveWindowQuitHistory()
command Undoquit :call undoquit#UndoQuitWindow()

if g:undoquit_mapping != ''
  exe 'nnoremap '.g:undoquit_mapping.' :call undoquit#UndoQuitWindow()<cr>'
endif

let &cpo = s:keepcpo
unlet s:keepcpo
