-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp_keymaps", { clear = true }),
	callback = function(ev)
		-- Normal 模式映射
		vim.keymap.set('n', '<leader>a', vim.lsp.buf.code_action, { buffer = ev.buf, desc = 'Code Action (LSP)' })
		vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, { buffer = ev.buf, desc = 'Rename symbol (LSP)' })

		-- Visual 模式映射
		vim.keymap.set('v', '<leader>a', vim.lsp.buf.code_action, { buffer = ev.buf, desc = 'Code Action (LSP)' })
		vim.keymap.set('v', '<leader>r', vim.lsp.buf.rename, { buffer = ev.buf, desc = 'Rename symbol (LSP)' })
	end
})
