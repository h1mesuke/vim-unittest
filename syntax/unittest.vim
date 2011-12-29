"=============================================================================
" Simple Unit Testing Framework for Vim script
"
" File    : syntax/unittest.vim
" Author  : h1mesuke
" Updated : 2011-12-29
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

if version < 700
  syntax clear
elseif exists('b:current_syntax')
  finish
endif

execute 'highlight default UnitTestRed'
      \ 'ctermfg=' . g:unittest_color_red   'guifg=' . g:unittest_color_red
execute 'highlight default UnitTestGreen'
      \ 'ctermfg=' . g:unittest_color_green 'guifg=' . g:unittest_color_green

syntax match UnitTestGreenStatusLine
      \ '^\h\w* => \.\+$'

syntax match UnitTestRedStatusLine
      \ '^\h\w* => \.*[FE][.FE]*$'
      \ contains=UnitTestRedTest,UnitTestStatusFailure,UnitTestStatusError

syntax match UnitTestStatusFailure
      \ 'F'
      \ contained

syntax match UnitTestStatusError
      \ 'E'
      \ contained

syntax match UnitTestRedTest
      \ '^\zs\h\w*\ze => \.*[FE]'
      \ contained

syntax match UnitTestFailure
      \ '^\s\+\zsFailed:.*$'

syntax match UnitTestError
      \ '^\s\+\zsError:.*$'

syntax match UnitTestResults
      \ '^\d\+ tests, \d\+ assertions, \d\+ failures, \d\+ errors$'
      \ contains=UnitTestSomeFailures,UnitTestSomeErrors,UnitTestAllGreen

syntax match UnitTestSomeFailures
      \ '[1-9]\d* failures,'
      \ contained

syntax match UnitTestSomeErrors
      \ '[1-9]\d* errors'
      \ contained

syntax match UnitTestAllGreen
      \ '0 failures, 0 errors'
      \ contained

highlight default link UnitTestRedTest       UnitTestRed
highlight default link UnitTestStatusFailure UnitTestRed
highlight default link UnitTestStatusError   UnitTestRed

highlight default link UnitTestFailure       UnitTestRed
highlight default link UnitTestError         UnitTestRed

highlight default link UnitTestSomeFailures  UnitTestRed
highlight default link UnitTestSomeErrors    UnitTestRed
highlight default link UnitTestAllGreen      UnitTestGreen

let b:current_syntax = 'unittest'

" vim: filetype=vim
