"=============================================================================
" Simple Unit Testing Framework for Vim scripts
"
" File    : autoload/unittest/testcase.vim
" Author	: h1mesuke <himesuke@gmail.com>
" Updated : 2011-01-22
" Version : 0.2.6
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

function! unittest#testcase#new(tc_name)
  if !unittest#is_running()
    call unittest#print_error(
          \ "unittest: don't source the testcase directly, use :UnitTest command")
    return {}
  endif
  let tc = s:TestCase.new(a:tc_name)
  call unittest#runner().add_testcase(tc)
  return tc
endfunction

function! s:SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:sid = s:SID()

let s:TestCase = unittest#oop#class#new('TestCase')

function! s:TestCase_initialize(tc_name) dict
  let self.name = a:tc_name
  let self.context_file = ""
  let self.cache = {}
endfunction
call s:TestCase.bind(s:sid, 'initialize')

function! s:TestCase_tests() dict
  if !has_key(self.cache, 'tests')
    let tests = s:grep(keys(self), '^\(\(setup\|teardown\)_\)\@!')
    let tests = s:grep(tests, '\(^test\|\(^\|[^_]_\)should\)_')
    let self.cache.tests = sort(tests)
  endif
  return self.cache.tests
endfunction
call s:TestCase.bind(s:sid, 'tests')

function! s:TestCase_open_context_file() dict
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
call s:TestCase.bind(s:sid, 'open_context_file')

function! s:TestCase___setup__(test) dict
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
call s:TestCase.bind(s:sid, '__setup__')

function! s:TestCase___teardown__(test) dict
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
call s:TestCase.bind(s:sid, '__teardown__')

function! s:TestCase_puts(...) dict
  let str = (a:0 ? a:1 : "")
  call unittest#runner().results.puts(str)
endfunction
call s:TestCase.bind(s:sid, 'puts')

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

" vim: filetype=vim
