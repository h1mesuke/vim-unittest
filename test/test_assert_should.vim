" unittest.vim's test suite
"
" This is a testcase of assertions.
"
" Expected results are: 
" N tests, 2 * N assertions, N failures, 1 errors

let tc = unittest#testcase(expand('<sfile>:p'))

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

function! tc.should_foo_bar_baz()
  " Expected:
  "
  " setup
  " setup_foo
  " setup_foo_bar
  " setup_foo_bar_baz
  "
  " should_foo_bar_baz
  "
  " teardown_foo_bar_baz
  " teardown_foo_bar
  " teardown_foo
  " teardown
endfunction

function! tc.should_be_true()
  call assert#true(1)
  call assert#true(0)
endfunction

function! tc.should_be_false()
  call assert#false(0)
  call assert#false(1)
endfunction

function! tc.should_exist()
  call assert#exists('*tr')
  call assert#exists('*foo#bar#baz')
endfunction

function! tc.should_not_exist()
  call assert#not_exists('*foo#bar#baz')
  call assert#not_exists('*tr')
endfunction

function! tc.should_be_Number()
  call assert#is_Number(1)
  call assert#is_Number("a")
endfunction

function! tc.should_be_String()
  call assert#is_String("a")
  call assert#is_String(1)
endfunction

function! tc.should_be_Funcref()
  call assert#is_Funcref(function("type"))
  call assert#is_Funcref(1)
endfunction

function! tc.should_be_List()
  call assert#is_List([1,2,3])
  call assert#is_List(1)
endfunction

function! tc.should_be_Dictionary()
  call assert#is_Dictionary({ 1:'a', 2:'b' })
  call assert#is_Dictionary(1)
endfunction

function! tc.should_be_Float()
  call assert#is_Float(3.14)
  call assert#is_Float(1)
endfunction

function! tc.should_be_equal()
  call assert#equal(1, 1)
  call assert#equal(1, 2)
endfunction

function! tc.should_be_equal_c()
  call assert#equal_c("a", "A")
  call assert#equal_c("a", "b")
endfunction

function! tc.should_be_equal_C()
  call assert#equal_C("a", "a")
  call assert#equal_C("a", "b")
endfunction

function! tc.should_not_be_equal()
  call assert#not_equal(1, 2)
  call assert#not_equal(1, 1)
endfunction

function! tc.should_not_be_equal_c()
  call assert#not_equal_c("a", "b")
  call assert#not_equal_c("a", "A")
endfunction

function! tc.should_not_be_equal_C()
  call assert#not_equal_C("a", "b")
  call assert#not_equal_C("a", "a")
endfunction

function! tc.should_be_same()
  let a = []
  let b = []
  call assert#same(a, a)
  call assert#same(a, b)
endfunction

function! tc.should_not_be_same()
  let a = []
  let b = []
  call assert#not_same(a, b)
  call assert#not_same(a, a)
endfunction

function! tc.should_match()
  call assert#match("hello", 'e')
  call assert#match("hello", 'x')

  call assert#match(["hello", "goodbye"], 'e')
  call assert#match(["hello", "goodbye"], 'x')
endfunction

function! tc.should_not_match()
  call assert#not_match("hello", 'x')
  call assert#not_match("hello", 'e')

  call assert#not_match(["hello", "goodbye"], 'x')
  call assert#not_match(["hello", "goodbye"], 'e')
endfunction

function! tc.should_raise()
  call assert#raise('FooBarBaz', 'E492')
  call assert#raise('nohl', 'E492')
endfunction

function! tc.should_not_be_raised()
  call assert#nothing_raised('nohl')
  call assert#nothing_raised('FooBarBaz')
endfunction

function! tc.should_error()
  call foo#bar#baz()
endfunction

unlet tc

" vim: filetype=vim
