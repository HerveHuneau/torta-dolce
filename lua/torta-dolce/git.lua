local M = {}

function M.create_branch(branch_name)
	local obj = vim.system({ "git", "checkout", "-b", branch_name }):wait()
	if obj.code ~= 0 then
		vim.notify("An error occurred while creating the branch: " .. obj.stderr, vim.log.levels.ERROR, {})
		return false
	end
	vim.notify("Created the local branch: " .. branch_name, vim.log.levels.INFO)
	return true
end

return M
