"=============================================================================
" File    : plugin/unittest.vim
" Author  : h1mesuke
" Updated : 2010-11-06
" Version : 0.1.5
"
" Licensed under the MIT license:
" http://www.opensource.org/licenses/mit-license.php
"
"=============================================================================

command! -nargs=* UnitTest call unittest#run(<f-args>)

" vim: filetype=vim
