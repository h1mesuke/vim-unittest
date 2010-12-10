"=============================================================================
" File    : autoload/assert.vim
" Author	: h1mesuke <himesuke@gmail.com>
" Updated : 2010-12-02
" Version : 0.1.8
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

function! assert#true(expr, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if !a:expr
    call s:add_failure(
          \ "True expected, but was\n" .
          \ string(a:expr),
          \ hint)
  else
    call s:add_success()
  endif
endfunction

function! assert#false(expr, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:expr
    call s:add_failure(
          \ "False expected, but was\n" .
          \ string(a:expr),
          \ hint)
  else
    call s:add_success()
  endif
endfunction

function! assert#equal(value_1, value_2, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if type(a:value_1) == type("") && type(a:value_2) == type("")
    if a:value_1 !=# a:value_2
      call s:add_failure(
            \ string(a:value_1) . " expected but was\n" .
            \ string(a:value_2),
            \ hint)
    else
      call s:add_success()
    endif
  else
    if a:value_1 != a:value_2
      call s:add_failure(
            \ string(a:value_1) . " expected but was\n" .
            \ string(a:value_2),
            \ hint)
    else
      call s:add_success()
    endif
  endif
endfunction

function! assert#not_equal(value_1, value_2, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if type(a:value_1) == type("") && type(a:value_2) == type("")
    if a:value_1 ==# a:value_2
      call s:add_failure(
            \ string(a:value_1) . " not expected but was\n" .
            \ string(a:value_2),
            \ hint)
    else
      call s:add_success()
    endif
  else
    if a:value_1 == a:value_2
      call s:add_failure(
            \ string(a:value_1) . " not expected but was\n" .
            \ string(a:value_2),
            \ hint)
    else
      call s:add_success()
    endif
  endif
endfunction

function! assert#equals(value_1, value_2, ...)
  call assert#equal(a:value_1, a:value_2, (a:0 ? a:1 : ""))
endfunction

function! assert#not_equals(value_1, value_2, ...)
  call assert#not_equal(a:value_1, a:value_2, (a:0 ? a:1 : ""))
endfunction

function! assert#equal_c(value_1, value_2, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:value_1 !=? a:value_2
    call s:add_failure(
          \ string(a:value_1) . " expected but was\n" .
          \ string(a:value_2),
          \ hint)
  else
    call s:add_success()
  endif
endfunction

function! assert#not_equal_c(value_1, value_2, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:value_1 ==? a:value_2
    call s:add_failure(
          \ string(a:value_1) . " not expected but was\n" .
          \ string(a:value_2),
          \ hint)
  else
    call s:add_success()
  endif
endfunction

function! assert#equals_c(value_1, value_2, ...)
  call assert#equal_c(a:value_1, a:value_2, (a:0 ? a:1 : ""))
endfunction

function! assert#not_equals_c(value_1, value_2, ...)
  call assert#not_equal_c(a:value_1, a:value_2, (a:0 ? a:1 : ""))
endfunction

function! assert#equal_C(value_1, value_2, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:value_1 !=# a:value_2
    call s:add_failure(
          \ string(a:value_1) . " expected but was\n" .
          \ string(a:value_2),
          \ hint)
  else
    call s:add_success()
  endif
endfunction

function! assert#not_equal_C(value_1, value_2, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:value_1 ==# a:value_2
    call s:add_failure(
          \ string(a:value_1) . " not expected but was\n" .
          \ string(a:value_2),
          \ hint)
  else
    call s:add_success()
  endif
endfunction

function! assert#equals_C(value_1, value_2, ...)
  call assert#equal_C(a:value_1, a:value_2, (a:0 ? a:1 : ""))
endfunction

function! assert#not_equals_C(value_1, value_2, ...)
  call assert#not_equal_C(a:value_1, a:value_2, (a:0 ? a:1 : ""))
endfunction

function! assert#exists(expr, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if !exists(a:expr)
    call s:add_failure(
          \ string(a:expr) . " doesn't exist",
          \ hint)
  else
    call s:add_success()
  endif
endfunction

function! assert#not_exists(expr, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if exists(a:expr)
    call s:add_failure(
          \ string(a:expr) . " exist",
          \ hint)
  else
    call s:add_success()
  endif
endfunction

function! assert#is_Number(value, ...)
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

function! assert#is_String(value, ...)
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

function! assert#is_Funcref(value, ...)
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

function! assert#is_List(value, ...)
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

function! assert#is_Dictionary(value, ...)
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

function! assert#is_Float(value, ...)
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

function! s:typestr(value)
  let val_type = type(a:value)
  if val_type == type(0)
    return 'Number'
  elseif val_type == type("")
    return 'String'
  elseif val_type == type(function("tr"))
    return 'Funcref'
  elseif val_type == type([])
    return 'List'
  elseif val_type == type({})
    return 'Dictionary'
  elseif val_type == type(0.0)
    return 'Float'
  endif
endfunction

function! assert#match(value, pattern, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if match(a:value, a:pattern) < 0
    call s:add_failure(
          \ string(a:value) . " didn't match the pattern " . string(a:pattern),
          \ hint)
  else
    call s:add_success()
  endif
endfunction

function! assert#not_match(value, pattern, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if match(a:value, a:pattern) >= 0
    call s:add_failure(
          \ string(a:value) . " matched the pattern " . string(a:pattern),
          \ hint)
  else
    call s:add_success()
  endif
endfunction

function! assert#raise(ex_command, pattern, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  try
    execute a:ex_command
  catch
    if v:exception =~# a:pattern
      call s:add_success()
    else
      call s:add_failure(
            \ string(a:ex_command) . " didn't raise /" . a:pattern . "/, but raised:\n" .
            \ v:exception,
            \ hint)
    endif
    return
  endtry
  call s:add_failure(
        \ string(a:ex_command) . " didn't raise /" . a:pattern . "/\n" .
        \ "Nothing raised.",
        \ hint)
endfunction

function! assert#nothing_raised(ex_command, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  try
    execute a:ex_command
  catch
    call s:add_failure(
          \ string(a:ex_command) . " raised:\n" .
          \ v:exception,
          \ hint)
    return
  endtry
  call s:add_success()
endfunction

function! assert#same(value_1, value_2, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:value_1 isnot a:value_2
    call s:add_failure(
          \ string(a:value_1) . " itself expected but was\n" .
          \ string(a:value_2),
          \ hint)
  else
    call s:add_success()
  endif
endfunction

function! assert#not_same(value_1, value_2, ...)
  call s:count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:value_1 is a:value_2
    call s:add_failure(
          \ string(a:value_1) . " itself not expected but was\n" .
          \ string(a:value_2) . " itself",
          \ hint)
  else
    call s:add_success()
  endif
endfunction

function! s:count_assertion()
  let results = unittest#results()
  if !empty(results)
    call results.count_assertion()
  endif
endfunction

function! s:add_success()
  let results = unittest#results()
  if !empty(results)
    call results.add_success()
  endif
endfunction

function! s:add_failure(reason, hint)
  let results = unittest#results()
  if !empty(results)
    call results.add_failure(a:reason, a:hint)
  endif
endfunction

" vim: filetype=vim
