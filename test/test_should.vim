" unittest.vim's test suite

" Testcase sample of shoulda style
"
" thoughtbot/shoulda - GitHub
" https://github.com/thoughtbot/shoulda

let tc = unittest#testcase#new('test_should')

function! tc.one_should_be_true()
  call assert#true(1)
endfunction

function! tc.zero_should_be_false()
  call assert#false(0)
endfunction

unlet tc

" vim: filetype=vim
