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
        \ bufnr(window_data.neighbour_buffer) >= 0 &&
        \ bufwinnr(bufnr(window_data.neighbour_buffer)) >= 0
    let neighbour_window = bufwinnr(bufnr(window_data.neighbour_buffer))
    exe neighbour_window.'wincmd w'
  endif

  exe window_data.open_command.' '.escape(fnamemodify(window_data.filename, ':~:.'), ' ')

  if has_key(window_data, 'view')
    call winrestview(window_data.view)
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
  let window_data = {
        \ 'filename':  expand('%:p'),
        \ 'tabpagenr': tabpagenr(),
        \ 'view':      winsaveview(),
        \ }

  let real_buffers = s:RealTabBuffers()

  if len(real_buffers) == 1
    " then this is the last buffer in this tab
    let window_data.neighbour_buffer = ''
    let window_data.open_command     = (tabpagenr() - 1).'tabnew'
    return window_data
  endif

  " attempt to store neighbouring buffers as split-base-points
  if s:UseNeighbourWindow('j', 'leftabove split',   window_data) | return window_data | endif
  if s:UseNeighbourWindow('k', 'rightbelow split',  window_data) | return window_data | endif
  if s:UseNeighbourWindow('l', 'rightbelow vsplit', window_data) | return window_data | endif
  if s:UseNeighbourWindow('h', 'leftabove vsplit',  window_data) | return window_data | endif

  " default case, no listed buffers around
  let window_data.neighbour_buffer = ''
  let window_data.open_command     = 'edit'
  return window_data
endfunction

" Attempts to use a neighbouring window in the direction a:direction as a base
" point from which to restore a previously-:quit window.
"
" Returns true if it found an appropriate window in that direction, false if
" it didn't.
function! s:UseNeighbourWindow(direction, split_command, window_data)
  let current_bufnr = bufnr('%')
  let current_winnr = winnr()

  try
    exe 'wincmd '.a:direction
    let bufnr = bufnr('%')
    if s:IsStorable(bufnr) && bufnr != current_bufnr
      " then we have a neighbouring buffer above
      let a:window_data.neighbour_buffer = expand('%')
      let a:window_data.open_command = join([
            \ 'tabnext '.a:window_data.tabpagenr,
            \ a:split_command,
            \ ], ' | ')
      return 1
    else
      return 0
    endif
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
