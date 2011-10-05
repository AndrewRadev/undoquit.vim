if !exists('b:tagfinder_commands')
  let b:tagfinder_commands = {}
endif

command! -nargs=+ DefineTagCommand call s:DefineTagCommand(<f-args>)
function s:DefineTagCommand(name, kinds)
  let b:tagfinder_commands[a:name] = split(a:kinds, ',')

  exe 'command! -nargs=1 -complete=customlist,CompleteTagFinder '.a:name.' call JumpToTag(<f-args>, "'.a:kinds.'")'
endfunction

function! CompleteTagFinder(lead, command_line, cursor_pos)
  let command_name = split(a:command_line, '\s\+')[0]
  let kinds        = b:tagfinder_commands[command_name]

  if len(a:lead) > 0
    let tag_prefix = a:lead
  else
    let tag_prefix = '.'
  endif

  return sort(FindTagNamesByPrefix(tag_prefix, kinds))
endfunction

function! FindTagNamesByPrefix(prefix, kinds)
  let tag_set = {}

  for entry in taglist('^'.a:prefix)
    if index(a:kinds, entry.kind) > -1
      let tag_set[entry.name] = 1
    endif
  endfor

  return keys(tag_set)
endfunction

function! FindTags(name, kinds)
  let tag_list = []

  for entry in taglist(a:name)
    if index(a:kinds, entry.kind) > -1
      call add(tag_list, entry)
    endif
  endfor

  return tag_list
endfunction

function! JumpToTag(name, kinds)
  let kinds  = split(a:kinds, ',')
  let qflist = []

  for entry in FindTags(a:name, kinds)
    let filename = entry.filename
    let pattern  = substitute(entry.cmd, '^/\(.*\)/$', '\1', 'g')

    call add(qflist, {
          \ 'filename': filename,
          \ 'pattern':  pattern,
          \ })
  endfor

  if len(qflist) == 0
    echohl Error | echo "No tags found" | echohl NONE
  elseif len(qflist) == 1
    call setqflist(qflist)
    silent cfirst
  else
    call setqflist(qflist)
    copen
  endif
endfunction
