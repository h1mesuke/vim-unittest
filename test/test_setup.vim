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

let tc = unittest#testcase#new('test_setup')

function! tc.setup()
  call self.puts()
  call self.puts("setup")
endfunction

function! tc.setup_foo_bar_baz()
  call self.puts("setup_foo_bar_baz")
endfunction

function! tc.setup_foo()
  call self.puts("setup_foo")
endfunction

function! tc.setup_foo_bar()
  call self.puts("setup_foo_bar")
endfunction

function! tc.teardown()
  call self.puts("teardown")
endfunction

function! tc.teardown_foo_bar_baz()
  call self.puts("teardown_foo_bar_baz")
endfunction

function! tc.teardown_foo()
  call self.puts("teardown_foo")
endfunction

function! tc.teardown_foo_bar()
  call self.puts("teardown_foo_bar")
endfunction

function! tc.test_foo_bar_baz()
endfunction

unlet tc

" vim: filetype=vim
