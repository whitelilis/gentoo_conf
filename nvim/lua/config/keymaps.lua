-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp_keymaps", { clear = true }),
	callback = function(ev)
		-- Normal 模式映射
		vim.keymap.set('n', '<leader>a', vim.lsp.buf.code_action, { buffer = ev.buf, desc = 'Code Action (LSP)' })
		vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, { buffer = ev.buf, desc = 'Rename symbol (LSP)' })
		-- 编译项目
		vim.keymap.set("n", "<leader>m", "<cmd>make<cr>", { desc = "Compile with Ninja" })
		-- 跳转到下一个/上一个错误
		vim.keymap.set("n", "<leader>q", "<cmd>cnext<cr>", { desc = "Next Quickfix Item" })
		vim.keymap.set("n", "<leader>p", "<cmd>cprev<cr>", { desc = "Previous Quickfix Item" })
		-- -- 打开/关闭 Quickfix 列表
		vim.keymap.set("n", "<leader>cq", "<cmd>copen<cr>", { desc = "Open Quickfix" })
		vim.keymap.set("n", "<leader>cQ", "<cmd>cclose<cr>", { desc = "Close Quickfix" })

	end
})
