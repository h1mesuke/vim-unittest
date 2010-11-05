" himesuke's vimrc suite
" Maintainer: Satoshi Himeno <himesuke@gmail.com>

let tc = unittest#testcase(expand('<sfile>:p'))

function! tc.test_bool_assertions()
  call assert#true(1)
  call assert#true(0)
  call assert#false(0)
  call assert#false(1)
endfunction

function! tc.test_type_assertions()
  call assert#is_number(1)
  call assert#is_number("a")
  call assert#is_string("a")
  call assert#is_string(1)
  call assert#is_funcref(function("type"))
  call assert#is_funcref(1)
  call assert#is_list([1,2,3])
  call assert#is_list(1)
  call assert#is_dictionary({ 1:'a', 2:'b' })
  call assert#is_dictionary(1)
  call assert#is_float(3.14)
  call assert#is_float(1)
endfunction

function! tc.test_equal_assertions()
  call assert#equal(1, 1)
  call assert#equal(1, 2)
  call assert#equal_c("a", "A")
  call assert#equal_c("a", "b")
  call assert#equal_C("a", "a")
  call assert#equal_C("a", "b")

  call assert#not_equal(1, 2)
  call assert#not_equal(1, 1)
  call assert#not_equal_c("a", "b")
  call assert#not_equal_c("a", "A")
  call assert#not_equal_C("a", "b")
  call assert#not_equal_C("a", "a")
endfunction

function! tc.test_same_assertions()
  let a = []
  let b = []
  call assert#same(a, a)
  call assert#same(a, b)

  call assert#not_same(a, b)
  call assert#not_same(a, a)
endfunction

function! tc.test_match_assertions()
  call assert#match("hello", 'e')
  call assert#match(["hello", "goodbyb"], 'e')
  call assert#match("hello", 'x')
  call assert#match(["hello", "goodbyb"], 'x')

  call assert#not_match("hello", 'x')
  call assert#not_match(["hello", "goodbyb"], 'x')
  call assert#not_match("hello", 'e')
  call assert#not_match(["hello", "goodbyb"], 'e')
endfunction

function! tc.test_error()
  call foo#bar#baz()
endfunction

unlet tc

" vim: filetype=vim
