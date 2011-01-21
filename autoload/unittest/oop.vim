"=============================================================================
" Simple OOP Layer for Vimscript
"
" File    : oop.vim
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

function! unittest#oop#is_class(obj)
  let Class = unittest#oop#class#get('Class')
  return (type(a:obj) == type({}) && has_key(a:obj, 'class') &&
        \ (a:obj.class is Class || a:obj is Class))
endfunction

function! unittest#oop#is_instance(obj)
  return (unittest#oop#is_object(a:obj) && !unittest#oop#is_class(a:obj))
endfunction

function! unittest#oop#is_object(obj)
  return (type(a:obj) == type({}) && has_key(a:obj, 'class') && unittest#oop#is_class(a:obj.class))
endfunction

" vim: filetype=vim
