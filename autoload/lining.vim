" Author: Adrián Pérez de Castro <aperez@igalia.com>
" License: GPLv3

if exists('g:loaded_lining_autoload')
	finish
endif
let g:loaded_lining_autoload = 1

let s:save_cpo = &cpo
set cpo&vim


function lining#color(active, group, content)
	if a:active
		return '%#' . a:group . '#' . a:content . '%#StatusLine#'
	else
		return a:content
	endif
endfunction


function lining#status(winnum)
  let active = a:winnum == winnr()
  let bufnum = winbufnr(a:winnum)

  let alt  = 0
  let fmt  = ''
  let type = getbufvar(bufnum, '&buftype')
  let name = bufname(bufnum)

  if type ==# 'help'
    let fmt .= lining#color(active, 'LiningBufName', ' help ')
    let fmt .= lining#color(active, 'LiningItem', ' ' . fnamemodify(name, ':t:r'))
    return fmt
  endif

  " File name
  let fmt .= lining#color(active, 'LiningBufName', ' %<%f ')

  " Paste mode
  if active && &paste
    let fmt .= lining#color(active, 'LiningWarn', ' PASTE ')
  endif

  " File flags
  let fmt .= lining#color(active, 'LinigItem', ' %r%m%w ')

  let fmt .= '%='  " Switch to the right side

  " FiletypeA
  let fmt .= lining#color(active, 'LiningItem', ' %{&filetype} ')

  " Git branch
  if exists('*fugitive#head')
    let head = fugitive#head()
    if empty(head) && exists('*fugitive#detect') && !exists('b:git_dir')
      call fugitive#detect(getcwd())
      let head = fugitive#head()
    endif
    if !empty(head)
      let fmt .= lining#color(active, 'LiningVertSep', '·')
      let fmt .= lining#color(active, 'LiningVcsInfo', ' ' . head . ' ')
    endif
  endif

  " Line/Column
  let fmt .= lining#color(active, 'LiningLnCol', ' %4l:%-3c ')

  return fmt
endfunction


function lining#refresh()
  for nr in range(1, winnr('$'))
    call setwinvar(nr, '&statusline', '%!lining#status(' . nr . ')')
  endfor
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
