" Testcase sample of shoulda style

let tc = unittest#testcase#new('test_sample_shoulda')

function! tc.one_should_be_true()
  call assert#true(1)
endfunction

function! tc.zero_should_be_false()
  call assert#false(0)
endfunction

unlet tc

" vim: filetype=vim
