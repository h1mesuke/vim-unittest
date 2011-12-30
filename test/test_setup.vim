" unittest.vim's test suite
"
" Test case of setup and teardown
"
"-----------------------------------------------------------------------------
" Expected results:
"
"   Setup
"
"   setup
"   setup_foo
"   test_foo
"   teardown_foo
"   teardown
"
"   setup
"   setup_foo
"   setup_foo_bar
"   test_foo_bar
"   teardown_foo_bar
"   teardown_foo
"   teardown
"
"   setup
"   setup_foo
"   setup_foo_bar
"   setup_foo_bar_baz
"   test_foo_bar_baz
"   teardown_foo_bar_baz
"   teardown_foo_bar
"   teardown_foo
"   teardown
"
"   Teardown

let s:tc = unittest#testcase#new("Setup and Teardown")

function! s:tc.Setup()
  let self.hook_calls = ["Setup"]
  call self.puts("Setup")
endfunction

function! s:tc.setup()
  call self.puts()
  call add(self.hook_calls, "setup")
  call self.puts("setup")
endfunction

function! s:tc.setup_foo()
  call add(self.hook_calls, "setup_foo")
  call self.puts("setup_foo")
endfunction

function! s:tc.teardown_foo()
  call add(self.hook_calls, "teardown_foo")
  call self.puts("teardown_foo")
endfunction

function! s:tc.test_foo()
  call add(self.hook_calls, "test_foo")
  call self.puts("test_foo")
endfunction

function! s:tc.setup_foo_bar()
  call add(self.hook_calls, "setup_foo_bar")
  call self.puts("setup_foo_bar")
endfunction

function! s:tc.teardown_foo_bar()
  call add(self.hook_calls, "teardown_foo_bar")
  call self.puts("teardown_foo_bar")
endfunction

function! s:tc.test_foo_bar()
  call add(self.hook_calls, "test_foo_bar")
  call self.puts("test_foo_bar")
endfunction

function! s:tc.setup_foo_bar_baz()
  call add(self.hook_calls, "setup_foo_bar_baz")
  call self.puts("setup_foo_bar_baz")
endfunction

function! s:tc.test_foo_bar_baz()
  call add(self.hook_calls, "test_foo_bar_baz")
  call self.puts("test_foo_bar_baz")
endfunction

function! s:tc.teardown_foo_bar_baz()
  call add(self.hook_calls, "teardown_foo_bar_baz")
  call self.puts("teardown_foo_bar_baz")
endfunction

function! s:tc.teardown()
  call add(self.hook_calls, "teardown")
  call self.puts("teardown")
  call self.puts()
endfunction

function! s:tc.Teardown()
  call self.puts()
  call add(self.hook_calls, "Teardown")
  call self.puts("Teardown")
endfunction

" NOTE: This test must be executed at the last in alphabetical order, so
" "zetup" of the name isn't a typo. Unfortunately, this can't test Teardown(),
" so we need to see the output of the test results finding "Teardown" printed
" by puts().
"
function! s:tc.test_zetup_and_teardown()
  let expected = [
        \ "Setup",
        \
        \ "setup",
        \ "setup_foo",
        \ "test_foo",
        \ "teardown_foo",
        \ "teardown",
        \
        \ "setup",
        \ "setup_foo",
        \ "setup_foo_bar",
        \ "test_foo_bar",
        \ "teardown_foo_bar",
        \ "teardown_foo",
        \ "teardown",
        \
        \ "setup",
        \ "setup_foo",
        \ "setup_foo_bar",
        \ "setup_foo_bar_baz",
        \ "test_foo_bar_baz",
        \ "teardown_foo_bar_baz",
        \ "teardown_foo_bar",
        \ "teardown_foo",
        \ "teardown",
        \
        \ "setup",
        \ ]
  " NOTE: The last "setup" is called for this test.
  call self.assert_equal(expected, self.hook_calls)
endfunction

unlet s:tc

" vim: filetype=vim
