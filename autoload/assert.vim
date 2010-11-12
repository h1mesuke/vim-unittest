"=============================================================================
" File    : autoload/assert.vim
" Author  : h1mesuke
" Updated : 2010-11-08
" Version : 0.1.4
"
" Licensed under the MIT license:
" http://www.opensource.org/licenses/mit-license.php
"
"=============================================================================

function! assert#true(expr, ...)
  call s:count_assertion()
  let msg = (a:0 ? string(a:1) : "")
  if !a:expr
    call s:add_failure(
          \ "True expected, but was\n" .
          \ string(a:expr), msg)
  else
    call s:add_success()
  endif
endfunction

function! assert#false(expr, ...)
  call s:count_assertion()
  let msg = (a:0 ? string(a:1) : "")
  if a:expr
    call s:add_failure(
          \ "False expected, but was\n" .
          \ string(a:expr), msg)
  else
    call s:add_success()
  endif
endfunction

function! assert#is_number(value, ...)
  call s:count_assertion()
  let msg = (a:0 ? string(a:1) : "")
  if type(a:value) != type(0)
    call s:add_failure(
          \ "Number expected, but was\n" .
          \ s:typestr(a:value), msg)
  else
    call s:add_success()
  endif
endfunction

function! assert#is_string(value, ...)
  call s:count_assertion()
  let msg = (a:0 ? string(a:1) : "")
  if type(a:value) != type("")
    call s:add_failure(
          \ "String expected, but was\n" .
          \ s:typestr(a:value), msg)
  else
    call s:add_success()
  endif
endfunction

function! assert#is_funcref(value, ...)
  call s:count_assertion()
  let msg = (a:0 ? string(a:1) : "")
  if type(a:value) != type(function("tr"))
    call s:add_failure(
          \ "Funcref expected, but was\n" .
          \ s:typestr(a:value), msg)
  else
    call s:add_success()
  endif
endfunction

function! assert#is_list(value, ...)
  call s:count_assertion()
  let msg = (a:0 ? string(a:1) : "")
  if type(a:value) != type([])
    call s:add_failure(
          \ "List expected, but was\n" .
          \ s:typestr(a:value), msg)
  else
    call s:add_success()
  endif
endfunction

function! assert#is_dictionary(value, ...)
  call s:count_assertion()
  if type(a:value) != type({})
    let msg = (a:0 ? string(a:1) : "")
    call s:add_failure(
          \ "Dictionary expected, but was\n" .
          \ s:typestr(a:value), msg)
  else
    call s:add_success()
  endif
endfunction

function! assert#is_float(value, ...)
  call s:count_assertion()
  let msg = (a:0 ? string(a:1) : "")
  if type(a:value) != type(0.0)
    call s:add_failure(
          \ "Float expected, but was\n" .
          \ s:typestr(a:value), msg)
  else
    call s:add_success()
  endif
endfunction

function! s:typestr(value)
  if type(a:value) == type(0)
    return 'Number'
  elseif type(a:value) == type("")
    return 'String'
  elseif type(a:value) == type(function("tr"))
    return 'Funcref'
  elseif type(a:value) == type([])
    return 'List'
  elseif type(a:value) == type({})
    return 'Dictionary'
  elseif type(a:value) == type(0.0)
    return 'Float'
  endif
endfunction

function! assert#equal(value_1, value_2, ...)
  call s:count_assertion()
  let msg = (a:0 ? string(a:1) : "")
  if type(a:value_1) == 1 && type(a:value_2) == 1
    if a:value_1 !=# a:value_2
      call s:add_failure(
            \ string(a:value_1) . " expected but was\n" .
            \ string(a:value_2), msg)
    else
      call s:add_success()
    endif
  else
    if a:value_1 != a:value_2
      call s:add_failure(
            \ string(a:value_1) . " expected but was\n" .
            \ string(a:value_2), msg)
    else
      call s:add_success()
    endif
  endif
endfunction

function! assert#equal_c(value_1, value_2, ...)
  call s:count_assertion()
  let msg = (a:0 ? string(a:1) : "")
  if a:value_1 !=? a:value_2
    call s:add_failure(
          \ string(a:value_1) . " expected but was\n" .
          \ string(a:value_2), msg)
  else
    call s:add_success()
  endif
endfunction

function! assert#equal_C(value_1, value_2, ...)
  call s:count_assertion()
  let msg = (a:0 ? string(a:1) : "")
  if a:value_1 !=# a:value_2
    call s:add_failure(
          \ string(a:value_1) . " expected but was\n" .
          \ string(a:value_2), msg)
  else
    call s:add_success()
  endif
endfunction

function! assert#not_equal(value_1, value_2, ...)
  call s:count_assertion()
  let msg = (a:0 ? string(a:1) : "")
  if type(a:value_1) == 1 && type(a:value_2) == 1
    if a:value_1 ==# a:value_2
      call s:add_failure(
            \ string(a:value_1) . " not expected but was\n" .
            \ string(a:value_2), msg)
    else
      call s:add_success()
    endif
  else
    if a:value_1 == a:value_2
      call s:add_failure(
            \ string(a:value_1) . " not expected but was\n" .
            \ string(a:value_2), msg)
    else
      call s:add_success()
    endif
  endif
endfunction

function! assert#not_equal_c(value_1, value_2, ...)
  call s:count_assertion()
  let msg = (a:0 ? string(a:1) : "")
  if a:value_1 ==? a:value_2
    call s:add_failure(
          \ string(a:value_1) . " not expected but was\n" .
          \ string(a:value_2), msg)
  else
    call s:add_success()
  endif
endfunction

function! assert#not_equal_C(value_1, value_2, ...)
  call s:count_assertion()
  let msg = (a:0 ? string(a:1) : "")
  if a:value_1 ==# a:value_2
    call s:add_failure(
          \ string(a:value_1) . " not expected but was\n" .
          \ string(a:value_2), msg)
  else
    call s:add_success()
  endif
endfunction

function! assert#same(value_1, value_2, ...)
  call s:count_assertion()
  let msg = (a:0 ? string(a:1) : "")
  if a:value_1 isnot a:value_2
    call s:add_failure(
          \ string(a:value_1) . " itself expected but was\n" .
          \ string(a:value_2), msg)
  else
    call s:add_success()
  endif
endfunction

function! assert#not_same(value_1, value_2, ...)
  call s:count_assertion()
  let msg = (a:0 ? string(a:1) : "")
  if a:value_1 is a:value_2
    call s:add_failure(
          \ string(a:value_1) . " itself not expected but was\n" .
          \ string(a:value_2), msg)
  else
    call s:add_success()
  endif
endfunction

function! assert#match(value, pat, ...)
  call s:count_assertion()
  let msg = (a:0 ? string(a:1) : "")
  if match(a:value, a:pat) < 0
    call s:add_failure(
          \ string(a:value) . " didn't match against " . string(a:pat), msg)
  else
    call s:add_success()
  endif
endfunction

function! assert#not_match(value, pat, ...)
  call s:count_assertion()
  let msg = (a:0 ? string(a:1) : "")
  if match(a:value, a:pat) >= 0
    call s:add_failure(
          \ string(a:value) . " matched against " . string(a:pat), msg)
  else
    call s:add_success()
  endif
endfunction

function! s:count_assertion()
  let results = unittest#results()
  call results.count_assertion()
endfunction

function! s:add_success()
  let results = unittest#results()
  call results.add_success()
endfunction

function! s:add_failure(reason, message)
  let results = unittest#results()
  call results.add_failure(a:reason, a:message)
endfunction

" vim: filetype=vim
