" unittest.vim's test suite
"
" Test case of context accessors
"
"-----------------------------------------------------------------------------
" Expected results:
"
"   Green
"
"   WARNING:
"   Exporting s: in Vim 7.2 causes deadly signal SEGV. You had better use Vim
"   7.3 or later when you run the tests that access any script-local
"   variables.
"
"-----------------------------------------------------------------------------

let s:tc = unittest#testcase#new("Context Accessors", unittest#assertions#context())

let g:unittest_test_flag = 1
let s:current = {
      \ 'g:unittest_test_flag': g:unittest_test_flag,
      \ '&ignorecase': &ignorecase,
      \ '&g:ignorecase': &g:ignorecase,
      \ '&l:ignorecase': &l:ignorecase,
      \ }

function! s:tc.test_context_call_global_function()
  call self.assert(self.call('unittest#is_running', []))
endfunction

function! s:tc.test_context_call_script_local_function()
  call self.call('s:Assertions_assert_true', [1])
endfunction

function! s:tc.test_context_get_global_variable()
  call self.assert_equal(g:unittest_test_flag, self.get('g:unittest_test_flag'))
endfunction

function! s:tc.test_context_get_script_local_variable()
  call self.assert_equal(type(0), self.get('s:TYPE_NUM'))
endfunction

function! s:tc.test_context_get_option()
  call self.assert_equal(&ignorecase, self.get('&ignorecase'))
endfunction

function! s:tc.test_context_get_global_option()
  call self.assert_equal(&g:ignorecase, self.get('&g:ignorecase'))
endfunction

function! s:tc.test_context_get_local_option()
  call self.assert_equal(&l:shiftwidth, self.get('&l:shiftwidth'))
endfunction

function! s:tc.test_context_set_global_variable()
  call self.set('g:unittest_test_flag', !s:current['g:unittest_test_flag'])
  call self.assert_equal(!s:current['g:unittest_test_flag'], g:unittest_test_flag)
endfunction
function! s:tc.test_context_set_global_variable_revert()
  call self.assert_equal(s:current['g:unittest_test_flag'], g:unittest_test_flag)
endfunction

function! s:tc.test_context_define_global_variable()
  call self.set('g:unittest_foo', 10)
  call self.assert_equal(10, self.get('g:unittest_foo'))
endfunction
function! s:tc.test_context_define_global_variable_revert()
  call self.assert_not(self.exists('g:unittest_foo'))
endfunction

function! s:tc.test_context_set_script_local_variable()
  call self.set('s:TYPE_NUM', 10)
  call self.assert_equal(10, self.get('s:TYPE_NUM'))
endfunction
function! s:tc.test_context_set_script_local_variable_revert()
  call self.assert_equal(type(0), self.get('s:TYPE_NUM'))
endfunction

function! s:tc.test_context_define_script_local_variable()
  call self.set('s:foo', 10)
  call self.assert_equal(10, self.get('s:foo'))
endfunction
function! s:tc.test_context_define_script_local_variable_revert()
  call self.assert_not(self.exists('s:foo'))
endfunction

function! s:tc.test_context_set_option()
  call self.set('&ignorecase', !s:current['&ignorecase'])
  call self.assert_equal(!s:current['&ignorecase'], &ignorecase)
endfunction
function! s:tc.test_context_set_option_revert()
  call self.assert_equal(s:current['&ignorecase'], &ignorecase)
endfunction

function! s:tc.test_context_set_global_option()
  call self.set('&g:ignorecase', !s:current['&g:ignorecase'])
  call self.assert_equal(!s:current['&g:ignorecase'], &g:ignorecase)
endfunction
function! s:tc.test_context_set_global_option_revert()
  call self.assert_equal(s:current['&g:ignorecase'], &g:ignorecase)
endfunction

function! s:tc.test_context_set_local_option()
  call self.set('&l:ignorecase', !s:current['&l:ignorecase'])
  call self.assert_equal(!s:current['&l:ignorecase'], &l:ignorecase)
endfunction
function! s:tc.test_context_set_local_option_revert()
  call self.assert_equal(s:current['&l:ignorecase'], &l:ignorecase)
endfunction

unlet s:tc

" vim: filetype=vim
