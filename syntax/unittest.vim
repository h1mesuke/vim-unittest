"=============================================================================
" File    : syntax/unittest.vim
" Author  : h1mesuke
" Updated : 2010-11-06
" Version : 0.1.4
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

hi def UnitTestGreen ctermfg=Green guifg=Green
hi def UnitTestRed   ctermfg=Red   guifg=Red

syn match UnitTestStats
      \ '^\d\+ tests, \d\+ assertions, \d\+ failures, \d\+ errors$'
      \ contains=UnitTestNoFailures,UnitTestNoErrors,UnitTestSomeFailures,UnitTestSomeErrors

syn match UnitTestNoFailures    / \@<=0 failures,\( 0 errors\)\@=/ contained
syn match UnitTestNoErrors      /\( 0 failures, \)\@<=0 errors/    contained
syn match UnitTestSomeFailures  /[1-9]\d* failures,/               contained
syn match UnitTestSomeErrors    /[1-9]\d* errors/                  contained

hi def link UnitTestNoFailures   UnitTestGreen
hi def link UnitTestNoErrors     UnitTestGreen
hi def link UnitTestSomeFailures UnitTestRed
hi def link UnitTestSomeErrors   UnitTestRed

let b:current_syntax = 'unittest'

" vim: filetype=vim
