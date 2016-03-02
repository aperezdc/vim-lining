" Author: Adrián Pérez de Castro <aperez@igalia.com>
" License: GPLv3

if exists('g:loaded_lining')
	finish
endif
let g:loaded_lining = 1

let s:save_cpo = &cpo
set cpo&vim

augroup lining
	autocmd!
	autocmd VimEnter,WinEnter,BufWinEnter * call lining#refresh()
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
