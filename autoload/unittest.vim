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

function! unittest#run(...)
  let s:test_runner = s:TestRunner.new()
  if a:0
    let tc_files = a:000
  else
    let tc_files = [expand('%:p')]
  endif
  for tc_file in tc_files
    execute 'source' tc_file
  endfor
  call s:test_runner.run()
  unlet s:test_runner
endfunction

function! unittest#runner()
  return s:test_runner
endfunction

function! unittest#testcase()
  let tc = s:TestCase.new()
  call s:test_runner.add_testcase(tc)
  return tc
endfunction

"-----------------------------------------------------------------------------
" TestRunner

let s:TestRunner = {}

function! s:TestRunner.new()
  let obj = copy(self)
  call obj.init()
  return obj
endfunction

function! s:TestRunner.init()
  let self.class = s:TestRunner
  let self.testcases = []
endfunction

function! s:TestRunner.add_testcase(tc)
  call add(self.testcases, a:tc)
endfunction

function! s:TestRunner.run()
  let saved_pos = getpos(".")
  for tc in self.testcases
    let self.testcase = tc
    for test in tc.tests()
      call s:print_header(2, test)
      try
        call tc[test]()
      catch
        call tc.add_error()
        let idx = printf('%3d', unittest#runner().stats().errors)
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

function! s:TestRunner.stats()
  let stats = {
        \ 'tests'     : 0,
        \ 'assertions': 0,
        \ 'failures'  : 0,
        \ 'errors'    : 0,
        \ }
  for tc in self.testcases
    let stats.tests      += len(tc.tests())
    let stats.assertions += tc.stats.assertions
    let stats.failures   += tc.stats.failures
    let stats.errors     += tc.stats.errors
  endfor
  return stats
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

function! s:print_stats()
  call s:print_header(2, '')
  let stats = unittest#runner().stats()
  if stats.failures > 0 || stats.errors > 0
    echohl Error
  endif
  echomsg stats.tests . " tests, " . stats.assertions . " assertions, " .
        \ stats.failures . " failures, " . stats.errors . " errors"
  echohl None
endfunction

"-----------------------------------------------------------------------------
" TestCase

let s:TestCase = {}

function! s:TestCase.new()
  let obj = copy(self)
  call obj.init()
  return obj
endfunction

function! s:TestCase.init()
  let self.class = s:TestCase
  let self.path = expand('<sfile>:p')
  let self.name = 'testcase'
  let self.stats = { 'assertions': 0, 'failures': 0, 'errors': 0 }
endfunction

function! s:TestCase.tests()
  return filter(keys(self), "v:val =~# '^test_'")
endfunction

function! s:TestCase.add_error()
  let self.stats.errors += 1
endfunction

" vim: filetype=vim
