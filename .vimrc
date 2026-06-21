let mapleader=" "             " 设置自定义命令前缀
set encoding=utf-8            " 设置字符编码为utf-8
set nocompatible              " 关闭与vi的兼容模式
set nu                        " 显示行号
set ruler                     " 右下角状态栏显示光标定位标尺
set showcmd                   " 显示所敲命令
set wildmenu                  " 输入命令时获取匹配列表
set cursorline cursorcolumn   " 突出显示光标所在行列(十字光标)
set ts=4                      " 设置tab键的宽度为4个空格
set sw=4                      " 设置自动缩进的宽度为4个空格
set autoindent                " 设置自动缩进
set incsearch                 " 搜索模式下高亮对应文本
set ignorecase                " 忽略大小写
set smartcase                 " 智能匹配大写
set showmatch                 " 匹配括号，包括() [] {}
syntax on                     " 开启语法检测
filetype on                   " 自动检测文件类型
set lines=30 columns=130
set guifont=Consolas:h15
set noundofile                " 禁止生成.un~结尾的文件
set nobackup                  " 禁止生成~结尾的文件
set noswapfile                " 禁止生成swp文件
set backspace=indent,eol,start " 允许退格键删除

" 取消高亮(空格 + 回车)
noremap <Leader><CR>  :noh<CR>
" 快速跳转行首和行尾
noremap H ^
noremap L $
" 快速上移和下移
noremap K 5k
noremap J 5j
" Esc键映射
inoremap jk <Esc>
" 括号/引号自动补全
inoremap [ []<Esc>i
inoremap ( ()<Esc>i
inoremap " ""<Esc>i
inoremap ' ''<Esc>i
inoremap { {}<Esc>i

inoremap <C-H>  <LEFT>
inoremap <C-K>  <UP>
inoremap <C-J>  <DOWN>
inoremap <C-L>  <RIGHT>

" 刷新Vim配置
map <Leader>q :q<CR>
map <Leader>w :w<CR>
map <Leader>s :source $MYVIMRC<CR>

" 通过vim-plug插件管理器安装插件
call plug#begin('~/.vim/plugged')

Plug 'vim-airline/vim-airline'
Plug 'preservim/nerdtree'
Plug 'connorholyday/vim-snazzy'

call plug#end()

" 设置透明背景
let g:SnazzyTransparent = 0.2

" 设置Vim主题颜色为snazzy
silent! colorscheme snazzy

" 设置注释的颜色为绿色
highlight Comment ctermfg=green guifg=green
