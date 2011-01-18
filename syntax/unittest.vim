"=============================================================================
" File    : syntax/unittest.vim
" Author  : h1mesuke
" Updated : 2010-11-19
" Version : 0.2.2
"
" Licensed under the MIT license:
" http://www.opensource.org/licenses/mit-license.php
"
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
