"=============================================================================
" Simple OOP Layer for Vimscript
"
" File    : oop/object.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2011-01-19
" Version : 0.0.5
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

function! s:SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:sid = s:SID()

let s:Object = unittest#oop#class#new('Object', {})

function! s:Object_initialize(...) dict
endfunction
call s:Object.define('initialize', function(s:sid . 'Object_initialize'))

function! s:Object_is_a(class) dict
  let class = self.class
  while !empty(class)
    if class is a:class
      return 1
    endif
    let class = class.super
  endwhile
  return 0
endfunction
call s:Object.define('is_a', function(s:sid . 'Object_is_a'))

function! s:Object_to_s() dict
  return '<' . self.class.name . ':0x' . printf('%08x', self.object_id) . '>'
endfunction
call s:Object.define('to_s', function(s:sid . 'Object_to_s'))

" vim: filetype=vim
