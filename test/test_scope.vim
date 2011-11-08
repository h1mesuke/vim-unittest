" unittest.vim's test suite

" TestCase of script-local scope
"
" Expected results:
" Green
"
" WARNING: Using the context scope feature in Vim 7.2 sometimes causes deadly
" signal SEGV. You had better use Vim 7.3 or later when you test something in
" script-local namespace.

let context = unittest#assertions#context()
let tc = unittest#testcase#new('test_scope', context)

function! tc.test_tc_call()
  call self.call('Assertions_assert_true', [1])
endfunction

function! tc.test_tc_get()
  call self.assert_match('^<SNR>\d\+_', self.get('SID'))
endfunction

function! tc.test_tc_set()
  call self.set('foo', 10)
  call self.assert_equal(10, self.get('foo'))
endfunction

unlet tc

" vim: filetype=vim
