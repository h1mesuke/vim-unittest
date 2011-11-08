"=============================================================================
" Simple Unit Testing Framework for Vim script
"
" File    : autoload/unittest/testcase.vim
" Author	: h1mesuke <himesuke@gmail.com>
" Updated : 2011-11-08
" Version : 0.3.2
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

function! unittest#testcase#class()
  return s:TestCase
endfunction

function! unittest#testcase#new(...)
  return call(s:TestCase.new, a:000, s:TestCase)
endfunction

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

let s:TestCase = unittest#oop#class#new('TestCase', s:SID)
call s:TestCase.include(unittest#assertions#module())

function! s:TestCase_initialize(name) dict
  if !unittest#is_running()
    call unittest#print_error(
          \ "unittest: Don't source a testcase directly, please use :UnitTest command.")
  else
    let self.name = a:name
    let self.context_file = ""
    let self.__cache__ = {}
    let runner = unittest#runner()
    call runner.add_testcase(self)
  endif
endfunction
call s:TestCase.method('initialize')

function! s:TestCase_tests() dict
  if !has_key(self.__cache__, 'tests')
    let tests = s:grep(keys(self), '^\(\(setup\|teardown\)_\)\@!')
    let tests = s:grep(tests, '\(^test\|\(^\|[^_]_\)should\)_')
    let self.__cache__.tests = sort(tests)
  endif
  return self.__cache__.tests
endfunction
call s:TestCase.method('tests')

function! s:TestCase___initialize__() dict
  if !empty(self.context_file)
    call self.__open_context_window__()
  endif
endfunction
call s:TestCase.method('__initialize__')

function! s:TestCase___open_context_window__() dict
  let context_file = s:escape_file_pattern(self.context_file)
  if !bufexists(context_file)
    " the buffer doesn't exist
    split
    edit `=context_file`
  elseif bufwinnr(context_file) != -1
    " the buffer exists, and it has a window
    execute bufwinnr(context_file) 'wincmd w'
  else
    " the buffer exists, but it has no window
    split
    execute 'buffer' bufnr(context_file)
  endif
endfunction
call s:TestCase.method('__open_context_window__')

function! s:TestCase___finalize__() dict
  if !empty(self.context_file)
    call self.__close_context_window__()
  endif
endfunction
call s:TestCase.method('__finalize__')

function! s:TestCase___close_context_window__() dict
  let context_file = s:escape_file_pattern(self.context_file)
  if bufwinnr(context_file) != -1
    execute bufwinnr(context_file) 'wincmd c'
  endif
endfunction
call s:TestCase.method('__close_context_window__')

function! s:escape_file_pattern(path)
  return escape(a:path, '*[]?{},')
endfunction

function! s:TestCase___setup__(test) dict
  if has_key(self, 'setup')
    call self.setup()
  endif
  if !has_key(self.__cache__, 'setup_suffixes')
    let setups = sort(s:grep(keys(self), '^setup_'), 's:compare_strlen')
    let self.__cache__.setup_suffixes = s:map_matchstr(setups, '^setup_\zs.*$')
  endif
  for suffix in self.__cache__.setup_suffixes
    if a:test =~# suffix
      call call(self['setup_' . suffix], [], self)
    endif
  endfor
endfunction
call s:TestCase.method('__setup__')

function! s:TestCase___teardown__(test) dict
  if !has_key(self.__cache__, 'teardown_suffixes')
    let teardowns = reverse(sort(s:grep(keys(self), '^teardown_'), 's:compare_strlen'))
    let self.__cache__.teardown_suffixes = s:map_matchstr(teardowns, '^teardown_\zs.*$')
  endif
  for suffix in self.__cache__.teardown_suffixes
    if a:test =~# suffix
      call call(self['teardown_' . suffix], [], self)
    endif
  endfor
  if has_key(self, 'teardown')
    call self.teardown()
  endif
endfunction
call s:TestCase.method('__teardown__')

function! s:TestCase_puts(...) dict
  let str = (a:0 ? a:1 : "")
  let runner = unittest#runner()
  call runner.out.puts(str)
endfunction
call s:TestCase.method('puts')

function! s:grep(list, pat, ...)
  let op = (a:0 ? a:1 : '=~#')
  return filter(a:list, 'v:val ' . op . ' a:pat')
endfunction

function! s:map_matchstr(list, pat)
  return map(a:list, 'matchstr(v:val, a:pat)')
endfunction

function! s:compare_strlen(str1, str2)
  let len1 = strlen(a:str1)
  let len2 = strlen(a:str2)
  return len1 == len2 ? 0 : len1 > len2 ? 1 : -1
endfunction

" vim: filetype=vim
