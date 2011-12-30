" unittest.vim's test suite
"
" Test case of context accessors
"
"-----------------------------------------------------------------------------
" Expected results:
"   Green
"
" WARNING: Using Context's get/set methods in Vim 7.2 causes deadly signal
" SEGV. You had better use Vim 7.3 or later when you run the tests that need
" to access any of script-local variables.
"
"-----------------------------------------------------------------------------

let s:tc = unittest#testcase#new("Context", unittest#assertions#context())

let s:current = {
      \ 'g:unittest_smooth_redraw_results': g:unittest_smooth_redraw_results,
      \ '&ignorecase': &ignorecase,
      \ '&g:ignorecase': &g:ignorecase,
      \ '&l:ignorecase': &l:ignorecase,
      \ }

function! s:tc.test_context_call_global_function()
  call self.assert(self.context.call('unittest#is_running', []))
endfunction

function! s:tc.test_context_call_script_local_function()
  call self.context.call('s:Assertions_assert_true', [1])
endfunction

function! s:tc.test_context_get_global_variable()
  call self.assert_equal(g:unittest_smooth_redraw_results,
        \ self.context.get('g:unittest_smooth_redraw_results'))
endfunction

function! s:tc.test_context_get_script_local_variable()
  call self.assert_equal(type(0), self.context.get('s:TYPE_NUM'))
endfunction

function! s:tc.test_context_get_option()
  call self.assert_equal(&ignorecase, self.context.get('&ignorecase'))
endfunction

function! s:tc.test_context_get_global_option()
  call self.assert_equal(&g:ignorecase, self.context.get('&g:ignorecase'))
endfunction

function! s:tc.test_context_get_local_option()
  call self.assert_equal(&l:shiftwidth, self.context.get('&l:shiftwidth'))
endfunction

function! s:tc.test_context_set_global_variable()
  call self.context.set('g:unittest_smooth_redraw_results',
        \ !s:current['g:unittest_smooth_redraw_results'])
  call self.assert_equal(!s:current['g:unittest_smooth_redraw_results'],
        \ self.context.get('g:unittest_smooth_redraw_results'))
endfunction
function! s:tc.test_context_set_global_variable_revert()
  call self.assert_equal(s:current['g:unittest_smooth_redraw_results'],
        \ self.context.get('g:unittest_smooth_redraw_results'))
endfunction

function! s:tc.test_context_define_global_variable()
  call self.context.set('g:unittest_foo', 10)
  call self.assert_equal(10, self.context.get('g:unittest_foo'))
endfunction
function! s:tc.test_context_define_global_variable_revert()
  call self.assert_not(self.context.exists('g:unittest_foo'))
endfunction

function! s:tc.test_context_set_script_local_variable()
  call self.context.set('s:TYPE_NUM', 10)
  call self.assert_equal(10, self.context.get('s:TYPE_NUM'))
endfunction
function! s:tc.test_context_set_script_local_variable_revert()
  call self.assert_equal(type(0), self.context.get('s:TYPE_NUM'))
endfunction

function! s:tc.test_context_define_script_local_variable()
  call self.context.set('s:foo', 10)
  call self.assert_equal(10, self.context.get('s:foo'))
endfunction
function! s:tc.test_context_define_script_local_variable_revert()
  call self.assert_not(self.context.exists('s:foo'))
endfunction

function! s:tc.test_context_set_option()
  call self.context.set('&ignorecase', !s:current['&ignorecase'])
  call self.assert_equal(!s:current['&ignorecase'], &ignorecase)
endfunction
function! s:tc.test_context_set_option_revert()
  call self.assert_equal(s:current['&ignorecase'], &ignorecase)
endfunction

function! s:tc.test_context_set_global_option()
  call self.context.set('&g:ignorecase', !s:current['&g:ignorecase'])
  call self.assert_equal(!s:current['&g:ignorecase'], &g:ignorecase)
endfunction
function! s:tc.test_context_set_global_option_revert()
  call self.assert_equal(s:current['&g:ignorecase'], &g:ignorecase)
endfunction

function! s:tc.test_context_set_local_option()
  call self.context.set('&l:ignorecase', !s:current['&l:ignorecase'])
  call self.assert_equal(!s:current['&l:ignorecase'], &l:ignorecase)
endfunction
function! s:tc.test_context_set_local_option_revert()
  call self.assert_equal(s:current['&l:ignorecase'], &l:ignorecase)
endfunction

unlet s:tc

" vim: filetype=vim
