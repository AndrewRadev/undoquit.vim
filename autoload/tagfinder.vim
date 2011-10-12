function! tagfinder#CompleteTagFinder(lead, command_line, cursor_pos)
  if !exists('b:tagfinder_commands')
    let b:tagfinder_commands = {}
  endif

  let command_name       = s:ExtractCommandName(a:command_line)
  let tagfinder_commands = extend(g:tagfinder_commands, b:tagfinder_commands)
  let kinds              = tagfinder_commands[command_name]

  if len(a:lead) > 0
    let tag_prefix = a:lead
  else
    let tag_prefix = '.'
  endif

  return sort(tagfinder#FindTagNamesByPrefix(tag_prefix, kinds))
endfunction

function! tagfinder#FindTagNamesByPrefix(prefix, kinds)
  let tag_set = {}

  for entry in taglist('^'.a:prefix)
    if index(a:kinds, entry.kind) > -1
      let tag_set[entry.name] = 1
    endif
  endfor

  return keys(tag_set)
endfunction

function! tagfinder#FindTags(name, kinds)
  let tag_list = []

  for entry in taglist('^'.a:name.'$')
    if index(a:kinds, entry.kind) > -1
      call add(tag_list, entry)
    endif
  endfor

  return tag_list
endfunction

function! tagfinder#JumpToTag(name, kinds)
  let kinds  = split(a:kinds, ',')
  let qflist = []

  for entry in tagfinder#FindTags(a:name, kinds)
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

function! s:ExtractCommandName(command_line)
  let command_line = substitute(a:command_line, '^.*|', '', '')
  let parts        = split(command_line, '\s\+')
  return parts[0]
endfunction
