"=============================================================================
" vim-oop
" OOP Support for Vim script
"
" File    : oop.vim
" Author  : h1mesuke <himesuke+vim@gmail.com>
" Updated : 2012-01-17
" Version : 0.2.4
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

let s:save_cpo = &cpo
set cpo&vim

let s:TYPE_NUM  = type(0)
let s:TYPE_DICT = type({})
let s:TYPE_LIST = type([])
let s:TYPE_FUNC = type(function('tr'))

let s:namespace = {}

function! unittest#oop#__namespace__()
  return s:namespace
endfunction

function! unittest#oop#is_object(value)
  return type(a:value) == s:TYPE_DICT && has_key(a:value, '__vim_oop__')
endfunction

function! unittest#oop#is_class(value)
  return type(a:value) == s:TYPE_DICT && has_key(a:value, '__vim_oop__') &&
        \ has_key(a:value, '__prototype__')
endfunction

function! unittest#oop#is_instance(value)
  return type(a:value) == s:TYPE_DICT && has_key(a:value, '__vim_oop__') &&
        \ has_key(a:value, 'class')
endfunction

function! unittest#oop#is_module(value)
  return type(a:value) == s:TYPE_DICT && has_key(a:value, '__vim_oop__') &&
        \ !has_key(a:value, '__prototype__') && !has_key(a:value, 'class')
endfunction

function! unittest#oop#string(value)
  let value = a:value
  let type = type(a:value)
  if type == s:TYPE_LIST || type == s:TYPE_DICT
    let value = deepcopy(a:value)
    call s:demote_objects(value)
  endif
  return string(value)
endfunction

function! s:demote_objects(value)
  let type = type(a:value)
  if type == s:TYPE_LIST
    call map(a:value, 's:demote_objects(v:val)')
  elseif type == s:TYPE_DICT
    if has_key(a:value, '__vim_oop__') && has_key(a:value, 'class')
      call a:value.demote()
    endif
    call map(values(a:value), 's:demote_objects(v:val)')
  endif
  return a:value
endfunction

function! unittest#oop#deserialize(str)
  sandbox let dict = eval(a:str)
  return s:promote_objects(dict)
endfunction

function! s:promote_objects(value)
  let type = type(a:value)
  if type == s:TYPE_LIST
    call map(a:value, 's:promote_objects(v:val)')
  elseif type == s:TYPE_DICT
    if has_key(a:value, 'class')
      let class = unittest#oop#class#get(a:value.class)
      call class.promote(a:value)
    endif
    call map(values(a:value), 's:promote_objects(v:val)')
  endif
  return a:value
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
