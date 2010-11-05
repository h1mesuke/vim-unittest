" unittest.vim's test suite

let tc = unittest#testcase(expand('<sfile>:p'))

function! tc.test_all_green()
  call assert#true(1)
endfunction

unlet tc

" vim: filetype=vim
