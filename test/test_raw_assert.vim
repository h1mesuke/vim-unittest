" unittest.vim's test suite

" Test of assertions used outside testcases.
"
" Expected results:
" AssertionFailedError will be thrown.

function! s:test_assert()
  call assert#true(0)
endfunction
call s:test_assert()

" vim: filetype=vim
