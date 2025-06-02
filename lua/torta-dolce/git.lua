local M = {}

function M.get_current_branch_name()
	local obj = vim.system({ "git", "branch", "--show-current" }):wait()
	if obj.code ~= 0 then
		vim.notify("An error occurred while getting the branch name: " .. obj.stderr, vim.log.levels.ERROR, {})
		return
	end
	-- return string.gsub(obj.stdout, "([a-zA-Z0-9]+)/([a-z-]+)", "%1/%2")
	return obj.stdout:sub(1, -2)
end

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
