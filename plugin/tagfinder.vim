if exists("g:loaded_tagfinder") || &cp
  finish
endif

let g:loaded_tagfinder = '0.0.1' " version number
let s:keepcpo          = &cpo
set cpo&vim

if !exists('b:tagfinder_commands')
  let g:tagfinder_commands = {}
endif

command! -nargs=+ DefineTagFinder call s:DefineTagFinder(<f-args>)
function s:DefineTagFinder(name, kinds)
  if !exists('b:tagfinder_commands')
    let b:tagfinder_commands = {}
  endif

  let b:tagfinder_commands[a:name] = split(a:kinds, ',')

  exe 'command! -buffer -nargs=1 -complete=customlist,tagfinder#CompleteTagFinder '.a:name.' call tagfinder#JumpToTag(<f-args>, "'.a:kinds.'")'
endfunction

command! -nargs=+ DefineGlobalTagFinder call s:DefineGlobalTagFinder(<f-args>)
function s:DefineGlobalTagFinder(name, kinds)
  let g:tagfinder_commands[a:name] = split(a:kinds, ',')

  exe 'command! -nargs=1 -complete=customlist,tagfinder#CompleteTagFinder '.a:name.' call tagfinder#JumpToTag(<f-args>, "'.a:kinds.'")'
endfunction

let &cpo = s:keepcpo
unlet s:keepcpo
