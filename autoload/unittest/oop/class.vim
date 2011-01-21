"=============================================================================
" Simple OOP Layer for Vimscript
" Minimum Edition
"
" File    : oop/class.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2011-01-22
" Version : 0.0.8
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

function! unittest#oop#class#is_defined(name)
  return has_key(s:class_table, a:name)
endfunction

function! unittest#oop#class#get(name)
  if unittest#oop#class#is_defined(a:name)
    return s:class_table[a:name]
  else
    throw "oop: class " . a:name . " is not defined"
  endif
endfunction

function! unittest#oop#class#new(name, ...)
  let _self = deepcopy(s:Class, 1)
  let _self.class = s:Class
  if a:0
    let superclass = a:1
    if unittest#oop#is_class(superclass)
      let _self.superclass = superclass
    elseif type(superclass) == type("")
      let _self.superclass = unittest#oop#class#get(superclass)
    else
      throw "oop: class required, but got " . string(superclass)
    endif
  else
    let _self.superclass = unittest#oop#class#get('Object')
  endif
  let _self.name  = a:name
  let s:class_table[a:name] = _self
  " inherit methods from superclasses
  let class = _self.superclass
  while !empty(class)
    call extend(_self, class, 'keep')
    call extend(_self.prototype, class.prototype, 'keep')
    let class = class.superclass
  endwhile
  return _self
endfunction

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()

let s:Class = { 'class': {}, 'prototype': {} }
let s:class_table = { 'Class': s:Class, '__nil__': {} }

function! s:Class_class_alias(alias, method_name) dict
  if has_key(self, a:method_name) && type(self[a:method_name]) == type(function('tr'))
    let self[a:alias] = self[a:method_name]
  else
    throw "oop: " . self.name . "." . a:method_name . "() is not defined"
  endif
endfunction
let s:Class.class_alias = function(s:SID . 'Class_class_alias')

function! s:Class_class_bind(sid, method_name) dict
  let self[a:method_name] = function(a:sid . self.name . '_class_' . a:method_name)
endfunction
let s:Class.class_bind = function(s:SID . 'Class_class_bind')

function! s:Class_alias(alias, method_name) dict
  if has_key(self.prototype, a:method_name) &&
        \ type(self.prototype[a:method_name]) == type(function('tr'))
    let self.prototype[a:alias] = self.prototype[a:method_name]
  else
    throw "oop: " . self.name . "#" . a:method_name . "() is not defined"
  endif
endfunction
let s:Class.alias = function(s:SID . 'Class_alias')

function! s:Class_bind(sid, method_name) dict
  let self.prototype[a:method_name] = function(a:sid . self.name . '_' . a:method_name)
endfunction
let s:Class.bind = function(s:SID . 'Class_bind')

function! s:Class_export(method_name) dict
  if has_key(self.prototype, a:method_name) &&
        \ type(self.prototype[a:method_name]) == type(function('tr'))
    let self[a:method_name] = self.prototype[a:method_name]
  else
    throw "oop: " . self.name . "#" . a:method_name . "() is not defined"
  endif
endfunction
let s:Class.export = function(s:SID . 'Class_export')

function! s:Class_new(...) dict
  " instantiate
  let obj = copy(self.prototype)
  let obj.class = self
  call call(obj.initialize, a:000, obj)
  return obj
endfunction
let s:Class.new = function(s:SID . 'Class_new')

" bootstrap
execute 'source' expand('<sfile>:p:h') . '/object.vim'

" vim: filetype=vim
