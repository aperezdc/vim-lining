" Author: Adrián Pérez de Castro <aperez@igalia.com>
" License: GPLv3

if exists('g:loaded_lining')
	finish
endif
let g:loaded_lining = 1

let s:save_cpo = &cpo
set cpo&vim

set laststatus=2
if get(g:, 'lining#showmode', 1)
	set showmode
endif

augroup lining
	autocmd!
	autocmd VimEnter,WinEnter,BufWinEnter,BufUnload,VimResized,FileType * call lining#refresh()
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
