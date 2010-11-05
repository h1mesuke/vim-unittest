"=============================================================================
" File    : autoload/assert.vim
" Author  : h1mesuke
" Updated : 2010-11-05
" Version : 0.1.4
"
" Licensed under the MIT license:
" http://www.opensource.org/licenses/mit-license.php
"
"=============================================================================

function! assert#true(expr, ...)
  call s:count_assertion()
  let hint = (a:0 ? string(a:1) : "")
  if !a:expr
    call s:add_failure("assert#true",
          \ "True expected, but was\n" . string(a:expr), hint)
  else
    call s:add_success()
  endif
endfunction

function! assert#false(expr, ...)
  call s:count_assertion()
  let hint = (a:0 ? string(a:1) : "")
  if a:expr
    call s:add_failure("assert#false",
          \ "False expected, but was\n" . string(a:expr), hint)
  else
    call s:add_success()
  endif
endfunction

function! assert#is_number(val, ...)
  call s:count_assertion()
  let hint = (a:0 ? string(a:1) : "")
  if type(a:val) != type(0)
    call s:add_failure("assert#is_number",
          \ "Number expected, but was\n" . s:typestr(a:val), hint)
  else
    call s:add_success()
  endif
endfunction

function! assert#is_string(val, ...)
  call s:count_assertion()
  let hint = (a:0 ? string(a:1) : "")
  if type(a:val) != type("")
    call s:add_failure("assert#is_string",
          \ "String expected, but was\n" . s:typestr(a:val), hint)
  else
    call s:add_success()
  endif
endfunction

function! assert#is_funcref(val, ...)
  call s:count_assertion()
  let hint = (a:0 ? string(a:1) : "")
  if type(a:val) != type(function("tr"))
    call s:add_failure("assert#is_funcref",
          \ "Funcref expected, but was\n" . s:typestr(a:val), hint)
  else
    call s:add_success()
  endif
endfunction

function! assert#is_list(val, ...)
  call s:count_assertion()
  let hint = (a:0 ? string(a:1) : "")
  if type(a:val) != type([])
    call s:add_failure("assert#is_list",
          \ "List expected, but was\n" . s:typestr(a:val), hint)
  else
    call s:add_success()
  endif
endfunction

function! assert#is_dictionary(val, ...)
  call s:count_assertion()
  if type(a:val) != type({})
    let hint = (a:0 ? string(a:1) : "")
    call s:add_failure("assert#is_dictionary",
          \ "Dictionary expected, but was\n" . s:typestr(a:val), hint)
  else
    call s:add_success()
  endif
endfunction

function! assert#is_float(val, ...)
  call s:count_assertion()
  let hint = (a:0 ? string(a:1) : "")
  if type(a:val) != type(0.0)
    call s:add_failure("assert#is_float",
          \ "Float expected, but was\n" . s:typestr(a:val), hint)
  else
    call s:add_success()
  endif
endfunction

function! s:typestr(val)
  if type(a:val) == type(0)
    return 'Number'
  elseif type(a:val) == type("")
    return 'String'
  elseif type(a:val) == type(function("tr"))
    return 'Funcref'
  elseif type(a:val) == type([])
    return 'List'
  elseif type(a:val) == type({})
    return 'Dictionary'
  elseif type(a:val) == type(0.0)
    return 'Float'
  endif
endfunction

function! assert#equal(val_1, val_2, ...)
  call s:count_assertion()
  let hint = (a:0 ? string(a:1) : "")
  if type(a:val_1) == 1 && type(a:val_2) == 1
    if a:val_1 !=# a:val_2
      call s:add_failure("assert#equal",
            \ string(a:val_1) . " expected but was\n" . string(a:val_2), hint)
    else
      call s:add_success()
    endif
  else
    if a:val_1 != a:val_2
      call s:add_failure("assert#equal",
            \ string(a:val_1) . " expected but was\n" . string(a:val_2), hint)
    else
      call s:add_success()
    endif
  endif
endfunction

function! assert#equal_c(val_1, val_2, ...)
  call s:count_assertion()
  let hint = (a:0 ? string(a:1) : "")
  if a:val_1 !=? a:val_2
    call s:add_failure("assert#equal_c",
          \ string(a:val_1) . " expected but was\n" . string(a:val_2), hint)
  else
    call s:add_success()
  endif
endfunction

function! assert#equal_C(val_1, val_2, ...)
  call s:count_assertion()
  let hint = (a:0 ? string(a:1) : "")
  if a:val_1 !=# a:val_2
    call s:add_failure("assert#equal_C",
          \ string(a:val_1) . " expected but was\n" . string(a:val_2), hint)
  else
    call s:add_success()
  endif
endfunction

function! assert#not_equal(val_1, val_2, ...)
  call s:count_assertion()
  let hint = (a:0 ? string(a:1) : "")
  if type(a:val_1) == 1 && type(a:val_2) == 1
    if a:val_1 ==# a:val_2
      call s:add_failure("assert#not_equal",
            \ string(a:val_1) . " not expected but was\n" . string(a:val_2), hint)
    else
      call s:add_success()
    endif
  else
    if a:val_1 == a:val_2
      call s:add_failure("assert#not_equal",
            \ string(a:val_1) . " not expected but was\n" . string(a:val_2), hint)
    else
      call s:add_success()
    endif
  endif
endfunction

function! assert#not_equal_c(val_1, val_2, ...)
  call s:count_assertion()
  let hint = (a:0 ? string(a:1) : "")
  if a:val_1 ==? a:val_2
    call s:add_failure("assert#not_equal_c",
          \ string(a:val_1) . " not expected but was\n" . string(a:val_2), hint)
  else
    call s:add_success()
  endif
endfunction

function! assert#not_equal_C(val_1, val_2, ...)
  call s:count_assertion()
  let hint = (a:0 ? string(a:1) : "")
  if a:val_1 ==# a:val_2
    call s:add_failure("assert#not_equal_C",
          \ string(a:val_1) . " not expected but was\n" . string(a:val_2), hint)
  else
    call s:add_success()
  endif
endfunction

function! assert#same(val_1, val_2, ...)
  call s:count_assertion()
  let hint = (a:0 ? string(a:1) : "")
  if a:val_1 isnot a:val_2
    call s:add_failure("assert#same",
          \ string(a:val_1) . " itself expected but was\n" . string(a:val_2), hint)
  else
    call s:add_success()
  endif
endfunction

function! assert#not_same(val_1, val_2, ...)
  call s:count_assertion()
  let hint = (a:0 ? string(a:1) : "")
  if a:val_1 is a:val_2
    call s:add_failure("assert#not_same",
          \ string(a:val_1) . " itself not expected but was\n" . string(a:val_2), hint)
  else
    call s:add_success()
  endif
endfunction

function! assert#match(val, pat, ...)
  call s:count_assertion()
  let hint = (a:0 ? string(a:1) : "")
  if match(a:val, a:pat) < 0
    call s:add_failure("assert#match",
          \ string(a:val) . " didn't match against " . string(a:pat), hint)
  else
    call s:add_success()
  endif
endfunction

function! assert#not_match(val, pat, ...)
  call s:count_assertion()
  let hint = (a:0 ? string(a:1) : "")
  if match(a:val, a:pat) >= 0
    call s:add_failure("assert#not_match",
          \ string(a:val) . " matched against " . string(a:pat), hint)
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

function! s:add_failure(assert, reason, hint)
  let results = unittest#results()
  call results.add_failure(a:assert, a:reason, a:hint)
endfunction

" vim: filetype=vim
