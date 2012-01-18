"=============================================================================
" vim-oop
" OOP Support for Vim script
"
" File    : oop/module.vim
" Author  : h1mesuke <himesuke+vim@gmail.com>
" Updated : 2012-01-19
" Version : 0.2.4
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

let s:save_cpo = &cpo
set cpo&vim

let s:TYPE_NUM  = type(0)
let s:TYPE_FUNC = type(function('tr'))

"-----------------------------------------------------------------------------
" Module

" NOTE: Omit type checking for efficiency.
function! unittest#oop#module#get(name)
  let ns = unittest#oop#__namespace__()
  return ns[a:name]
endfunction

" unittest#oop#module#new( {name}, {sid})
"
" Creates a new module. The second argument must be the SID number or prefix
" of the script where the module is defined.
"
"   function! s:get_SID()
"     return matchstr(expand('<sfile>'), '<SNR>\d\+_')
"   endfunction
"   let s:SID = s:get_SID()
"   delfunction s:get_SID
"
"   s:Fizz = unittest#oop#module#new('Fizz', s:SID)
"
function! unittest#oop#module#new(name, sid)
  let ns = unittest#oop#__namespace__()
  if has_key(ns, a:name)
    throw "vim-oop: Name conflict: " . a:name
  endif
  let module = copy(s:Module)
  let module.name = a:name
  let sid = (type(a:sid) == s:TYPE_NUM ? a:sid : matchstr(a:sid, '\d\+'))
  let module.__sid_prefix__ = printf('<SNR>%d_%s_', sid, a:name)
  "=> <SNR>10_Fizz_
  let module.__funcs__ = []
  let ns[a:name] = module
  return module
endfunction

"-----------------------------------------------------------------------------

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

let s:Module = { '__vim_oop__': 1 }

" Binds function {func_name} to a module Dictionary as a module function.
"
" The name of the function to be bound must be prefixed by the module name
" followed by one underscore. This convention helps you to distinguish module
" functions from other functions.
"
"   function! s:Fizz_hello() dict
"   endfunction
"   call s:Fizz.function('hello')
"
" Note that however the names of module functions themselves don't include the
" prefix.
"
"   call s:Fizz.hello()
"
function! s:Module_bind(func_name, ...) dict
  let func_name = (a:0 ? a:1 : a:func_name)
  let self[func_name] = function(self.__sid_prefix__  . a:func_name)
  call add(self.__funcs__, func_name)
endfunction
let s:Module.__bind__ = function(s:SID . 'Module_bind')
let s:Module.function = s:Module.__bind__ | " syntax sugar

" Defines an alias of module function {func_name}.
"
"   call s:Fizz.alias('hi', 'hello')
"
function! s:Module_alias(alias, func_name) dict
  if has_key(self, a:func_name) && type(self[a:func_name]) == s:TYPE_FUNC
    let self[a:alias] = self[a:func_name]
    call add(self.__funcs__, a:alias)
  else
    throw "vim-oop: " . self.name . "." . a:func_name . "() is not defined."
  endif
endfunction
let s:Module.alias = function(s:SID . 'Module_alias')

let &cpo = s:save_cpo
unlet s:save_cpo
