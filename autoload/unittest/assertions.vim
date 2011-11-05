"=============================================================================
" Simple Unit Testing Framework for Vim script
"
" File    : autoload/unittest/assertions.vim
" Author	: h1mesuke <himesuke@gmail.com>
" Updated : 2011-11-06
" Version : 0.3.2
" License : MIT license {{{
"
"   Permission is hereby granted, free of charge, to any person obtaining
"   a copy of this software and associated documentation files (the
"   "Software"), to deal in the Software without restriction, including
"   without limitation the rights to use, copy, modify, merge, publish,
"   distribute, sublicense, and/or sell copies of the Software, and to
"   permit persons to whom the Software is furnished to do so, subject to
"   the following conditions:
"   
"   The above copyright notice and this permission notice shall be included
"   in all copies or substantial portions of the Software.
"   
"   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"   OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

function! unittest#assertions#sid()
  return s:SID
endfunction

function! unittest#assertions#module()
  return s:Assertions
endfunction

let s:Assertions = unittest#oop#module#new('Assertions', s:SID)

function! s:Assertions_assert_true(expr, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if !a:expr
    call s:add_failure(
          \ "True expected, but was\n" .
          \ unittest#oop#string(a:expr),
          \ hint)
  else
    call s:add_success()
  endif
endfunction
call s:Assertions.function('assert_true')
call s:Assertions.alias('assert', 'assert_true')

function! s:Assertions_assert_false(expr, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:expr
    call s:add_failure(
          \ "False expected, but was\n" .
          \ unittest#oop#string(a:expr),
          \ hint)
  else
    call s:add_success()
  endif
endfunction
call s:Assertions.function('assert_false')
call s:Assertions.alias('assert_not', 'assert_false')

function! s:Assertions_assert_equal(expected, actual, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if type(a:expected) == type("") && type(a:actual) == type("")
    if a:expected !=# a:actual
      call s:add_failure(
            \ unittest#oop#string(a:expected) . " expected but was\n" .
            \ unittest#oop#string(a:actual),
            \ hint)
    else
      call s:add_success()
    endif
  else
    if a:expected != a:actual
      call s:add_failure(
            \ unittest#oop#string(a:expected) . " expected but was\n" .
            \ unittest#oop#string(a:actual),
            \ hint)
    else
      call s:add_success()
    endif
  endif
endfunction
call s:Assertions.function('assert_equal')

function! s:Assertions_assert_not_equal(expected, actual, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if type(a:expected) == type("") && type(a:actual) == type("")
    if a:expected ==# a:actual
      call s:add_failure(
            \ unittest#oop#string(a:expected) . " not expected but was\n" .
            \ unittest#oop#string(a:actual),
            \ hint)
    else
      call s:add_success()
    endif
  else
    if a:expected == a:actual
      call s:add_failure(
            \ unittest#oop#string(a:expected) . " not expected but was\n" .
            \ unittest#oop#string(a:actual),
            \ hint)
    else
      call s:add_success()
    endif
  endif
endfunction
call s:Assertions.function('assert_not_equal')

function! s:Assertions_assert_equal_c(expected, actual, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:expected !=? a:actual
    call s:add_failure(
          \ unittest#oop#string(a:expected) . " expected but was\n" .
          \ unittest#oop#string(a:actual),
          \ hint)
  else
    call s:add_success()
  endif
endfunction
call s:Assertions.function('assert_equal_c')

function! s:Assertions_assert_not_equal_c(expected, actual, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:expected ==? a:actual
    call s:add_failure(
          \ unittest#oop#string(a:expected) . " not expected but was\n" .
          \ unittest#oop#string(a:actual),
          \ hint)
  else
    call s:add_success()
  endif
endfunction
call s:Assertions.function('assert_not_equal_c')

function! s:Assertions_assert_equal_C(expected, actual, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:expected !=# a:actual
    call s:add_failure(
          \ unittest#oop#string(a:expected) . " expected but was\n" .
          \ unittest#oop#string(a:actual),
          \ hint)
  else
    call s:add_success()
  endif
endfunction
call s:Assertions.function('assert_equal_C')

function! s:Assertions_assert_not_equal_C(expected, actual, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:expected ==# a:actual
    call s:add_failure(
          \ unittest#oop#string(a:expected) . " not expected but was\n" .
          \ unittest#oop#string(a:actual),
          \ hint)
  else
    call s:add_success()
  endif
endfunction
call s:Assertions.function('assert_not_equal_C')

function! s:Assertions_assert_exists(expr, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:expr =~ '^:'
    call s:assert_command_exists(a:expr, hint)
  elseif !exists(a:expr)
    call s:add_failure(
          \ unittest#oop#string(a:expr) . " doesn't exist",
          \ hint)
  else
    call s:add_success()
  endif
endfunction
call s:Assertions.function('assert_exists')
call s:Assertions.alias('assert_exist', 'assert_exists')

function! s:assert_command_exists(command, hint)
  if exists(a:command) != 2
    call s:add_failure(
          \ unittest#oop#string(a:command) . " is not defined",
          \ a:hint)
  else
    call s:add_success()
  endif
endfunction

function! s:Assertions_assert_not_exists(expr, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:expr =~ '^:'
    call s:assert_command_not_exists(a:expr, hint)
  elseif exists(a:expr)
    call s:add_failure(
          \ unittest#oop#string(a:expr) . " exists",
          \ hint)
  else
    call s:add_success()
  endif
endfunction
call s:Assertions.function('assert_not_exists')
call s:Assertions.alias('assert_not_exist', 'assert_not_exists')

function! s:assert_command_not_exists(command, hint)
  if exists(a:command) == 2
    call s:add_failure(
          \ unittest#oop#string(a:command) . " is defined",
          \ a:hint)
  else
    call s:add_success()
  endif
endfunction

function! s:Assertions_assert_is(expected, actual, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:expected isnot a:actual
    call s:add_failure(
          \ unittest#oop#string(a:expected) . " itself expected but was\n" .
          \ unittest#oop#string(a:actual),
          \ hint)
  else
    call s:add_success()
  endif
endfunction
call s:Assertions.function('assert_is')

function! s:Assertions_assert_is_not(expected, actual, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:expected is a:actual
    call s:add_failure(
          \ unittest#oop#string(a:expected) . " itself not expected but was\n" .
          \ unittest#oop#string(a:actual) . " itself",
          \ hint)
  else
    call s:add_success()
  endif
endfunction
call s:Assertions.function('assert_is_not')

function! s:Assertions_assert_is_Number(value, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if type(a:value) != type(0)
    call s:add_failure(
          \ "Number expected, but was\n" .
          \ s:typestr(a:value),
          \ hint)
  else
    call s:add_success()
  endif
endfunction
call s:Assertions.function('assert_is_Number')

function! s:Assertions_assert_is_String(value, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if type(a:value) != type("")
    call s:add_failure(
          \ "String expected, but was\n" .
          \ s:typestr(a:value),
          \ hint)
  else
    call s:add_success()
  endif
endfunction
call s:Assertions.function('assert_is_String')

function! s:Assertions_assert_is_Funcref(value, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if type(a:value) != type(function('tr'))
    call s:add_failure(
          \ "Funcref expected, but was\n" .
          \ s:typestr(a:value),
          \ hint)
  else
    call s:add_success()
  endif
endfunction
call s:Assertions.function('assert_is_Funcref')

function! s:Assertions_assert_is_List(value, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if type(a:value) != type([])
    call s:add_failure(
          \ "List expected, but was\n" .
          \ s:typestr(a:value),
          \ hint)
  else
    call s:add_success()
  endif
endfunction
call s:Assertions.function('assert_is_List')

function! s:Assertions_assert_is_Dictionary(value, ...)
  call s:count_assertion()
  if type(a:value) != type({})
    let hint = (a:0 ? a:1 : "")
    call s:add_failure(
          \ "Dictionary expected, but was\n" .
          \ s:typestr(a:value),
          \ hint)
  else
    call s:add_success()
  endif
endfunction
call s:Assertions.function('assert_is_Dictionary')
call s:Assertions.alias('assert_is_Dict', 'assert_is_Dictionary')

function! s:Assertions_assert_is_Float(value, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if type(a:value) != type(0.0)
    call s:add_failure(
          \ "Float expected, but was\n" .
          \ s:typestr(a:value),
          \ hint)
  else
    call s:add_success()
  endif
endfunction
call s:Assertions.function('assert_is_Float')

function! s:typestr(value)
  let value_type = type(a:value)
  if value_type == type(0)
    return 'Number'
  elseif value_type == type("")
    return 'String'
  elseif value_type == type(function("tr"))
    return 'Funcref'
  elseif value_type == type([])
    return 'List'
  elseif unittest#oop#is_class(a:value)
    return 'Class'
  elseif unittest#oop#is_instance(a:value)
    return 'Instance'
  elseif unittest#oop#is_module(a:value)
    return 'Module'
  elseif value_type == type({})
    return 'Dictionary'
  elseif value_type == type(0.0)
    return 'Float'
  endif
endfunction

function! s:Assertions_assert_match(pattern, str, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if match(a:str, a:pattern) < 0
    call s:add_failure(
          \ unittest#oop#string(a:str) . " didn't match the pattern " .
          \ unittest#oop#string(a:pattern),
          \ hint)
  else
    call s:add_success()
  endif
endfunction
call s:Assertions.function('assert_match')

function! s:Assertions_assert_not_match(pattern, str, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if match(a:str, a:pattern) >= 0
    call s:add_failure(
          \ unittest#oop#string(a:str) . " matched the pattern " .
          \ unittest#oop#string(a:pattern),
          \ hint)
  else
    call s:add_success()
  endif
endfunction
call s:Assertions.function('assert_not_match')

function! s:Assertions_assert_throw(exception, ex_command, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  try
    execute a:ex_command
  catch
    if v:exception =~# a:exception
      call s:add_success()
    else
      call s:add_failure(
            \ unittest#oop#string(a:ex_command) .
            \   " didn't throw /" . a:exception . "/, but threw:\n" .
            \ v:exception,
            \ hint)
    endif
    return
  endtry
  call s:add_failure(
        \ unittest#oop#string(a:ex_command) . " didn't throw /" . a:exception . "/\n" .
        \ "Nothing thrown.",
        \ hint)
endfunction
call s:Assertions.function('assert_throw')

function! s:Assertions_assert_not_throw(ex_command, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  try
    execute a:ex_command
  catch
    call s:add_failure(
          \ unittest#oop#string(a:ex_command) . " threw:\n" .
          \ v:exception,
          \ hint)
    return
  endtry
  call s:add_success()
endfunction
call s:Assertions.function('assert_not_throw')
call s:Assertions.alias('assert_nothing_thrown', 'assert_not_throw')

"-----------------------------------------------------------------------------
" vim-oop

" h1mesuke/vim-oop - GitHub
" https://github.com/h1mesuke/vim-oop

function! s:Assertions_assert_is_Object(value, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if !unittest#oop#is_object(a:value)
    call s:add_failure(
          \ "Object expected, but was\n" .
          \ s:typestr(a:value),
          \ hint)
  else
    call s:add_success()
  endif
endfunction
call s:Assertions.function('assert_is_Object')

function! s:Assertions_assert_is_Class(value, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if !unittest#oop#is_class(a:value)
    call s:add_failure(
          \ "Class expected, but was\n" .
          \ s:typestr(a:value),
          \ hint)
  else
    call s:add_success()
  endif
endfunction
call s:Assertions.function('assert_is_Class')

function! s:Assertions_assert_is_Instance(value, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if !unittest#oop#is_instance(a:value)
    call s:add_failure(
          \ "Instance expected, but was\n" .
          \ s:typestr(a:value),
          \ hint)
  else
    call s:add_success()
  endif
endfunction
call s:Assertions.function('assert_is_Instance')

function! s:Assertions_assert_is_Module(value, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if !unittest#oop#is_module(a:value)
    call s:add_failure(
          \ "Module expected, but was\n" .
          \ s:typestr(a:value),
          \ hint)
  else
    call s:add_success()
  endif
endfunction
call s:Assertions.function('assert_is_Module')

function! s:Assertions_assert_is_kind_of(class, value, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if !a:value.is_kind_of(a:class)
    call s:add_failure(
          \ unittest#oop#string(a:value) . " is not kind of " . a:class.__name__,
          \ hint)
  else
    call s:add_success()
  endif
endfunction
call s:Assertions.function('assert_is_kind_of')

function! s:Assertions_assert_is_instance_of(class, value, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:value.__class__ isnot a:class
    call s:add_failure(
          \ unittest#oop#string(a:value) . " is not an instance of " . a:class.__name__,
          \ hint)
  else
    call s:add_success()
  endif
endfunction
call s:Assertions.function('assert_is_instance_of')

"-----------------------------------------------------------------------------

function! s:count_assertion()
  if unittest#is_running()
    let results = unittest#results()
    call results.count_assertion()
  endif
endfunction

function! s:add_success()
  if unittest#is_running()
    let results = unittest#results()
    call results.add_success()
  endif
endfunction

function! s:add_failure(reason, hint)
  if unittest#is_running()
    let results = unittest#results()
    call results.add_failure(a:reason, a:hint)
  else
    let msg = substitute(a:reason, "\n", ' ', 'g')
    if !empty(a:hint)
      let msg .= " (" . a:hint . ")"
    endif
    throw "AssertionFailedError: " . msg
  endif
endfunction

" vim: filetype=vim
