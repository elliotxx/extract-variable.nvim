local queries = require("nvim-treesitter.query")
local M = {}
function M.extract_variable()
	-- check vim file type
	local file_type = vim.bo.filetype
	if file_type == nil then
		return
	end

	-- check language supported
	local languages = {
		"go",
		"python",
		"lua",
	}
	local supported = false
	for _, language in ipairs(languages) do
		if file_type == language then
			supported = true
			break
		end
	end
	if not supported then
		local ret = string.format("file type %s not supported", file_type)
		vim.api.nvim_echo({ { ret, "WarningMsg" } }, true, {})
		return
	end
	if not queries.get_query(file_type, "textobjects") then
		query = nil
		vim.api.nvim_echo({ { "no textobjects query found", "WarningMsg" } }, true, {})
		return
	end
	local var = vim.fn.input("New var: ")
	if var == "" then
		vim.api.nvim_echo({ { "empty var", "WarningMsg" } }, true, {})
		return
	end
	local unnamed = vim.fn.getreg('"')

	local cmd = string.format(":lua require'nvim-treesitter.textobjects.select'.select_textobject('@parameter.inner')")

	vim.cmd(cmd)
	vim.cmd('normal! "zy')
	vim.cmd(cmd)
	--replace selected text with new var
	vim.cmd("normal! d")
	vim.cmd("normal! i" .. var)
	--
	local stored = vim.fn.getreg("z")
	if file_type == "go" then
		newinfo = string.format("%s := %s ", var, stored)
	elseif file_type == "lua" then
		newinfo = string.format("%s = %s ", var, stored)
	end
	vim.fn.setreg("z", newinfo)
	-- put new content before current line
	vim.cmd("normal! O ")
	vim.cmd("normal! x")

	vim.cmd('normal! "zp')

	vim.fn.setreg('"', unnamed)
end

-- add setup function
M.setup = function()
	vim.keymap.set("n", "<Leader>vv", ':lua require("extract_variable").extract_variable()<CR>')
end

return M
