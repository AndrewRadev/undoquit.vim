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

if !exists('g:undoquit_tab_mapping')
  let g:undoquit_tab_mapping = '<c-w>U'
endif

autocmd QuitPre * call undoquit#SaveWindowQuitHistory()

command Undoquit    call undoquit#RestoreWindow()
command UndoquitTab call undoquit#RestoreTab()

if has('patch-7.4.542')
  command -addr=tabs -range -nargs=? -bang UndoableTabclose
        \ call undoquit#Tabclose(<count>, <q-args>, '<bang>')
else
  command -count -nargs=? -bang UndoableTabclose
        \ call undoquit#Tabclose(<count>, <q-args>, '<bang>')
endif

if g:undoquit_mapping != ''
  exe 'nnoremap <silent> '.g:undoquit_mapping.' :call undoquit#RestoreWindow()<cr>'
endif

if g:undoquit_tab_mapping != ''
  exe 'nnoremap <silent> '.g:undoquit_tab_mapping.' :call undoquit#RestoreTab()<cr>'
endif

let &cpo = s:keepcpo
unlet s:keepcpo
