" unittest.vim's test suite

" Testcase of assertions
"
" Expected results are:
" T tests, A assertions, A/2 failures, 1 errors

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

let s:Foo = oop#class#new('Foo', s:SID)
let s:Bar = oop#class#new('Bar', s:SID, s:Foo)

let s:Fizz = oop#module#new('Fizz', s:SID)

"-----------------------------------------------------------------------------

let tc = unittest#testcase#new('test_assert')

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
  " Expected:
  "
  " setup
  " setup_foo
  " setup_foo_bar
  " setup_foo_bar_baz
  "
  " test_foo_bar_baz
  "
  " teardown_foo_bar_baz
  " teardown_foo_bar
  " teardown_foo
  " teardown
endfunction

function! tc.test_assert_true()
  call self.assert_true(1)
  call self.assert_true(0)
endfunction

function! tc.test_assert_false()
  call self.assert_false(0)
  call self.assert_false(1)
endfunction

function! tc.test_assert()
  call self.assert(1)
  call self.assert(0)
endfunction

function! tc.test_assert_not()
  call self.assert_not(0)
  call self.assert_not(1)
endfunction

function! tc.test_assert_equal()
  call self.assert_equal(1, 1)
  call self.assert_equal(1, 2)
endfunction

function! tc.test_assert_not_equal()
  call self.assert_not_equal(1, 2)
  call self.assert_not_equal(1, 1)
endfunction

function! tc.test_assert_equal_c()
  call self.assert_equal_c("a", "A")
  call self.assert_equal_c("a", "b")
endfunction

function! tc.test_assert_not_equal_c()
  call self.assert_not_equal_c("a", "b")
  call self.assert_not_equal_c("a", "A")
endfunction

function! tc.test_assert_equal_C()
  call self.assert_equal_C("a", "a")
  call self.assert_equal_C("a", "b")
endfunction

function! tc.test_assert_not_equal_C()
  call self.assert_not_equal_C("a", "b")
  call self.assert_not_equal_C("a", "a")
endfunction

function! tc.test_assert_exists()
  call self.assert_exists('*tr')
  call self.assert_exists('*foo#bar#baz')

  call self.assert_exists(':bnext')
  call self.assert_exists(':bn')
endfunction

function! tc.test_assert_not_exists()
  call self.assert_not_exists('*foo#bar#baz')
  call self.assert_not_exists('*tr')

  call self.assert_not_exists(':bn')
  call self.assert_not_exists(':bnext')
endfunction

function! tc.test_assert_is()
  let a = []
  let b = []
  call self.assert_is(a, a)
  call self.assert_is(a, b)
endfunction

function! tc.test_assert_is_not()
  let a = []
  let b = []
  call self.assert_is_not(a, b)
  call self.assert_is_not(a, a)
endfunction

function! tc.test_assert_is_Number()
  call self.assert_is_Number(1)
  call self.assert_is_Number("a")
endfunction

function! tc.test_assert_is_String()
  call self.assert_is_String("a")
  call self.assert_is_String(1)
endfunction

function! tc.test_assert_is_Funcref()
  call self.assert_is_Funcref(function("type"))
  call self.assert_is_Funcref(1)
endfunction

function! tc.test_assert_is_List()
  call self.assert_is_List([1,2,3])
  call self.assert_is_List(1)
endfunction

function! tc.test_assert_is_Dictionary()
  call self.assert_is_Dictionary({ 1:'a', 2:'b' })
  call self.assert_is_Dictionary(1)
endfunction

function! tc.test_assert_is_Float()
  call self.assert_is_Float(3.14)
  call self.assert_is_Float(1)
endfunction

function! tc.test_assert_match()
  call self.assert_match('e', "hello")
  call self.assert_match('x', "hello")

  call self.assert_match('e', ["hello", "goodbye"])
  call self.assert_match('x', ["hello", "goodbye"])
endfunction

function! tc.test_assert_not_match()
  call self.assert_not_match('x', "hello")
  call self.assert_not_match('e', "hello")

  call self.assert_not_match('x', ["hello", "goodbye"])
  call self.assert_not_match('e', ["hello", "goodbye"])
endfunction

function! tc.test_assert_throw()
  call self.assert_throw('E492', 'FooBarBaz')
  call self.assert_throw('E492', 'nohl')
endfunction

function! tc.test_assert_not_throw()
  call self.assert_not_throw('nohl')
  call self.assert_not_throw('FooBarBaz')
endfunction

function! tc.test_assert_nothing_thrown()
  call self.assert_nothing_thrown('nohl')
  call self.assert_nothing_thrown('FooBarBaz')
endfunction

function! tc.test_error()
  call foo#bar#baz()
endfunction

"-----------------------------------------------------------------------------
" vim-oop

" h1mesuke/vim-oop - GitHub
" https://github.com/h1mesuke/vim-oop

function! tc.setup()
  let self.foo = s:Foo.new()
  let self.bar = s:Bar.new()

  call self.puts()
  call self.puts("setup")
endfunction

function! tc.test_assert_is_Object()
  call self.assert_is_Object(s:Foo)
  call self.assert_is_Object({})
endfunction

function! tc.test_assert_is_Class()
  call self.assert_is_Class(s:Foo)
  call self.assert_is_Class(self.foo)
endfunction

function! tc.test_assert_is_Instance()
  call self.assert_is_Class(self.foo)
  call self.assert_is_Class(s:Foo)
endfunction

function! tc.test_assert_is_Module()
  call self.assert_is_Module(s:Fizz)
  call self.assert_is_Module({})
endfunction

function! tc.test_assert_is_kind_of()
  call self.assert_is_kind_of(s:Foo, self.bar)
  call self.assert_is_kind_of(s:Bar, self.foo)
endfunction

function! tc.test_assert_is_instance_of()
  call self.assert_is_instance_of(s:Foo, self.foo)
  call self.assert_is_instance_of(s:Bar, self.foo)
endfunction

unlet tc

" vim: filetype=vim
