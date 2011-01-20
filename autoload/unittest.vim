"=============================================================================
" File    : autoload/unittest.vim
" Author	: h1mesuke <himesuke@gmail.com>
" Updated : 2011-01-20
" Version : 0.2.3
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

function! unittest#run(...)
  let args = a:000
  if empty(filter(copy(args), "v:val !~ '^[gv]/'"))
    " if no argument was given, process the current buffer
    let args += ['%']
  endif

  let tc_files = []
  let test_filters = { 'g_pattern': "", 'v_pattern': "" }
  for value in args
    " filtering pattern
    let matched_list = matchlist(value, '^\([gv]\)/\(.*\)$')
    if len(matched_list) > 0
      if matched_list[1] ==# 'g'
        let test_filters.g_pattern = matched_list[2]
      else
        let test_filters.v_pattern = matched_list[2]
      endif
      continue
    endif
    " testcase
    let path = expand(value)
    if path =~# '\<\(test_\|t[cs]_\)\w\+\.vim$'
      call add(tc_files, path)
      continue
    endif
    " invalid value
    call s:print_error("unittest: sourced file is not a testcase")
    return
  endfor

  try
    let s:test_runner = s:TestRunner.new(test_filters)
    for tc_file in tc_files
      execute 'source' tc_file
    endfor
    call s:test_runner.run()
  catch
    call s:print_error(v:throwpoint)
    call s:print_error(v:exception)
  finally
    if exists('s:test_runner')
      unlet s:test_runner
    endif
  endtry
endfunction

function! unittest#runner()
  if !unittest#is_running()
    call s:print_error("unittest: no test is running")
    return {}
  endif
  return s:test_runner
endfunction

function! unittest#testcase()
  if !unittest#is_running()
    call s:print_error("unittest: no test is running")
    return {}
  endif
  return s:test_runner.context.testcase
endfunction

function! unittest#results()
  if !unittest#is_running()
    call s:print_error("unittest: no test is running")
    return {}
  endif
  return s:test_runner.results
endfunction

function! unittest#is_running()
  return exists('s:test_runner')
endfunction

function! s:print_error(msg)
  echohl ErrorMsg | echomsg a:msg | echohl None
endfunction

function! s:SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:sid = s:SID()

"-----------------------------------------------------------------------------
" TestRunner

let s:TestRunner = unittest#oop#class#new('TestRunner')

function! s:TestRunner_initialize(test_filters) dict
  let self.testcases = []
  let self.test_filters = a:test_filters
  let self.context = {}
  let self.results = s:TestResults.new(self)
endfunction
call s:TestRunner.define('initialize', function(s:sid . 'TestRunner_initialize'))

function! s:TestRunner_add_testcase(tc) dict
  call add(self.testcases, a:tc)
endfunction
call s:TestRunner.define('add_testcase', function(s:sid . 'TestRunner_add_testcase'))

function! s:TestRunner_run() dict
  if has("reltime")
    let start_time = reltime()
  endif
  let s:Failure.id = 1 | let s:Error.id = 1
  call self.results.open_window()
  for tc in self.testcases
    let self.context.testcase = tc
    call self.results.print_header(1, tc.name)
    call self.results.puts()
    if tc.context_file != ""
      call tc.open_context_file()
    endif
    let tests = self._filter_tests(tc.tests())
    for test in tests
      let self.context.test = test
      call self.results.count_test()
      call self.results.print_header(2, test)
      let self.context.test_header_lnum = self.results.append(" => ")
      try
        call tc.__setup__(test)
        call tc[test]()
      catch
        call self.results.add_error()
      endtry
      try
        call tc.__teardown__(test)
      catch
        call self.results.add_error()
      endtry
      call self.results.flush()
    endfor
  endfor
  call self.results.print_stats()
  if has("reltime")
    let used_time = split(reltimestr(reltime(start_time)))[0]
    call self.results.puts("Finished in " . used_time . " seconds.")
  endif
  call self.results.focus_window()
endfunction
call s:TestRunner.define('run', function(s:sid . 'TestRunner_run'))

function! s:TestRunner__filter_tests(tests) dict
  let tests = copy(a:tests)
  if self.test_filters.g_pattern != ""
    call filter(tests, 'v:val =~# self.test_filters.g_pattern')
  endif
  if self.test_filters.v_pattern != ""
    call filter(tests, 'v:val !~# self.test_filters.v_pattern')
  endif
  return tests
endfunction
call s:TestRunner.define('_filter_tests', function(s:sid . 'TestRunner__filter_tests'))

"-----------------------------------------------------------------------------
" TestResults

let s:TestResults = unittest#oop#class#new('TestResults')

function! s:TestResults_initialize(runner) dict
  let self.context = a:runner.context
  let self.stats = {
        \ 'n_tests'     : 0,
        \ 'n_assertions': 0,
        \ 'n_failures'  : 0,
        \ 'n_errors'    : 0,
        \ }
  let self.buffer = []
endfunction
call s:TestResults.define('initialize', function(s:sid . 'TestResults_initialize'))

function! s:TestResults_open_window() dict
  if !exists('s:results_bufnr') || !bufexists(s:results_bufnr)
    " the buffer doesn't exist
    split
    edit `='[unittest results]'`
    let s:results_bufnr = bufnr('%')
  elseif bufwinnr(s:results_bufnr) != -1
    " the buffer exists, and it has a window
    execute bufwinnr(s:results_bufnr) 'wincmd w'
  else
    " the buffer exists, but it has no window
    split
    execute 'buffer' s:results_bufnr
  endif
  call self._init_results_buffer()
endfunction
call s:TestResults.define('open_window', function(s:sid . 'TestResults_open_window'))

function! s:TestResults_focus_window() dict
  execute bufwinnr(s:results_bufnr) 'wincmd w'
endfunction
call s:TestResults.define('focus_window', function(s:sid . 'TestResults_focus_window'))

function! s:TestResults__init_results_buffer() dict
  nnoremap <buffer> q <C-w>c
  setlocal bufhidden=hide buftype=nofile noswapfile nobuflisted
  setlocal filetype=unittest
  silent! %delete _
endfunction
call s:TestResults.define('_init_results_buffer',
      \ function(s:sid . 'TestResults__init_results_buffer'))

function! s:TestResults_count_test() dict
  let self.stats.n_tests += 1
endfunction
call s:TestResults.define('count_test', function(s:sid . 'TestResults_count_test'))

function! s:TestResults_count_assertion() dict
  let self.stats.n_assertions += 1
endfunction
call s:TestResults.define('count_assertion', function(s:sid . 'TestResults_count_assertion'))

function! s:TestResults_add_success() dict
  call self.append(".", self.context.test_header_lnum)
endfunction
call s:TestResults.define('add_success', function(s:sid . 'TestResults_add_success'))

function! s:TestResults_add_failure(reason, hint) dict
  let fail = s:Failure.new(a:reason, a:hint)
  call add(self.buffer, fail)
  call self.append("F", self.context.test_header_lnum)
endfunction
call s:TestResults.define('add_failure', function(s:sid . 'TestResults_add_failure'))

function! s:TestResults_add_error() dict
  let err = s:Error.new()
  call add(self.buffer, err)
  call self.append("E", self.context.test_header_lnum)
endfunction
call s:TestResults.define('add_error', function(s:sid . 'TestResults_add_error'))

function! s:TestResults_puts(...) dict
  let save_winnr =  bufwinnr('%')
  execute bufwinnr(s:results_bufnr) 'wincmd w'
  let str = (a:0 ? a:1 : "")
  call append('$', str)
  normal! G
  setlocal nomodified
  execute save_winnr 'wincmd w'
  if g:unittest_smooth_redraw_results
    redraw
  endif
endfunction
call s:TestResults.define('puts', function(s:sid . 'TestResults_puts'))

function! s:TestResults_append(str, ...) dict
  let save_winnr =  bufwinnr('%')
  execute bufwinnr(s:results_bufnr) 'wincmd w'
  let lnum = (a:0 ? a:1 : line('$'))
  call setline(lnum, getline(lnum) . a:str)
  setlocal nomodified
  execute save_winnr 'wincmd w'
  return lnum
endfunction
call s:TestResults.define('append', function(s:sid . 'TestResults_append'))

function! s:TestResults_flush() dict
  for err in self.buffer
    if err.is_a(s:Failure)
      let self.stats.n_failures = err.id
      call self.print_failure(err)
    elseif err.is_a(s:Error)
      let self.stats.n_errors = err.id
      call self.print_error(err)
    endif
  endfor
  call self.puts()
  let self.buffer = []
endfunction
call s:TestResults.define('flush', function(s:sid . 'TestResults_flush'))

function! s:TestResults_print_separator(ch) dict
  let winw = winwidth(bufwinnr(s:results_bufnr))
  let seplen = min([80, winw]) - 2
  call self.puts(substitute(printf('%*s', seplen, ''), ' ', a:ch, 'g'))
endfunction
call s:TestResults.define('print_separator', function(s:sid . 'TestResults_print_separator'))

function! s:TestResults_print_header(level, title) dict
  if a:level == 1
    call self.print_separator('=')
  elseif a:level == 2
    call self.print_separator('-')
  endif
  call self.puts(toupper(a:title))
endfunction
call s:TestResults.define('print_header', function(s:sid . 'TestResults_print_header'))

function! s:TestResults_print_failure(fail) dict
  call self.puts()
  let idx = printf('%3d) ', a:fail.id)
  let head = idx . "Failure: " . a:fail.test . ": " . a:fail.assert
  if a:fail.hint != ""
    let head .= ": " . a:fail.hint
  endif
  call self.puts(head)
  call self.puts(split(a:fail.reason, "\n"))
endfunction
call s:TestResults.define('print_failure', function(s:sid . 'TestResults_print_failure'))

function! s:TestResults_print_error(err) dict
  call self.puts()
  let idx = printf('%3d) ', a:err.id)
  call self.puts(idx . "Error: " . a:err.throwpoint)
  call self.puts(a:err.exception)
endfunction
call s:TestResults.define('print_error', function(s:sid . 'TestResults_print_error'))

function! s:TestResults_print_stats() dict
  call self.print_separator('-')
  let stats = self.stats
  call self.puts(stats.n_tests . " tests, " . stats.n_assertions . " assertions, " .
        \ stats.n_failures . " failures, " . stats.n_errors . " errors")
  call self.puts()
endfunction
call s:TestResults.define('print_stats', function(s:sid . 'TestResults_print_stats'))

"-----------------------------------------------------------------------------
" Failure

let s:Failure = unittest#oop#class#new('Failure')
let s:Failure.id = 1

function! s:Failure_initialize(reason, hint) dict
  let self.id = s:Failure.id | let s:Failure.id += 1
  let self.testcase = s:test_runner.context.testcase
  let self.test = s:test_runner.context.test
  let self.failpoint = expand('<sfile>')
  let self.assert = matchstr(self.failpoint, '\.\.\zsassert#\w\+\ze\.\.')
  let self.reason = a:reason
  let self.hint = (type(a:hint) == type("") ? a:hint : string(a:hint))
endfunction
call s:Failure.define('initialize', function(s:sid . 'Failure_initialize'))

"-----------------------------------------------------------------------------
" Error

let s:Error = unittest#oop#class#new('Error')
let s:Error.id = 1

function! s:Error_initialize() dict
  let self.id = s:Error.id | let s:Error.id += 1
  let self.testcase = s:test_runner.context.testcase
  let self.test = s:test_runner.context.test
  let self.throwpoint = v:throwpoint
  let self.exception = v:exception
  let s:Error.id += 1
endfunction
call s:Error.define('initialize', function(s:sid . 'Error_initialize'))

" vim: filetype=vim
