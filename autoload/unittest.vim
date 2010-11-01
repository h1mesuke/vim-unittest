"=============================================================================
" File    : unittest.vim
" Require : assert.vim
" Author  : h1mesuke
" Updated : 2010-10-27
" Version : 0.1.0
"
" Licensed under the MIT license:
" http://www.opensource.org/licenses/mit-license.php
"
"=============================================================================

function! unittest#init()
  let g:unittest_testcases = []
endfunction

function! unittest#testcase(name)
  let testcase = {
        \ 'name': a:name,
        \ 'tests': [],
        \ 'stats': { 'assertions': 0, 'failures': 0, 'errors': 0 },
        \ }
  call add(g:unittest_testcases, testcase)
endfunction

function! unittest#add(testfunc)
  call add(s:testcase().tests, a:testfunc)
endfunction

function! unittest#run()
  let saved_pos = getpos(".")
  for testcase in g:unittest_testcases
    call s:print_header(1, testcase.name)
    for Testfunc in testcase.tests
      let funcname = matchstr(string(Testfunc), '<SNR>\d\+_\zs\w\+')
      call s:print_header(2, funcname)
      try
        call Testfunc()
      catch
        call s:add_error()
        let idx = printf('%3d', unittest#stats().errors)
        echohl Error
        echomsg idx . ") Error: " . v:throwpoint
        echomsg v:exception
        echohl None
      endtry
    endfor
  endfor
  call s:print_stats()
  call setpos(".", saved_pos)
endfunction

function! s:testcase()
  return g:unittest_testcases[-1]
endfunction

function! s:add_error()
  let testcase = s:testcase()
  let testcase.stats.errors += 1
endfunction

function! s:print_header(level, title)
  let now = strftime("%Y-%m-%d %H:%M:%S")
  if a:level == 1
    echomsg "=======================================================[" . now . "]"
    echomsg toupper(substitute(a:title, '#', ' # ', 'g'))
  elseif a:level == 2
    echomsg "-------------------------------------------------------[" . now . "]"
    echomsg toupper(substitute(a:title, '#', ' # ', 'g'))
  else
    echomsg "@ " . a:title
  endif
endfunction

function! unittest#stats()
  let stats = {
        \ 'tests'     : 0,
        \ 'assertions': 0,
        \ 'failures'  : 0,
        \ 'errors'    : 0,
        \ }
  for testcase in g:unittest_testcases
    let stats.tests      += len(testcase.tests)
    let stats.assertions += testcase.stats.assertions
    let stats.failures   += testcase.stats.failures
    let stats.errors     += testcase.stats.errors
  endfor
  return stats
endfunction

function! s:print_stats()
  call s:print_header(2, '')
  let stats = unittest#stats()
  if stats.failures > 0 || stats.errors > 0
    echohl Error
  endif
  echomsg stats.tests . " tests, " . stats.assertions . " assertions, " .
        \ stats.failures . " failures, " . stats.errors . " errors"
  echohl None
endfunction

" vim: filetype=vim
