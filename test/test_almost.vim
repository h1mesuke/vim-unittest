" unittest.vim's test suite

let here = expand('<sfile>:p:h')
execute 'source' here . '/test_context.vim'
execute 'source' here . '/test_data.vim'
execute 'source' here . '/test_setup.vim'
execute 'source' here . '/test_should.vim'

" vim: filetype=vim
