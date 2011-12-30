"=============================================================================
" Simple Unit Testing Framework for Vim script
"
" File    : autoload/unittest/testcase.vim
" Author	: h1mesuke <himesuke@gmail.com>
" Updated : 2011-12-31
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

"-----------------------------------------------------------------------------
" TestCase

let s:TestCase = unittest#oop#class#new('TestCase', s:SID)
call s:TestCase.include(unittest#assertions#module())

function! s:TestCase_initialize(name, ...) dict
  if !unittest#is_running()
    call unittest#print_error(
          \ "unittest: Don't source a testcase directly, please use :UnitTest command.")
  else
    let self.name = a:name
    let self.__context__ = s:Context.new(a:0 ? a:1 : {})
    let self.__private__ = {}
    let runner = unittest#runner()
    call runner.add_testcase(self)
  endif
endfunction
call s:TestCase.method('initialize')

function! s:TestCase___setup_all__() dict
  let funcs = s:funcs(self)
  let tests = s:grep(funcs, '\%(^test\|\%(^\|[^_]_\)should\)_')
  let tests = s:grep(tests, '^\%(\%(assert\|setup\|teardown\)_\)\@!')
  let self.__private__.tests = sort(tests)

  let setups = sort(s:grep(funcs, '^setup_'), 's:compare_strlen')
  let self.__private__.setup_suffixes = s:map_matchstr(setups, '^setup_\zs.*$')

  let teardowns = reverse(sort(s:grep(funcs, '^teardown_'), 's:compare_strlen'))
  let self.__private__.teardown_suffixes = s:map_matchstr(teardowns, '^teardown_\zs.*$')

  if has_key(self.__context__, 'data')
    call self.__open_context_window__()
  endif
  if has_key(self, 'Setup')
    call self.Setup()
  endif
endfunction
call s:TestCase.method('__setup_all__')

function! s:funcs(obj)
  return filter(keys(a:obj), 'type(a:obj[v:val]) == type(function("tr"))')
endfunction

function! s:grep(list, pat)
  return filter(copy(a:list), 'match(v:val, a:pat) != -1')
endfunction

function! s:map_matchstr(list, pat)
  return map(copy(a:list), 'matchstr(v:val, a:pat)')
endfunction

function! s:compare_strlen(str1, str2)
  let len1 = strlen(a:str1)
  let len2 = strlen(a:str2)
  return (len1 == len2 ? 0 : (len1 > len2 ? 1 : -1))
endfunction

function! s:TestCase___tests__() dict
  return self.__private__.tests
endfunction
call s:TestCase.method('__tests__')

function! s:TestCase___open_context_window__() dict
  let context_file = s:escape_file_pattern(self.__context__.data)
  if !bufexists(context_file)
    " The buffer doesn't exist.
    split
    edit `=self.__context__.data`
  elseif bufwinnr(context_file) != -1
    " The buffer exists, and it has a window.
    execute bufwinnr(context_file) 'wincmd w'
  else
    " The buffer exists, but it has no window.
    split
    execute 'buffer' bufnr(context_file)
  endif
endfunction
call s:TestCase.method('__open_context_window__')

function! s:TestCase___teardown_all__() dict
  if has_key(self, 'Teardown')
    call self.Teardown()
  endif
  if has_key(self.__context__, 'data')
    call self.__close_context_window__()
  endif
endfunction
call s:TestCase.method('__teardown_all__')

function! s:TestCase___close_context_window__() dict
  let context_file = s:escape_file_pattern(self.__context__.data)
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
  for suffix in self.__private__.setup_suffixes
    if a:test =~# suffix
      call call(self['setup_' . suffix], [], self)
    endif
  endfor
endfunction
call s:TestCase.method('__setup__')

function! s:TestCase___teardown__(test) dict
  for suffix in self.__private__.teardown_suffixes
    if a:test =~# suffix
      call call(self['teardown_' . suffix], [], self)
    endif
  endfor
  if has_key(self, 'teardown')
    call self.teardown()
  endif
  call self.__context__.revert()
endfunction
call s:TestCase.method('__teardown__')

function! s:TestCase_call(...) dict
  return call(self.__context__.call, a:000, self.__context__)
endfunction
call s:TestCase.method('call')

function! s:TestCase_exists(...) dict
  return call(self.__context__.exists, a:000, self.__context__)
endfunction
call s:TestCase.method('exists')

function! s:TestCase_get(...) dict
  return call(self.__context__.get, a:000, self.__context__)
endfunction
call s:TestCase.method('get')

function! s:TestCase_set(...) dict
  call call(self.__context__.set, a:000, self.__context__)
endfunction
call s:TestCase.method('set')

function! s:TestCase_puts(...) dict
  let runner = unittest#runner()
  call call(runner.out.puts, a:000, runner.out)
endfunction
call s:TestCase.method('puts')

"-----------------------------------------------------------------------------
" Context

let s:Context = unittest#oop#class#new('Context', s:SID)

function! s:Context_initialize(context) dict
  call extend(self, a:context, 'keep')
  if has_key(a:context, 'sid')
    call self.set_sid(a:context.sid)
  endif
  let self.saved = {}
  let self.defined = {}
endfunction
call s:Context.method('initialize')

function! s:Context_set_sid(sid) dict
  if type(a:sid) == type(0)
    let self.sid = '<SNR>' . a:sid . '_'
  else
    let self.sid = '<SNR>' . matchstr(a:sid, '\d\+') . '_'
  endif
endfunction
call s:Context.method('set_sid')

function! s:Context_call(func, args) dict
  if a:func =~ '^s:'
    if !has_key(self, 'sid')
      throw "InvalidContextAccess: Context SID is not given."
    endif
    let func = substitute(a:func, '^s:', self.sid, '')
  else
    let func = a:func
  endif
  return call(func, a:args)
endfunction
call s:Context.method('call')

function! s:Context_exists(name) dict
  if a:name =~ '^[bwtgs]:'
    let scope = self.get_scope_for(a:name)
    let name = substitute(a:name, '^\w:', '', '')
    return has_key(scope, name)
  else
    execute 'let value = exists(' . a:name . ')'
    return value
  endif
endfunction
call s:Context.method('exists')

function! s:Context_get(name, ...) dict
  if a:name =~ '^[bwtgs]:'
    let scope = self.get_scope_for(a:name)
    let name = substitute(a:name, '^\w:', '', '')
    return get(scope, name, (a:0 ? a:1 : 0))
  elseif a:name =~ '^&\%([lg]:\)\='
    execute 'let value = ' . a:name
    return value
  endif
endfunction
call s:Context.method('get')

function! s:Context_set(name, value, ...) dict
  let should_save = (a:0 ? a:1 : 1)
  if a:name =~ '^[bwtgs]:'
    let scope = self.get_scope_for(a:name)
    let name = substitute(a:name, '^\w:', '', '')
    if should_save && !has_key(self.saved, a:name)
      if has_key(scope, name)
        let self.saved[a:name] = scope[name]
      else
        let self.saved[a:name] = a:value
        let self.defined[a:name] = 1
      endif
    endif
    let scope[name] = a:value
  elseif a:name =~ '^&\%([lg]:\)\='
    if should_save && !has_key(self.saved, a:name)
      execute 'let self.saved[a:name] = ' . a:name
    endif
    execute 'let ' . a:name . ' = a:value'
  endif
endfunction
call s:Context.method('set')

function! s:Context_get_scope_for(name) dict
  if a:name =~# '^b:'
    if !has_key(self, 'data')
      throw "InvalidContextAccess: Context data is not given."
    endif
    let scope = b:
  elseif a:name =~# '^s:'
    if !has_key(self, 'scope')
      throw "InvalidContextAccess: Context scope is not given."
    endif
    let scope = self.scope
  elseif a:name =~# '^[wtg]:'
    execute 'let scope = ' . matchstr(a:name, '^\w:')
  endif
  return scope
endfunction
call s:Context.method('get_scope_for')

function! s:Context_revert() dict
  if empty(self.saved)
    return
  endif
  for [name, value] in items(self.saved)
    if has_key(self.defined, name)
      let scope = self.get_scope_for(name)
      let name = substitute(name, '^\w:', '', '')
      unlet scope[name]
    else
      call self.set(name, value, 0)
    endif
  endfor
  let self.saved = {}
  let self.defined = {}
endfunction
call s:Context.method('revert')

" vim: filetype=vim
