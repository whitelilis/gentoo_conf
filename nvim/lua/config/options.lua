-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- 基础缩进设置（必须与插件配置同步）
vim.opt.tabstop = 8 -- 一个 TAB 显示为 8 个空格
vim.opt.shiftwidth = 8 -- 自动缩进使用的空格数
vim.opt.expandtab = true -- 将 TAB 转换为空格
vim.opt.makeprg = "ninja -C build"
vim.g.snacks_animate = false -- 关闭所有动画效果
vim.opt.clipboard = "unnamedplus" -- 默认把复制的内容同步到系统剪切板
