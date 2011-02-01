" unittest.vim's test suite

" Testcase of assertions
"
" Expected results are: 
" T tests, A assertions, A/2 failures, 1 errors

let tc = unittest#testcase#new('test_assert')

let s:Foo = unittest#oop#class#new('Foo')
let s:Bar = unittest#oop#class#new('Bar', 'Foo')

"-----------------------------------------------------------------------------

function! tc.setup()
  let self.foo = s:Foo.new()
  let self.bar = s:Bar.new()

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
  call assert#true(1)
  call assert#true(0)
endfunction

function! tc.test_assert_false()
  call assert#false(0)
  call assert#false(1)
endfunction

function! tc.test_assert_()
  call assert#_(1)
  call assert#_(0)
endfunction

function! tc.test_assert_not()
  call assert#not(0)
  call assert#not(1)
endfunction

function! tc.test_assert_equal()
  call assert#equal(1, 1)
  call assert#equal(1, 2)
endfunction

function! tc.test_assert_not_equal()
  call assert#not_equal(1, 2)
  call assert#not_equal(1, 1)
endfunction

function! tc.test_assert_equal_c()
  call assert#equal_c("a", "A")
  call assert#equal_c("a", "b")
endfunction

function! tc.test_assert_not_equal_c()
  call assert#not_equal_c("a", "b")
  call assert#not_equal_c("a", "A")
endfunction

function! tc.test_assert_equal_C()
  call assert#equal_C("a", "a")
  call assert#equal_C("a", "b")
endfunction

function! tc.test_assert_not_equal_C()
  call assert#not_equal_C("a", "b")
  call assert#not_equal_C("a", "a")
endfunction

function! tc.test_assert_exists()
  call assert#exists('*tr')
  call assert#exists('*foo#bar#baz')

  call assert#exists(':bnext')
  call assert#exists(':bn')
endfunction

function! tc.test_assert_not_exists()
  call assert#not_exists('*foo#bar#baz')
  call assert#not_exists('*tr')

  call assert#not_exists(':bn')
  call assert#not_exists(':bnext')
endfunction

function! tc.test_assert_has_key()
  call assert#has_key('foo', { 'foo': 1 })
  call assert#has_key('bar', { 'foo': 1 })
endfunction

function! tc.test_assert_is()
  let a = []
  let b = []
  call assert#is(a, a)
  call assert#is(a, b)
endfunction

function! tc.test_assert_is_not()
  let a = []
  let b = []
  call assert#is_not(a, b)
  call assert#is_not(a, a)
endfunction

function! tc.test_assert_is_same()
  let a = []
  let b = []
  call assert#is_same(a, a)
  call assert#is_same(a, b)
endfunction

function! tc.test_assert_is_not_same()
  let a = []
  let b = []
  call assert#is_not_same(a, b)
  call assert#is_not_same(a, a)
endfunction

function! tc.test_assert_is_Number()
  call assert#is_Number(1)
  call assert#is_Number("a")
endfunction

function! tc.test_assert_is_String()
  call assert#is_String("a")
  call assert#is_String(1)
endfunction

function! tc.test_assert_is_Funcref()
  call assert#is_Funcref(function("type"))
  call assert#is_Funcref(1)
endfunction

function! tc.test_assert_is_List()
  call assert#is_List([1,2,3])
  call assert#is_List(1)
endfunction

function! tc.test_assert_is_Dictionary()
  call assert#is_Dictionary({ 1:'a', 2:'b' })
  call assert#is_Dictionary(1)
endfunction

function! tc.test_assert_is_Float()
  call assert#is_Float(3.14)
  call assert#is_Float(1)
endfunction

function! tc.test_assert_is_Object()
  call assert#is_Object(self.foo)
  call assert#is_Object({})
endfunction

function! tc.test_assert_is_instance_of()
  call assert#is_instance_of('Foo', self.foo)
  call assert#is_instance_of('Bar', self.foo)
endfunction

function! tc.test_assert_is_kind_of()
  call assert#is_kind_of('Foo', self.bar)
  call assert#is_kind_of('Bar', self.foo)
endfunction

function! tc.test_assert_match()
  call assert#match('e', "hello")
  call assert#match('x', "hello")

  call assert#match('e', ["hello", "goodbye"])
  call assert#match('x', ["hello", "goodbye"])
endfunction

function! tc.test_assert_not_match()
  call assert#not_match('x', "hello")
  call assert#not_match('e', "hello")

  call assert#not_match('x', ["hello", "goodbye"])
  call assert#not_match('e', ["hello", "goodbye"])
endfunction

function! tc.test_assert_raise()
  call assert#raise('E492', 'FooBarBaz')
  call assert#raise('E492', 'nohl')
endfunction

function! tc.test_assert_nothing_raised()
  call assert#nothing_raised('nohl')
  call assert#nothing_raised('FooBarBaz')
endfunction

function! tc.test_error()
  call foo#bar#baz()
endfunction

unlet tc

" vim: filetype=vim
