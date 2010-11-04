"=============================================================================
" File    : assert.vim
" Author  : h1mesuke
" Updated : 2010-11-04
" Version : 0.1.2
"
" Licensed under the MIT license:
" http://www.opensource.org/licenses/mit-license.php
"
"=============================================================================

function! assert#true(expr, ...)
  call s:add_assertion()
  let which = (a:0 ? string(a:1) : "")
  if !a:expr
    call s:add_failure()
    call s:print_failure("assert#true",
          \ "True expected, but was\n" . string(a:expr), which)
  endif
endfunction

function! assert#false(expr, ...)
  call s:add_assertion()
  let which = (a:0 ? string(a:1) : "")
  if a:expr
    call s:add_failure()
    call s:print_failure("assert#false",
          \ "False expected, but was\n" . string(a:expr), which)
  endif
endfunction

function! assert#is_number(val, ...)
  call s:add_assertion()
  let which = (a:0 ? string(a:1) : "")
  if type(a:val) != type(0)
    call s:add_failure()
    call s:print_failure("assert#is_number",
          \ "Number expected, but was\n" . s:typestr(a:val), which)
  endif
endfunction

function! assert#is_string(val, ...)
  call s:add_assertion()
  let which = (a:0 ? string(a:1) : "")
  if type(a:val) != type("")
    call s:add_failure()
    call s:print_failure("assert#is_string",
          \ "String expected, but was\n" . s:typestr(a:val), which)
  endif
endfunction

function! assert#is_funcref(val, ...)
  call s:add_assertion()
  let which = (a:0 ? string(a:1) : "")
  if type(a:val) != type(function("tr"))
    call s:add_failure()
    call s:print_failure("assert#is_funcref",
          \ "Funcref expected, but was\n" . s:typestr(a:val), which)
  endif
endfunction

function! assert#is_list(val, ...)
  call s:add_assertion()
  let which = (a:0 ? string(a:1) : "")
  if type(a:val) != type([])
    call s:add_failure()
    call s:print_failure("assert#is_list",
          \ "List expected, but was\n" . s:typestr(a:val), which)
  endif
endfunction

function! assert#is_dictionary(val, ...)
  call s:add_assertion()
  if type(a:val) != type({})
    let which = (a:0 ? string(a:1) : "")
    call s:add_failure()
    call s:print_failure("assert#is_dictionary",
          \ "Dictionary expected, but was\n" . s:typestr(a:val), which)
  endif
endfunction

function! assert#is_float(val, ...)
  call s:add_assertion()
  let which = (a:0 ? string(a:1) : "")
  if type(a:val) != type(0.0)
    call s:add_failure()
    call s:print_failure("assert#is_float",
          \ "Float expected, but was\n" . s:typestr(a:val), which)
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
  call s:add_assertion()
  let which = (a:0 ? string(a:1) : "")
  if type(a:val_1) == 1 && type(a:val_2) == 1
    if a:val_1 !=# a:val_2
      call s:add_failure()
      call s:print_failure("assert#equal",
            \ string(a:val_1) . " expected but was\n" . string(a:val_2), which)
    endif
  else
    if a:val_1 != a:val_2
      call s:add_failure()
      call s:print_failure("assert#equal",
            \ string(a:val_1) . " expected but was\n" . string(a:val_2), which)
    endif
  endif
endfunction

function! assert#equal_c(val_1, val_2, ...)
  call s:add_assertion()
  let which = (a:0 ? string(a:1) : "")
  if a:val_1 !=? a:val_2
    call s:add_failure()
    call s:print_failure("assert#equal_c",
          \ string(a:val_1) . " expected but was\n" . string(a:val_2), which)
  endif
endfunction

function! assert#equal_C(val_1, val_2, ...)
  call s:add_assertion()
  let which = (a:0 ? string(a:1) : "")
  if a:val_1 !=# a:val_2
    call s:add_failure()
    call s:print_failure("assert#equal_C",
          \ string(a:val_1) . " expected but was\n" . string(a:val_2), which)
  endif
endfunction

function! assert#not_equal(val_1, val_2, ...)
  call s:add_assertion()
  let which = (a:0 ? string(a:1) : "")
  if type(a:val_1) == 1 && type(a:val_2) == 1
    if a:val_1 ==# a:val_2
      call s:add_failure()
      call s:print_failure("assert#not_equal",
            \ string(a:val_1) . " not expected but was\n" . string(a:val_2), which)
    endif
  else
    if a:val_1 == a:val_2
      call s:add_failure()
      call s:print_failure("assert#not_equal",
            \ string(a:val_1) . " not expected but was\n" . string(a:val_2), which)
    endif
  endif
endfunction

function! assert#not_equal_c(val_1, val_2, ...)
  call s:add_assertion()
  let which = (a:0 ? string(a:1) : "")
  if a:val_1 ==? a:val_2
    call s:add_failure()
    call s:print_failure("assert#not_equal_c",
          \ string(a:val_1) . " not expected but was\n" . string(a:val_2), which)
  endif
endfunction

function! assert#not_equal_C(val_1, val_2, ...)
  call s:add_assertion()
  let which = (a:0 ? string(a:1) : "")
  if a:val_1 ==# a:val_2
    call s:add_failure()
    call s:print_failure("assert#not_equal_C",
          \ string(a:val_1) . " not expected but was\n" . string(a:val_2), which)
  endif
endfunction

function! assert#same(val_1, val_2, ...)
  call s:add_assertion()
  let which = (a:0 ? string(a:1) : "")
  if a:val_1 isnot a:val_2
    call s:add_failure()
    call s:print_failure("assert#same",
          \ string(a:val_1) . " itself expected but was\n" . string(a:val_2), which)
  endif
endfunction

function! assert#not_same(val_1, val_2, ...)
  call s:add_assertion()
  let which = (a:0 ? string(a:1) : "")
  if a:val_1 is a:val_2
    call s:add_failure()
    call s:print_failure("assert#not_same",
          \ string(a:val_1) . " itself not expected but was\n" . string(a:val_2), which)
  endif
endfunction

function! assert#match(val, pat, ...)
  call s:add_assertion()
  let which = (a:0 ? string(a:1) : "")
  if match(a:val, a:pat) < 0
    call s:add_failure()
    call s:print_failure("assert#match",
          \ string(a:val) . " didn't match against " . string(a:pat), which)
  endif
endfunction

function! assert#not_match(val, pat, ...)
  call s:add_assertion()
  let which = (a:0 ? string(a:1) : "")
  if match(a:val, a:pat) >= 0
    call s:add_failure()
    call s:print_failure("assert#not_match",
          \ string(a:val) . " matched against " . string(a:pat), which)
  endif
endfunction

function! s:testcase()
  return unittest#runner().testcase
endfunction

function! s:add_assertion()
  let tc = s:testcase()
  let tc.stats.assertions += 1
endfunction

function! s:add_failure()
  let tc = s:testcase()
  let tc.stats.failures += 1
endfunction

function! s:print_failure(test, reason, ...)
  let which = (a:0 ? a:1 : "")
  let idx = printf('%3d', unittest#runner().stats().failures)
  echohl Error
  echomsg idx . ") Failure: " . a:test . ": " . which
  echohl None
  for line in split(a:reason, "\n")
    echomsg line
  endfor
endfunction

" vim: filetype=vim
