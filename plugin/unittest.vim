"=============================================================================
" File    : unittest.vim
" Require : assert.vim
" Author  : h1mesuke
" Updated : 2010-11-04
" Version : 0.1.2
"
" Licensed under the MIT license:
" http://www.opensource.org/licenses/mit-license.php
"
"=============================================================================

command! -nargs=* Unittest call unittest#run(<f-args>)

" vim: filetype=vim
