" unittest.vim's test suite

" TestCase of shoulda style tests
"
" Expected results:
" Green
"
" thoughtbot/shoulda - GitHub
" https://github.com/thoughtbot/shoulda

let tc = unittest#testcase#new('test_should')

function! tc.one_should_be_true()
  call self.assert_true(1)
endfunction

function! tc.zero_should_be_false()
  call self.assert_false(0)
endfunction

unlet tc

" vim: filetype=vim