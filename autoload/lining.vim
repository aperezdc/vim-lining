" vim: set foldmethod=marker
"
" Author: Adrián Pérez de Castro <aperez@igalia.com>
" License: GPLv3

if exists('g:loaded_lining_autoload')
  finish
endif
let g:loaded_lining_autoload = 1

let s:save_cpo = &cpo
set cpo&vim

" Cache type codes. {{{1
"
" A Funcref attached directly to a dictionary may have a different type code
" than an unattached function. Defining a dummy function in a Dict and using
" it to obtain the type code is the safest way that works for Vim and NeoVim.
"
let s:dummy = {}
function s:dummy.dummier()
	return ''
endfunction

let s:TYPE_FREF = type(s:dummy.dummier)
let s:TYPE_DICT = type({})

unlet s:dummy  " Remove the dummy dictionary 1}}}

let s:left_items = []
let s:right_items = []


function s:colorize(active, group, content)
  if a:active
    return '%#' . a:group . '#' . a:content . '%#StatusLine#'
  else
    return a:content
  endif
endfunction


function s:add_item(lr, format, color)
	let l:id = len(a:lr)
	if type(a:format) == s:TYPE_DICT
		" Assume it's a properly set up Dict
		if a:color != ''
			" Color override
			let a:format.color = a:color
		endif
		call add(a:lr, a:format)
	else
		let v = { 'format': a:format }
		if a:color != ''
			let v.color = a:color
		endif
		call add(a:lr, l:v)
	endif
	return l:id
endfunction


function s:format(item, active, bufnum)
	let hlgroup = 'Lining' . get(a:item, 'color', 'Item')
	let text = ''
	if type(a:item.format) == s:TYPE_FREF
		" Evaluate the formatting function
		let text = a:item.format(a:item, a:active, a:bufnum)
	else
		let text = a:item.format
	endif
	if !empty(l:text)
		if get(a:item, 'nospace', 0) == 0
			let text = ' ' . text . ' '
		endif
		return s:colorize(a:active, hlgroup, text)
	else
		return ''
	endif
endfunction


function lining#left(format, ...)
	let color = 'Item'
	if a:0 > 0
		let color = a:1
	endif
	return s:add_item(s:left_items, a:format, color)
endfunction


function lining#right(format, ...)
	let color = 'Item'
	if a:0 > 0
		let color = a:1
	endif
	return s:add_item(s:right_items, a:format, color)
endfunction


" Buffer name
let s:filename_item = { 'nospace': 1 }
function s:filename_item.format(item, active, bufnum)
	let path = expand(bufname(a:bufnum))
	if empty(path)
		return '%< %f '
	endif
	let path = fnamemodify(path, ':p:~:.:h')
	if path == '.'
		let path = '%< '
	else
		let path = '%< ' . path . '/'
	endif
	return s:colorize(a:active, 'LiningBufPath', path)
				\ . s:colorize(a:active, 'LiningBufName', '%t ')
endfunction
call lining#left(s:filename_item, 'BufName')

" File flags
let s:flags_item = {}
function s:flags_item.format(item, active, bufnum)
	let f = ''
	if getbufvar(a:bufnum, '&readonly')
		let f .= '~'
	endif
	if getbufvar(a:bufnum, '&modifiable')
		if getbufvar(a:bufnum, '&modified')
			let f .= '+'
		endif
	else
		let f .= '-'
	endif
	return f
endfunction
call lining#left(s:flags_item)

" Paste status
let s:paste_item = {}
function s:paste_item.format(item, active, bufnum)
	if a:active && getbufvar(a:bufnum, '&paste')
		return 'PASTE'
	else
		return ''
	endif
endfunction
call lining#left(s:paste_item, 'Warn')

" Line/Column
call lining#right('%4l:%-3c', 'LnCol')

" Git branch/hunk information
if exists('*GitGutterGetHunkSummary')
	function s:git_get_hunks()
		let [hadd, hmod, hdel] = GitGutterGetHunkSummary()
		let hunks = ''
		if hmod > 0
			let hunks = printf(' ~%i', hmod)
		endif
		if hadd > 0
			let hunks = printf('%s +%i', hunks, hadd)
		endif
		if hdel > 0
			let hunks = printf('%s -%i', hunks, hdel)
		endif
		return hunks
	endfunction
else
	function s:git_get_hunks()
		return ''
	endfunction
endif

if exists('*fugitive#detect') && exists('*fugitive#detect')
	let s:git_item = {}
	function s:git_item.format(item, active, bufnum)
		let head = fugitive#head()
		if empty(head) && !exists('b:git_dir')
			call fugitive#detect(fnamemodify(bufname(a:bufnum), ':p:h'))
			let head = fugitive#head()
		endif
		if empty(head)
			return ''
		endif
		return a:active ? (head . s:git_get_hunks()) : head
	endfunction
	call lining#right(s:git_item, 'VcsInfo')
endif

" File type
call lining#right("%{empty(&filetype) ? 'none' : &filetype}")


function lining#status(winnum)
	let active = a:winnum == winnr()
	let bufnum = winbufnr(a:winnum)

	let fmt  = ''
	let type = getbufvar(bufnum, '&buftype')
	let name = bufname(bufnum)

	if type ==# 'help'
		let fmt .= s:colorize(active, 'LiningBufPath', ' help/')
		let fmt .= s:colorize(active, 'LiningBufName', fnamemodify(name, ':t:r') . ' ')
		let fmt .= '%='  " Move to the right side
		let fmt .= s:colorize(active, 'LiningLnCol', ' %P ')
		return fmt
	endif

	let i = 0
	let n = len(s:left_items)
	let last_color = -1
	let start_color = 1

	while i < n
		let item = s:left_items[i]
		let text = s:format(item, active, bufnum)
		if !empty(text)
			let hlgroup = 'Lining' . get(item, 'color', 'Item')
			let item_color = synIDtrans(hlID(hlgroup))
			if item_color == last_color
				if start_color != 0
					let fmt .= s:colorize(active, hlgroup, '·')
				endif
				let start_color = 0
			else
				let last_color = item_color
				let start_color = 1
			endif
			let fmt .= text
		endif
		let i = i + 1
	endwhile

	let fmt .= '%='  " Switch to the right side

	let i = len(s:right_items)
	let last_color = -1
	let start_color = 1

	while i > 0
		let i = i - 1
		let item = s:right_items[i]
		let text = s:format(item, active, bufnum)
		if !empty(text)
			let hlgroup = 'Lining' . get(item, 'color', 'Item')
			let item_color = synIDtrans(hlID(hlgroup))
			if item_color == last_color
				if start_color != 0
					let fmt .= s:colorize(active, hlgroup, '·')
				endif
				let start_color = 0
			else
				let last_color = item_color
				let start_color = 1
			endif
			let fmt .= text
		endif
	endwhile

	return fmt
endfunction


function lining#refresh()
	if pumvisible()
		return
	endif
	for nr in range(1, winnr('$'))
		call setwinvar(nr, '&statusline', '%!lining#status(' . nr . ')')
	endfor
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
