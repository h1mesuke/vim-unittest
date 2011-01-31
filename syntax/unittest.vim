"=============================================================================
" Simple Unit Testing Framework for Vimscript
"
" File    : syntax/unittest.vim
" Author  : h1mesuke
" Updated : 2011-01-22
" Version : 0.2.8
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

highlight default UnitTestGreen ctermfg=Green guifg=Green
highlight default UnitTestRed   ctermfg=Red   guifg=Red

syntax match UnitTestHeader
      \ '^TEST_.*'
      \ contains=UnitTestResults
      \ keepend

syntax match UnitTestResults
      \ '\( => \)\@<=[.FE]\+'
      \ contained
      \ contains=UnitTestFailure,UnitTestError

syntax match UnitTestFailure
      \ 'F'
      \ contained

syntax match UnitTestError
      \ 'E'
      \ contained

syntax match UnitTestErrorHeader
      \ '^\s*\d\+) \(Failure\|Error\):.*'

syntax match UnitTestStats
      \ '^\d\+ tests, \d\+ assertions, \d\+ failures, \d\+ errors$'
      \ contains=UnitTestNoFailures,UnitTestNoErrors,UnitTestSomeFailures,UnitTestSomeErrors
      \ keepend

syntax match UnitTestNoFailures
      \ ' \@<=0 failures,\( 0 errors\)\@='
      \ contained

syntax match UnitTestNoErrors
      \ '\( 0 failures, \)\@<=0 errors'
      \ contained

syntax match UnitTestSomeFailures
      \ '[1-9]\d* failures,'
      \ contained

syntax match UnitTestSomeErrors
      \ '[1-9]\d* errors'
      \ contained

highlight default link UnitTestFailure      UnitTestRed
highlight default link UnitTestError        UnitTestRed

highlight default link UnitTestErrorHeader  ErrorMsg

highlight default link UnitTestNoFailures   UnitTestGreen
highlight default link UnitTestNoErrors     UnitTestGreen
highlight default link UnitTestSomeFailures UnitTestRed
highlight default link UnitTestSomeErrors   UnitTestRed

let b:current_syntax = 'unittest'

" vim: filetype=vim
