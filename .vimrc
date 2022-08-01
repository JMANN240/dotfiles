set background=dark
syntax on
set hlsearch
set incsearch
set ignorecase
set number

hi TabLine NONE
hi TabLineSel term=reverse cterm=reverse gui=reverse
hi TabLineFill NONE

execute "set <M-r>=\er"
map <M-r> :source ~/.vimrc<CR>

vmap <C-c> y
vmap <C-x> x
imap <C-v> <esc>Pi

for i in range(1,12) | execute 'map <F'.i.'> '.i.'gt' | endfor

set tabline=%!MyTabLine()

function MyTabLine()
	let s = ''
	for i in range(tabpagenr('$'))
		if i + 1 == tabpagenr()
			let s .= '%#TabLineSel#['
		else
			let s .= '%#TabLine#'
		endif

		let s .= '%'.(i+1).'T'

		let s .= ' %{MyTabLabel('.(i+1).')} '

		if i + 1 == tabpagenr()
			let s .= ']'
		endif
	endfor

	let s .= '%#TabLineFill#%T'

	return s
endfunction

function MyTabLabel(n)
	let buflist = tabpagebuflist(a:n)
	let winnr = tabpagewinnr(a:n)
	return bufname(buflist[winnr-1])
endfunction
