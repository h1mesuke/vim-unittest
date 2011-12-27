" unittest.vim's test suite
"
" TestCase of script-local accessors
"
" Expected results:
"   Green
"
" WARNING: Using Context's get/set methods in Vim 7.2 causes deadly signal
" SEGV. You had better use Vim 7.3 or later when you run the tests that need
" to access any of script-local variables.

let context = unittest#assertions#context()
let s:tc = unittest#testcase#new("Context", context)

function! s:tc.test_context_call()
  call self.context.call('s:Assertions_assert_true', [1])
endfunction
function! s:tc.test_context_call_without_prefix()
  call self.context.call('Assertions_assert_true', [1])
endfunction

function! s:tc.test_context_get()
  call self.assert_match('^<SNR>\d\+_', self.context.get('s:SID'))
endfunction
function! s:tc.test_context_get_without_prefix()
  call self.assert_match('^<SNR>\d\+_', self.context.get('SID'))
endfunction

function! s:tc.test_context_set()
  call self.context.set('s:foo', 10)
  call self.assert_equal(10, self.context.get('s:foo'))
endfunction
function! s:tc.test_context_set_without_prefix()
  call self.context.set('bar', 10)
  call self.assert_equal(10, self.context.get('bar'))
endfunction

unlet s:tc

" vim: filetype=vim
