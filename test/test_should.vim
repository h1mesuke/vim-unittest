" unittest.vim's test suite
"
" Test case of shoulda style tests
"
"-----------------------------------------------------------------------------
" Expected results:
"
"   Green
"
" See also:
"   thoughtbot/shoulda - GitHub
"   https://github.com/thoughtbot/shoulda
"
"-----------------------------------------------------------------------------

let s:tc = unittest#testcase#new("Shoulda-style Test Names")

function! s:tc.one_should_be_true()
  call self.assert_true(1)
endfunction

function! s:tc.zero_should_be_false()
  call self.assert_false(0)
endfunction

unlet s:tc
