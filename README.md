# dotfiles

个人开发环境配置仓库。当前覆盖 zsh、tmux、kitty、Vim 和 Claude Code。

## 安装

在新机器上克隆仓库后执行：

```bash
cd ~/dotfiles
./install.sh
```

安装脚本会执行这些动作：

- 将仓库中的配置软链接到 `$HOME`。
- 安装或配置 Oh My Zsh、zsh plugins 和 fzf。
- 安装 tmux TPM (Tmux Plugin Manager) 和 tmux plugins。
- 安装或配置 kitty，并把 kitty 设置为默认终端。
- 安装 Powerline 字体。
- 写入 Claude Code 的 `CLAUDE.md`、`settings.json`、plugin registry 和 skills。

`install.sh` 会备份已存在的真实文件或目录，备份名为原路径追加 `.bak`。已有 symlink 会被替换。

## 目录

```text
.
├── .zshrc
├── .tmux.conf
├── .vimrc
├── .local/bin/tmux-pane-send-lines
├── .config/kitty/kitty.conf
├── .claude/
│   ├── CLAUDE.md
│   ├── settings.json
│   └── plugins/
└── install.sh
```

## zsh

配置文件：

```text
~/.zshrc
```

使用 Oh My Zsh，启用：

```text
git
zsh-autosuggestions
zsh-syntax-highlighting
```

fzf 历史预览：

```text
输入命令前缀，比如 ls，然后按 F2
上下键选择历史命令
Enter 填回命令行
Esc 或 F2 关闭预览
```

F2 会显示最近 10 条以前缀匹配当前输入的历史命令。

## tmux

前缀键是 `Ctrl-a`，不是默认的 `Ctrl-b`。

### 常用命令

```text
tmux new -s <name>          创建会话
tmux attach -t <name>       进入已有会话
tmux ls                     查看会话
tmux kill-session -t <name>  删除会话
tmux source-file ~/.tmux.conf  重新加载配置
```

### 常用快捷键

```text
Ctrl-a c      新建窗口
Ctrl-a |      左右分屏
Ctrl-a -      上下分屏
Ctrl-a h/j/k/l  切换 pane
Ctrl-a H/J/K/L  调整 pane 大小
Ctrl-a r      重新加载 tmux 配置
Ctrl-a [      进入 copy-mode
Ctrl-a q      显示 pane 编号
Ctrl-a T      将某个 pane 底部 N 行发送到另一个 pane
Ctrl-a G      将某个 pane 顶部 N 行发送到另一个 pane
```

### Pane 编号显示时间

`display-panes-time` 控制 pane 编号提示的显示时长，单位是毫秒：

```tmux
set -g display-panes-time 2000
```

`2000` 表示按下 `Ctrl-a q` 后显示 2 秒。

copy-mode：

```text
v       开始选择
y       复制并退出
Ctrl-c  复制并退出
q       取消并退出
Esc     取消并退出
```

鼠标行为：

- 鼠标拖拽会进入 copy-mode 并高亮选择。
- 选中后按 `y` 或 `Ctrl-c` 复制。
- 点击其他区域会清除当前高亮。
- 普通 shell 里滚轮不会进入 copy-mode。
- Vim、less 等 alternate screen 程序里滚轮会转发给程序。

发送 pane 内容给 Codex/Claude Code：

```text
Ctrl-a T
source pane: 2
target pane: 4
lines: 10
```

这会把当前 window 中 pane 2 底部 10 行直接粘贴到 pane 4。`Ctrl-a G` 是同样的交互，但发送顶部 N 行。

### 会话保存和恢复

配置使用：

- `tmux-plugins/tmux-resurrect`
- `tmux-plugins/tmux-continuum`

手动保存：

```text
Ctrl-a Ctrl-s
```

手动恢复：

```text
Ctrl-a Ctrl-r
```

会话快照保存到：

```text
~/.local/share/tmux/resurrect
```

已启用 pane 内容保存：

```tmux
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-pane-contents-area 'full'
```

这会保存 pane 里的终端输出和 scrollback。它不会让重启前的进程继续运行。

已启用登录后自动启动 tmux：

```tmux
set -g @continuum-boot 'on'
set -g @continuum-restore 'on'
```

systemd 用户服务位置：

```text
~/.config/systemd/user/tmux.service
```

检查服务：

```bash
systemctl --user status tmux.service
systemctl --user is-enabled tmux.service
```

## kitty

配置文件：

```text
~/.config/kitty/kitty.conf
```

常用命令：

```text
kitty --version
kitty +kitten themes
kitty +kitten ssh <host>
```

如果 Dock 中 kitty 图标消失，优先检查 desktop launcher：

```text
~/.local/share/applications/kitty.desktop
```

`Exec` 和 `TryExec` 应使用绝对路径，避免 GNOME Shell 的 `PATH` 找不到 `~/.local/bin`：

```ini
TryExec=/home/patrick/.local/bin/kitty
Exec=/home/patrick/.local/bin/kitty
```

刷新应用数据库：

```bash
update-desktop-database ~/.local/share/applications
```

## Vim

配置文件：

```text
~/.vimrc
```

常用命令：

```text
:w        保存
:q        退出
:wq       保存并退出
:q!       放弃修改退出
/text     向下搜索
?text     向上搜索
n / N     下一个 / 上一个搜索结果
```

常用操作：

```text
hjkl      移动
i         插入模式
Esc       返回 normal mode
v         visual selection
y         yank
p         paste
dd        删除当前行
u         undo
Ctrl-r    redo
```

## Claude Code

配置目录默认是：

```text
~/.claude
```

安装脚本会链接或写入：

```text
~/.claude/CLAUDE.md
~/.claude/settings.json
~/.claude/plugins/installed_plugins.json
~/.claude/plugins/known_marketplaces.json
~/.claude/skills/lark-*
```

首次安装后，在 Claude Code 内执行：

```text
/plugins install claude-hud
/plugins install superpowers
/claude-hud:configure
```

`settings.json` 中的 Node 路径由 `install.sh` 在安装时写入。

## Git

常用命令：

```bash
git status --short
git diff
git add <path>
git commit -m "type(scope): description"
git push
```

提交约定：

- commit message 使用英文。
- 格式：`type(scope): description`。
- 不自动 push，先本地提交，确认后再推送。

## 维护流程

修改配置后，先在当前环境验证，再同步到仓库。

常用检查：

```bash
tmux source-file ~/.tmux.conf
desktop-file-validate ~/.local/share/applications/kitty.desktop
git -C ~/dotfiles status --short
```

安装后配置通常应软链接到仓库。修改前先确认链接状态：

```bash
ls -l ~/.tmux.conf ~/.config/kitty/kitty.conf ~/.vimrc
```

如果目标是 symlink，直接修改 `$HOME` 下的配置等同于修改仓库文件；如果是普通文件，先把变更同步回 `~/dotfiles`。
