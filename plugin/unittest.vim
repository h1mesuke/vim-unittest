"=============================================================================
" Simple Unit Testing Framework for Vim script
"
" File    : plugin/unittest.vim
" Author  : h1mesuke
" Updated : 2011-02-27
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

if v:version < 700 || &cp
  echoerr "unittest: Vim 7.0 or later required"
  finish
elseif exists('g:loaded_unittest')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

"-----------------------------------------------------------------------------
" Variables

if !exists('g:unittest_smooth_redraw_results')
  let g:unittest_smooth_redraw_results = 1
endif

"-----------------------------------------------------------------------------
" Command

command! -nargs=* -complete=file UnitTest call unittest#run(<f-args>)

"-----------------------------------------------------------------------------

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_unittest = 1

" vim: filetype=vim
