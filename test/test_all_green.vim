" unittest.vim's test suite

let tc = unittest#testcase#new('test_all_green')

function! tc.test_foo()
  call assert#true(1)
endfunction

function! tc.test_bar()
  call assert#true(1)
endfunction

function! tc.test_baz()
  call assert#true(1)
endfunction

unlet tc

" vim: filetype=vim
