"=============================================================================
" File    : autoload/unittest.vim
" Author	: h1mesuke <himesuke@gmail.com>
" Updated : 2010-12-29
" Version : 0.2.1
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

function! unittest#results()
  if !unittest#is_running()
    call s:print_error("unittest: no test is running")
    return {}
  endif
  return s:test_runner.results
endfunction

function! unittest#testcase(tc_path)
  if !unittest#is_running()
    " NOTE: The testcase may be sourced by the user unexpectedlly. Return
    " a dummy Dictionary to suppress too many errors.
    return {}
  endif
  let tc = s:TestCase.new(a:tc_path)
  call s:test_runner.add_testcase(tc)
  return tc
endfunction

function! unittest#is_running()
  return exists('s:test_runner')
endfunction

function! s:print_error(msg)
  echohl ErrorMsg
  echomsg a:msg
  echohl None
endfunction

"-----------------------------------------------------------------------------
" TestRunner

let s:TestRunner = unittest#object#extend()

function! s:TestRunner.initialize(test_filters)
  let self.testcases = []
  let self.test_filters = a:test_filters
  let self.context = {}
  let self.results = s:TestResults.new(self)
endfunction

function! s:TestRunner.add_testcase(tc)
  call add(self.testcases, a:tc)
endfunction

function! s:TestRunner.run()
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

function! s:TestRunner._filter_tests(tests)
  let tests = copy(a:tests)
  if self.test_filters.g_pattern != ""
    call filter(tests, 'v:val =~# self.test_filters.g_pattern')
  endif
  if self.test_filters.v_pattern != ""
    call filter(tests, 'v:val !~# self.test_filters.v_pattern')
  endif
  return tests
endfunction

"-----------------------------------------------------------------------------
" TestCase

let s:TestCase = unittest#object#extend()

function! s:TestCase.initialize(path)
  let self.path = a:path
  let self.name = substitute(split(a:path, '/')[-1], '\.\w\+$', '', '')
  let self.context_file = ""
  let self.cache = {}
endfunction

function! s:TestCase.tests()
  if !has_key(self.cache, 'tests')
    let tests = s:grep(keys(self), '^\(\(setup\|teardown\)_\)\@!')
    let tests = s:grep(tests, '\(^test\|\(^\|[^_]_\)should\)_')
    let self.cache.tests = sort(tests)
  endif
  return self.cache.tests
endfunction

function! s:TestCase.open_context_file()
  if !bufexists(self.context_file)
    " the buffer doesn't exist
    split
    edit `=self.context_file`
  elseif bufwinnr(self.context_file) != -1
    " the buffer exists, and it has a window
    execute bufwinnr(self.context_file) 'wincmd w'
  else
    " the buffer exists, but it has no window
    split
    execute 'buffer' bufnr(self.context_file)
  endif
endfunction

function! s:TestCase.__setup__(test)
  if has_key(self, 'setup')
    call self.setup()
  endif
  if !has_key(self.cache, 'setup_suffixes')
    let setups = sort(s:grep(keys(self), '^setup_'), 's:compare_strlen')
    let self.cache.setup_suffixes = s:map_matchstr(setups, '^setup_\zs.*$')
  endif
  for suffix in self.cache.setup_suffixes
    if a:test =~# suffix
      call self['setup_'.suffix]()
    endif
  endfor
endfunction

function! s:TestCase.__teardown__(test)
  if !has_key(self.cache, 'teardown_suffixes')
    let teardowns = reverse(sort(s:grep(keys(self), '^teardown_'), 's:compare_strlen'))
    let self.cache.teardown_suffixes = s:map_matchstr(teardowns, '^teardown_\zs.*$')
  endif
  for suffix in self.cache.teardown_suffixes
    if a:test =~# suffix
      call self['teardown_'.suffix]()
    endif
  endfor
  if has_key(self, 'teardown')
    call self.teardown()
  endif
endfunction

function! s:TestCase.puts(...)
  let str = (a:0 ? a:1 : "")
  call s:test_runner.results.puts(str)
endfunction

function! s:grep(list, pat, ...)
  let op = (a:0 ? a:1 : '=~#')
  return filter(a:list, 'v:val ' . op . " '" . a:pat . "'")
endfunction

function! s:map_matchstr(list, pat)
  return map(a:list, 'matchstr(v:val, ' . "'" . a:pat . "')")
endfunction

function! s:compare_strlen(str1, str2)
  let len1 = strlen(a:str1)
  let len2 = strlen(a:str2)
  return len1 == len2 ? 0 : len1 > len2 ? 1 : -1
endfunction

"-----------------------------------------------------------------------------
" TestResults

let s:TestResults = unittest#object#extend()

function! s:TestResults.initialize(runner)
  let self.context = a:runner.context
  let self.stats = {
        \ 'n_tests'     : 0,
        \ 'n_assertions': 0,
        \ 'n_failures'  : 0,
        \ 'n_errors'    : 0,
        \ }
  let self.buffer = []
endfunction

function! s:TestResults.open_window()
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

function! s:TestResults.focus_window()
  execute bufwinnr(s:results_bufnr) 'wincmd w'
endfunction

function! s:TestResults._init_results_buffer()
  nnoremap <buffer> q <C-w>c
  setlocal bufhidden=hide buftype=nofile noswapfile nobuflisted
  setlocal filetype=unittest
  silent! %delete _
endfunction

function! s:TestResults.count_test()
  let self.stats.n_tests += 1
endfunction

function! s:TestResults.count_assertion()
  let self.stats.n_assertions += 1
endfunction

function! s:TestResults.add_success()
  call self.append(".", self.context.test_header_lnum)
endfunction

function! s:TestResults.add_failure(reason, hint)
  let fail = s:Failure.new(a:reason, a:hint)
  call add(self.buffer, fail)
  call self.append("F", self.context.test_header_lnum)
endfunction

function! s:TestResults.add_error()
  let err = s:Error.new()
  call add(self.buffer, err)
  call self.append("E", self.context.test_header_lnum)
endfunction

function! s:TestResults.puts(...)
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

function! s:TestResults.append(str, ...)
  let save_winnr =  bufwinnr('%')
  execute bufwinnr(s:results_bufnr) 'wincmd w'
  let lnum = (a:0 ? a:1 : line('$'))
  call setline(lnum, getline(lnum) . a:str)
  setlocal nomodified
  execute save_winnr 'wincmd w'
  return lnum
endfunction

function! s:TestResults.flush()
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

function! s:TestResults.print_separator(ch)
  let winw = winwidth(bufwinnr(s:results_bufnr))
  let seplen = min([80, winw]) - 2
  call self.puts(substitute(printf('%*s', seplen, ''), ' ', a:ch, 'g'))
endfunction

function! s:TestResults.print_header(level, title)
  if a:level == 1
    call self.print_separator('=')
  elseif a:level == 2
    call self.print_separator('-')
  endif
  call self.puts(toupper(a:title))
endfunction

function! s:TestResults.print_failure(fail)
  call self.puts()
  let idx = printf('%3d) ', a:fail.id)
  let head = idx . "Failure: " . a:fail.test . ": " . a:fail.assert
  if a:fail.hint != ""
    let head .= ": " . a:fail.hint
  endif
  call self.puts(head)
  call self.puts(split(a:fail.reason, "\n"))
endfunction

function! s:TestResults.print_error(err)
  call self.puts()
  let idx = printf('%3d) ', a:err.id)
  call self.puts(idx . "Error: " . a:err.throwpoint)
  call self.puts(a:err.exception)
endfunction

function! s:TestResults.print_stats()
  call self.print_separator('-')
  let stats = self.stats
  call self.puts(stats.n_tests . " tests, " . stats.n_assertions . " assertions, " .
        \ stats.n_failures . " failures, " . stats.n_errors . " errors")
  call self.puts()
endfunction

"-----------------------------------------------------------------------------
" Failure

let s:Failure = unittest#object#extend()
let s:Failure.id = 1

function! s:Failure.initialize(reason, hint)
  let self.testcase = s:test_runner.context.testcase
  let self.test = s:test_runner.context.test
  let self.failpoint = expand('<sfile>')
  let self.assert = matchstr(self.failpoint, '\.\.\zsassert#\w\+\ze\.\.')
  let self.reason = a:reason
  let self.hint = (type(a:hint) == type("") ? a:hint : string(a:hint))
  let s:Failure.id += 1
endfunction

"-----------------------------------------------------------------------------
" Error

let s:Error = unittest#object#extend()
let s:Error.id = 1

function! s:Error.initialize()
  let self.testcase = s:test_runner.context.testcase
  let self.test = s:test_runner.context.test
  let self.throwpoint = v:throwpoint
  let self.exception = v:exception
  let s:Error.id += 1
endfunction

" vim: filetype=vim
