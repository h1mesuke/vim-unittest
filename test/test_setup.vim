" unittest.vim's test suite
"
" TestCase of TestCase#setup()
"
" Expected results:
"
"   setup
"   setup_foo
"   setup_foo_bar
"   setup_foo_bar_baz
"   teardown_foo_bar_baz
"   teardown_foo_bar
"   teardown_foo
"   teardown

let s:tc = unittest#testcase#new("Setup and Teardown")

function! s:tc.setup()
  call self.puts("setup")
endfunction

function! s:tc.setup_foo_bar_baz()
  call self.puts("setup_foo_bar_baz")
endfunction

function! s:tc.setup_foo()
  call self.puts("setup_foo")
endfunction

function! s:tc.setup_foo_bar()
  call self.puts("setup_foo_bar")
endfunction

function! s:tc.teardown()
  call self.puts("teardown")
  call self.puts()
endfunction

function! s:tc.teardown_foo_bar_baz()
  call self.puts("teardown_foo_bar_baz")
endfunction

function! s:tc.teardown_foo()
  call self.puts("teardown_foo")
endfunction

function! s:tc.teardown_foo_bar()
  call self.puts("teardown_foo_bar")
endfunction

function! s:tc.test_foo_bar_baz()
endfunction

unlet s:tc

" vim: filetype=vim
