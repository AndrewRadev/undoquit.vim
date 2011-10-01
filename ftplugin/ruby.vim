command! -buffer -nargs=1 FindClass    call JumpToTag(<f-args>, ['c', 'class'])
command! -buffer -nargs=1 FindFunction call JumpToTag(<f-args>, ['f', 'function', 'F', 'singleton method'])

command! -buffer -nargs=1 -complete=customlist,s:CompleteFindClass FindClass call JumpToTag(<f-args>, ['c', 'class'])
function! s:CompleteFindClass(lead, command_line, cursor_pos)
  let segments = split(a:command_line, '\s\+')

  if len(segments) > 1
    let tag_prefix = segments[-1]
  else
    let tag_prefix = '.'
  endif

  return sort(FindTagNamesByPrefix(tag_prefix, ['c', 'class']))
endfunction
