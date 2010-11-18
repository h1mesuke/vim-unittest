"=============================================================================
" File    : autoload/unittest.vim
" Author  : h1mesuke
" Updated : 2010-11-19
" Version : 0.1.4
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

function! unittest#results()
  return s:test_runner.results
endfunction

function! unittest#testcase(tc_path)
  if !exists('s:test_runner')
    " sourced by the user, not the test runner, so retuun a dummy
    return {}
  endif
  let tc = s:TestCase.new(a:tc_path)
  call s:test_runner.add_testcase(tc)
  return tc
endfunction

"-----------------------------------------------------------------------------
" TestRunner

let s:TestRunner = {}

function! s:TestRunner.new()
  let obj = copy(self)
  let obj.class = s:TestRunner
  let obj.testcases = []
  let obj.context = {}
  let obj.results = s:TestResults.new(obj)
  return obj
endfunction

function! s:TestRunner.add_testcase(tc)
  call add(self.testcases, a:tc)
endfunction

function! s:TestRunner.run()
  if has("reltime")
    let start_time = reltime()
  endif
  let s:Failure.id = 0 | let s:Error.id = 0
  call self.results.open_window()
  for tc in self.testcases
    let self.context.testcase = tc
    call self.results.print_header(1, tc.name)
    call self.results.puts()
    if tc.context_file != ""
      call tc.open_context_file()
    endif
    for test in tc.tests()
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

"-----------------------------------------------------------------------------
" TestCase

let s:TestCase = {}

function! s:TestCase.new(path)
  let obj = copy(self)
  let obj.class = s:TestCase
  let obj.path = a:path
  let obj.name = substitute(split(a:path, '/')[-1], '\.\w\+$', '', '')
  let obj.context_file = ""
  let obj.cache = {}
  return obj
endfunction

function! s:TestCase.tests()
  if !has_key(self.cache, 'tests')
    let self.cache.tests = sort(s:grep(keys(self), '^test_'))
  endif
  return self.cache.tests
endfunction

function! s:TestCase.open_context_file()
  if !bufexists(self.context_file)
    " the buffer doesn't exist
    split
    edit `self.context_file`
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
  if !has_key(self.cache, 'setup_prefixes')
    let setups = sort(s:grep(keys(self), '^setup_'), 's:compare_strlen')
    let self.cache.setup_prefixes = s:map_matchstr(setups, 'setup_\zs.*$')
  endif
  for prefix in self.cache.setup_prefixes
    if a:test =~# '^test_'.prefix
      call self['setup_'.prefix]()
    endif
  endfor
endfunction

function! s:TestCase.__teardown__(test)
  if !has_key(self.cache, 'teardown_prefixes')
    let teardowns = reverse(sort(s:grep(keys(self), '^teardown_'), 's:compare_strlen'))
    let self.cache.teardown_prefixes = s:map_matchstr(teardowns, 'teardown_\zs.*$')
  endif
  for prefix in self.cache.teardown_prefixes
    if a:test =~# '^test_'.prefix
      call self['teardown_'.prefix]()
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

let s:TestResults = {}

function! s:TestResults.new(runner)
  let obj = copy(self)
  let obj.class = s:TestResults
  let obj.context = a:runner.context
  let obj.n_tests = 0    | let obj.n_assertions = 0
  let obj.n_failures = 0 | let obj.n_errors = 0
  let obj.buffer = []
  return obj
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
  call s:init_results_buffer()
endfunction

function! s:TestResults.focus_window()
  execute bufwinnr(s:results_bufnr) 'wincmd w'
endfunction

function! s:init_results_buffer()
  nnoremap <buffer> q <C-w>c
  setlocal bufhidden=hide buftype=nofile noswapfile nobuflisted
  setlocal filetype=unittest
  silent! %delete _
endfunction

function! s:TestResults.count_test()
  let self.n_tests += 1
endfunction

function! s:TestResults.count_assertion()
  let self.n_assertions += 1
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
  let saved_winnr =  bufwinnr('%')
  execute bufwinnr(s:results_bufnr) 'wincmd w'
  let str = (a:0 ? a:1 : "")
  call append('$', str)
  normal! G
  setlocal nomodified
  execute saved_winnr 'wincmd w'
endfunction

function! s:TestResults.append(str, ...)
  let saved_winnr =  bufwinnr('%')
  execute bufwinnr(s:results_bufnr) 'wincmd w'
  let lnum = (a:0 ? a:1 : line('$'))
  call setline(lnum, getline(lnum) . a:str)
  setlocal nomodified
  execute saved_winnr 'wincmd w'
  return lnum
endfunction

function! s:TestResults.flush()
  for err in self.buffer
    if err.class is s:Failure
      let self.n_failures = err.id
      call self.print_failure(err)
    elseif err.class is s:Error
      let self.n_errors = err.id
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
  call self.puts(self.n_tests . " tests, " . self.n_assertions . " assertions, " .
        \ self.n_failures . " failures, " . self.n_errors . " errors")
  call self.puts()
endfunction

let s:Failure = { 'id': 0 }

function! s:Failure.new(reason, hint)
  let self.id += 1
  let obj = copy(self)
  let obj.class = s:Failure
  let obj.testcase = s:test_runner.context.testcase
  let obj.test = s:test_runner.context.test
  let obj.failpoint = expand('<sfile>')
  let obj.assert = matchstr(obj.failpoint, '\.\.\zsassert#\w\+\ze\.\.')
  let obj.reason = a:reason
  let obj.hint = string(a:hint)
  return obj
endfunction

let s:Error = { 'id': 0 }

function! s:Error.new()
  let self.id += 1
  let obj = copy(self)
  let obj.class = s:Error
  let obj.testcase = s:test_runner.context.testcase
  let obj.test = s:test_runner.context.test
  let obj.throwpoint = v:throwpoint
  let obj.exception = v:exception
  return obj
endfunction

" vim: filetype=vim
