" Stores the current window in the quit history, so we can undo the :quit
" later.
function! undoquit#SaveWindowQuitHistory()
  if !s:IsStorable(bufnr('%'))
    return
  endif

  if !exists('g:undoquit_stack')
    let g:undoquit_stack = []
  endif

  let window_data = undoquit#GetWindowRestoreData()

  call add(g:undoquit_stack, window_data)
endfunction

function! undoquit#Tabclose(prefix_count, suffix_count, bang)
  if a:suffix_count != ''
    let tab_description = a:suffix_count
  elseif a:prefix_count > 0
    let tab_description = a:prefix_count
  else
    let tab_description = ''
  endif

  if tab_description != ''
    exe 'tabnext ' . tab_description
  endif

  for bufnr in tabpagebuflist()
    if bufexists(bufnr)
      let winnr = bufwinnr(bufnr)
      exe winnr.'wincmd w'
      exe 'quit'.a:bang
    endif
  endfor
endfunction

" Restores the last-:quit window.
function! undoquit#RestoreWindow()
  if !exists('g:undoquit_stack') || empty(g:undoquit_stack)
    echo "No closed windows to undo"
    return
  endif

  let window_data = remove(g:undoquit_stack, -1)
  let real_buffers = s:RealTabBuffers()

  if len(real_buffers) == 0
    " then there's nothing of importance in this tab, let's just clear it and
    " use "edit"
    let window_data.open_command = 'only | edit'
  endif

  if window_data.neighbour_buffer != '' &&
        \ bufnr(window_data.neighbour_buffer) >= 0
    " try to find the latest-opened window with that buffer:
    let max_winid = max(win_findbuf(bufnr(window_data.neighbour_buffer)))
    if max_winid > 0
      call win_gotoid(max_winid)
    endif
  endif

  exe window_data.open_command.' '.escape(fnamemodify(window_data.filename, ':~:.'), ' ')

  if has_key(window_data, 'view')
    call winrestview(window_data.view)
  endif

  if has_key(window_data, 'height')
    exe 'resize ' .. window_data.height
  endif

  if has_key(window_data, 'width')
    exe 'vertical resize ' .. window_data.width
  endif
endfunction

function! undoquit#RestoreTab()
  if !exists('g:undoquit_stack') || empty(g:undoquit_stack)
    echo "No closed tabs to undo"
    return
  endif

  let last_window = g:undoquit_stack[len(g:undoquit_stack) - 1]
  let last_tab    = last_window.tabpagenr

  while last_window.tabpagenr == last_tab
    call undoquit#RestoreWindow()

    if len(g:undoquit_stack) > 0
      let last_window = g:undoquit_stack[len(g:undoquit_stack) - 1]
    else
      break
    endif

    if last_window.open_command == '1tabnew'
      " then this was the window that opens a new tab page, stop here
      break
    endif
  endwhile
endfunction

" Fetches the data we need to successfully restore a window we're just about
" to :quit.
function! undoquit#GetWindowRestoreData()
  let data = {
        \ 'filename':  expand('%:p'),
        \ 'tabpagenr': tabpagenr(),
        \ 'view':      winsaveview(),
        \ }

  let real_buffers = s:RealTabBuffers()

  if len(real_buffers) == 1
    " then this is the last buffer in this tab
    let data.neighbour_buffer = ''
    let data.open_command     = (tabpagenr() - 1).'tabnew'
    return data
  endif

  let neighbour_window = {}
  let is_max_width = winwidth(0) == &columns
  let is_max_height = winheight(0) + &cmdheight + (&laststatus >= 1 ? 1 : 0) == &lines

  let neighbours = []

  for direction in 'hjkl'
    let neighbour_window = s:GetNeighbourWindow(direction)
    if empty(neighbour_window)
      continue
    else
      call add(neighbours, neighbour_window)
    endif
  endfor

  let split_command = ''

  " 1. Try to find a perfect neighbour with the same width/height
  for neighbour_window in neighbours
    let direction   = neighbour_window.direction
    let same_height = neighbour_window.height == winheight(0)
    let same_width  = neighbour_window.width == winwidth(0)

    if same_height && direction == 'h'
      let data.neighbour_buffer = ''
      let split_command = 'rightbelow vsplit'
    elseif same_width && direction == 'j'
      let split_command = 'leftabove split'
    elseif same_width && direction == 'k'
      let split_command = 'rightbelow split'
    elseif same_height && direction == 'l'
      let split_command = 'leftabove vsplit'
    endif

    if split_command != ''
      let data.neighbour_buffer = neighbour_window.buffer
      let data.width = neighbour_window.width
      let data.height = neighbour_window.height
      break
    endif
  endfor

  " 2. Try to find a neighbour to create a max-height or max-width window from
  if split_command == '' && (is_max_width || is_max_height)
    for neighbour_window in neighbours
      let direction = neighbour_window.direction

      if is_max_height && direction == 'h'
        let split_command = 'rightbelow botright vsplit'
      elseif is_max_width && direction == 'j'
        let split_command = 'leftabove topleft split'
      elseif is_max_width && direction == 'k'
        let split_command = 'rightbelow botright split'
      elseif is_max_height && direction == 'l'
        let split_command = 'leftabove topleft vsplit'
      endif

      if split_command != ''
        let data.neighbour_buffer = neighbour_window.buffer
        break
      endif
    endfor
  endif

  " 3. Just pick any existing one as a fallback
  if split_command == '' && !empty(neighbours)
    let neighbour_window = neighbours[0]
    let direction = neighbour_window.direction

    if direction == 'h'
      let split_command = 'rightbelow vsplit'
    elseif direction == 'j'
      let split_command = 'leftabove split'
    elseif direction == 'k'
      let split_command = 'rightbelow split'
    elseif direction == 'l'
      let split_command = 'leftabove vsplit'
    endif

    let data.neighbour_buffer = neighbour_window.buffer
  endif

  if split_command != ''
    let data.width = winwidth(0)
    let data.height = winheight(0)
    let data.open_command = join([
          \ 'tabnext ' .. data.tabpagenr,
          \ split_command,
          \ ], ' | ')
  else
    " default case, no listed buffers around
    let data.neighbour_buffer = ''
    let data.open_command     = 'edit'
  endif

  return data
endfunction

function! s:GetNeighbourWindow(direction)
  let current_bufnr = bufnr('%')
  let current_winnr = winnr()
  let data = {}

  try
    exe 'wincmd '.a:direction
    let neighbour_bufnr = bufnr('%')
    let neighbour_winnr = winnr()

    if current_winnr == neighbour_winnr
      " then we haven't moved, nothing in this direction
      return {}
    endif

    if !s:IsStorable(neighbour_bufnr)
      " then it's a temporary window that we can't restore
      return {}
    endif

    return {
          \ 'direction': a:direction,
          \ 'buffer':    expand('%'),
          \ 'height':    winheight(0),
          \ 'width':     winwidth(0),
          \ }
  finally
    exe current_winnr.'wincmd w'
  endtry
endfunction

function! s:RealTabBuffers()
  return filter(copy(tabpagebuflist()), 's:IsStorable(v:val)')
endfunction

function! s:IsStorable(bufnr)
  if buflisted(a:bufnr) && getbufvar(a:bufnr, '&buftype') == ''
    return 1
  else
    return getbufvar(a:bufnr, '&buftype') == 'help'
  endif
endfunction
