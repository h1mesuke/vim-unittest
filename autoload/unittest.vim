"=============================================================================
" File    : unittest.vim
" Require : assert.vim
" Author  : h1mesuke
" Updated : 2010-11-05
" Version : 0.1.3
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
  let obj.results = s:TestResults.new()
  return obj
endfunction

function! s:TestRunner.add_testcase(tc)
  call add(self.testcases, a:tc)
endfunction

function! s:TestRunner.run()
  call self.results.open_window()
  let saved_pos = getpos(".")
  for tc in self.testcases
    let self.context.testcase = tc
    call self.results.print_header(1, tc.name)
    call self.results.puts()
    for test in tc.tests()
      let self.context.test = test
      call self.results.count_test()
      call self.results.print_header(2, test)
      call self.results.append(" => ")
      try
        call tc[test]()
      catch
        call self.results.add_error()
      endtry
      call self.results.flush()
    endfor
  endfor
  call self.results.print_stats()
  call setpos(".", saved_pos)
endfunction

"-----------------------------------------------------------------------------
" TestCase

let s:TestCase = {}

function! s:TestCase.new(path)
  let obj = copy(self)
  let obj.class = s:TestCase
  let obj.path = a:path
  let obj.name = substitute(split(a:path, '/')[-1], '\.\w\+$', '', '')
  return obj
endfunction

function! s:TestCase.tests()
  return sort(filter(keys(self), 'v:val =~# "^test_"'))
endfunction

"-----------------------------------------------------------------------------
" TestResults

let s:TestResults = {}

function! s:TestResults.new()
  let obj = copy(self)
  let obj.class = s:TestResults
  let obj.n_tests = 0
  let obj.n_asserts = 0
  let obj.failures = []
  let obj.errors = []
  let obj.buffer = []
  return obj
endfunction

function! s:TestResults.open_window()
  let sp = ''
  if !exists('s:bufnr') || !bufexists(s:bufnr)
    " the buffer doesn't exist
    execute sp 'split'
    edit `='[unittest results]'`
    let s:bufnr = bufnr('%')
    nnoremap <buffer> q <C-w>c
    setlocal bufhidden=hide buftype=nofile noswapfile nobuflisted
    setlocal filetype=unittest
  elseif bufwinnr(s:bufnr) != -1
    " the buffer exists, but it has no window
    execute bufwinnr(s:bufnr) 'wincmd w'
    %delete _
  else
    " the buffer and its window exist
    execute sp 'split'
    execute 'buffer' s:bufnr
    %delete _
  endif
endfunction

function! s:TestResults.count_test()
  let self.n_tests += 1
endfunction

function! s:TestResults.count_assertion()
  let self.n_asserts += 1
endfunction

function! s:TestResults.add_success()
  call self.append(".")
endfunction

function! s:TestResults.add_failure(assert, reason, hint)
  let fail = s:Failure.new(a:assert, a:reason, a:hint)
  call add(self.failures, fail)
  call add(self.buffer, fail)
  call self.append("F")
endfunction

function! s:TestResults.add_error()
  let err = s:Error.new()
  call add(self.errors, err)
  call add(self.buffer, err)
  call self.append("E")
endfunction

function! s:TestResults.puts(...)
  execute bufwinnr(s:bufnr) 'wincmd w'
  let args = (a:0 ? a:000 : [""])
  for str in args
    call append('$', str)
  endfor
  setlocal nomodified
endfunction

function! s:TestResults.append(str)
  execute bufwinnr(s:bufnr) 'wincmd w'
  call setline('$', getline('$') . a:str)
  setlocal nomodified
endfunction

function! s:TestResults.flush()
  for err in self.buffer
    if err.class is s:Failure
      call self.print_failure(err)
    elseif err.class is s:Error
      call self.print_error(err)
    endif
  endfor
  call self.puts()
  let self.buffer = []
endfunction

function! s:TestResults.print_separator(ch)
  let winw = winwidth(bufwinnr(s:bufnr))
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
  call self.puts("Failure: " . a:fail.test . ": " . a:fail.assert)
  call self.puts(split(a:fail.reason, "\n"))
endfunction

function! s:TestResults.print_error(err)
  call self.puts()
  call self.puts("Error: " . a:err.throwpoint)
  call self.puts(a:err.exception)
endfunction

function! s:TestResults.print_stats()
  call self.print_separator('-')
  let n_fails = len(self.failures)
  let n_errs  = len(self.errors)
  call self.puts(self.n_tests . " tests, " . self.n_asserts . " assertions, " .
        \ n_fails . " failures, " . n_errs . " errors")
  call self.puts()
endfunction

let s:Failure = {}

function! s:Failure.new(assert, reason, hint)
  let obj = copy(self)
  let obj.class = s:Failure
  let obj.testcase = s:test_runner.context.testcase
  let obj.test = s:test_runner.context.test
  let obj.assert = a:assert
  let obj.reason = a:reason
  let obj.hint = a:hint
  return obj
endfunction

let s:Error = {}

function! s:Error.new()
  let obj = copy(self)
  let obj.class = s:Error
  let obj.testcase = s:test_runner.context.testcase
  let obj.test = s:test_runner.context.test
  let obj.throwpoint = v:throwpoint
  let obj.exception = v:exception
  return obj
endfunction

" vim: filetype=vim
