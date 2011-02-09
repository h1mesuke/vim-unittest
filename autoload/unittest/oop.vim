"=============================================================================
" vim-oop
" Class-based OOP Layer for Vim script <Mininum Edition>
"
" File    : oop.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2011-02-01
" Version : 0.1.6
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

let s:initialized = 0

function! unittest#oop#_is_initialized()
  return s:initialized
endfunction

function! unittest#oop#_initialize()
  if s:initialized | return | endif
  let s:initialized = 1

  let Class = unittest#oop#class#_initialize()
  let Object = unittest#oop#object#_initialize()

  let Class.superclass = Object

  let Object_instance_methods = copy(Object.prototype)
  unlet Object_instance_methods.initialize

  call extend(Object, Object_instance_methods, 'keep')

  call extend(Class, Object_instance_methods, 'keep')
  call extend(Class.prototype, Object_instance_methods, 'keep')
endfunction

function! unittest#oop#is_object(obj)
  return (type(a:obj) == type({}) && has_key(a:obj, 'class') &&
        \ type(a:obj.class) == type({}) && has_key(a:obj.class, 'class') &&
        \ a:obj.class.class is unittest#oop#class#get('Class'))
endfunction

function! unittest#oop#is_class(obj)
  return (unittest#oop#is_object(a:obj) && a:obj.class is unittest#oop#class#get('Class'))
endfunction

function! unittest#oop#is_instance(obj)
  return (unittest#oop#is_object(a:obj) && a:obj.class isnot unittest#oop#class#get('Class'))
endfunction

function! unittest#oop#inspect(value)
  if unittest#oop#is_object(a:value)
    return a:value.inspect()
  else
    return s:safe_dump(a:value)
  endif
endfunction

function! unittest#oop#string(value)
  if unittest#oop#is_object(a:value)
    return a:value.to_s()
  else
    return s:safe_dump(a:value)
  endif
endfunction

function! s:safe_dump(value)
  return string(s:_safe_dump(a:value))
endfunction
function! s:_safe_dump(value)
  let value_type = type(a:value)
  if value_type == type({}) || value_type == type([])
    return map(copy(a:value), 'unittest#oop#is_object(v:val) ? v:val.to_s() : s:_safe_dump(v:val)')
  else
    return a:value
  endif
endfunction

if !s:initialized
  call unittest#oop#_initialize()
endif

" vim: filetype=vim
