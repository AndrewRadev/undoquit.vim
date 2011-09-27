function! FindTagNamesByPrefix(prefix, kinds)
  let tag_set = {}

  for entry in taglist('^'.a:prefix)
    if index(a:kinds, entry.kind) > -1
      let tag_set[entry.name] = 1
    endif
  endfor

  return keys(tag_set)
endfunction

function! FindTag(name, kinds)
  let tag_list = []

  for entry in taglist(a:name)
    if index(a:kinds, entry.kind) > -1
      call add(tag_list, entry)
    endif
  endfor

  return tag_list
endfunction
