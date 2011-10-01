command! -buffer -nargs=1 FindCommand  call JumpToTag(<f-args>, ['c', 'command'])
command! -buffer -nargs=1 FindFunction call JumpToTag(<f-args>, ['f', 'function'])
