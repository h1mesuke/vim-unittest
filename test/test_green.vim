" unittest.vim's test suite

" Testcase of the green state
"
" Expected results:
" Green

let tc = unittest#testcase#new('test_green')

function! tc.test_foo()
  call self.assert_true(1)
endfunction

function! tc.test_bar()
  call self.assert_true(1)
endfunction

function! tc.test_baz()
  call self.assert_true(1)
endfunction

unlet tc

" vim: filetype=vim
