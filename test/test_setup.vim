" unittest.vim's test suite
"
" Test case of setup and teardown
"
"-----------------------------------------------------------------------------
" Expected results:
"
"   SETUP
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
"   TEARDOWN
"
"-----------------------------------------------------------------------------

let s:tc = unittest#testcase#new("Setup and Teardown")

function! s:tc.SETUP()
  let self.funcalls = ["SETUP"]
  call self.puts("SETUP")
endfunction

function! s:tc.setup()
  call self.puts()
  call add(self.funcalls, "setup")
  call self.puts("setup")
endfunction

function! s:tc.setup_foo()
  call add(self.funcalls, "setup_foo")
  call self.puts("setup_foo")
endfunction

function! s:tc.teardown_foo()
  call add(self.funcalls, "teardown_foo")
  call self.puts("teardown_foo")
endfunction

function! s:tc.test_foo()
  call add(self.funcalls, "test_foo")
  call self.puts("test_foo")
  call self.assert(1) | " Not pending.
endfunction

function! s:tc.setup_foo_bar()
  call add(self.funcalls, "setup_foo_bar")
  call self.puts("setup_foo_bar")
endfunction

function! s:tc.teardown_foo_bar()
  call add(self.funcalls, "teardown_foo_bar")
  call self.puts("teardown_foo_bar")
endfunction

function! s:tc.test_foo_bar()
  call add(self.funcalls, "test_foo_bar")
  call self.puts("test_foo_bar")
  call self.assert(1) | " Not pending.
endfunction

function! s:tc.setup_foo_bar_baz()
  call add(self.funcalls, "setup_foo_bar_baz")
  call self.puts("setup_foo_bar_baz")
endfunction

function! s:tc.test_foo_bar_baz()
  call add(self.funcalls, "test_foo_bar_baz")
  call self.puts("test_foo_bar_baz")
  call self.assert(1) | " Not pending.
endfunction

function! s:tc.teardown_foo_bar_baz()
  call add(self.funcalls, "teardown_foo_bar_baz")
  call self.puts("teardown_foo_bar_baz")
endfunction

function! s:tc.teardown()
  call add(self.funcalls, "teardown")
  call self.puts("teardown")
  call self.puts()
endfunction

function! s:tc.TEARDOWN()
  call self.puts()
  call add(self.funcalls, "TEARDOWN")
  call self.puts("TEARDOWN")
endfunction

" NOTE: This test must be executed last in alphabetical order, so "zetup" of
" the name isn't a typo. Unfortunately, this can't test TEARDOWN(), so we need
" to see the output of the test results finding "TEARDOWN" printed by puts().
"
function! s:tc.test_zetup_and_teardown()
  let expected = [
        \ "SETUP",
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
  call self.assert_equal(expected, self.funcalls)
endfunction

unlet s:tc
