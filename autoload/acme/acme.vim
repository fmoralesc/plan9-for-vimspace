" vim: set fdm=marker :
"
" acme/acme.vim
"
" acme emulation for vim

" Init(): configure and initialize acme functionality {{{1
function! acme#acme#Init()
    if !exists("g:plan9#acme#map_mouse")
	let g:plan9#acme#map_mouse = 1
    endif
    if !exists("g:plan9#acme#move_mouse")
	let g:plan9#acme#move_mouse = 0
    endif
    if !exists("g:plan9#acme#map_keyboard")
	let g:plan9#acme#map_keyboard = 0
    endif

    if g:plan9#acme#map_mouse > 0
	nnoremap <silent> <MiddleMouse> <LeftMouse>:call acme#acme#MiddleMouse(expand('<cWORD>'))<cr>
	vnoremap <silent> <MiddleMouse> :call acme#acme#MiddleMouse(getreg("*"))<cr>
	nnoremap <silent> <RightMouse> <LeftMouse>:set opfunc=acme#acme#RightMouse<cr>g@
	vnoremap <silent> <RightMouse> :<C-U>call acme#acme#RightMouse(visualmode())<cr>
    endif

    if g:plan9#acme#map_keyboard > 0
	nnoremap <silent> <leader>mm :call acme#acme#MiddleMouse(expand('<cWORD>'))<cr>
	vnoremap <silent> <leader>mm :call acme#acme#MiddleMouse(getreg("*"))<cr>
	nnoremap <silent> <leader>mr :set opfunc=acme#acme#RightMouse<cr>g@
	vnoremap <silent> <leader>mr :<C-U>call acme#acme#RightMouse(visualmode())<cr>
    endif
endfunction

" RightMouse(text): emulate the right mouse operation in acme {{{1
" acme's manual calls this button 'mouse button 2'
function! acme#acme#RightMouse(type)
    let sel_save = &selection
    let &selection = "inclusive"
    let reg_save = @@
    if a:type =~? "v"
	execute "normal! `<".a:type."`>x"
    else
	execute "normal! BvEx"
    endif
    let l:text = @@
    if executable(split(l:text)[0])
	normal P
	let cmd_output = system(l:text)
	botright vnew
	"exec "0read !". substitute(a:prog, "!", "\\\\!", "g")
	exe "normal i\<C-r>=cmd_output\<cr>"
	setlocal nosmarttab
	try
	    exe "%s/\t//g"
	catch
	endtry
	setlocal buftype=nofile
    else
	if l:text[0] == "<"
	    " replace selection with output
	    let cmd_output = system(l:text[1:])
	    exe "normal i\<C-r>=cmd_output\<cr>"
	elseif l:text[0] == ">"
	    " open the output in a new buffer
	    let cmd_output = system(l:text[1:], getreg("*"))
	    botright vnew
	    exe "normal i\<C-r>=cmd_output\<cr>"
	    try
		exe "%s/\t//g"
	    catch
	    endtry
	    setlocal buftype=nofile
	elseif l:text[0] == "|"
	    " replace selection with output
	    let cmd_output = system(l:text[1:], getreg("*"))
	    exe "normal i\<C-r>=cmd_output\<cr>"
	endif
    endif
    let @@ = reg_save
    let &selection = sel_save
endfunction

" MiddleMouse(text): emulate the middle mouse operation in acme {{{1
" acme's manual calls this button 'mouse button 3'
function! acme#acme#MiddleMouse(text) 
    let text_data = split(a:text, ":")[:1]
    if len(text_data) > 1
	if filereadable(text_data[0]) || text_data[0] == ''
            call plan9#address#Do(a:text)
	    return
	endif
    endif
    exe "silent normal *"
endfunction