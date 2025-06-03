local M = {}

function M.get_current_branch_name()
	local obj = vim.system({ "git", "branch", "--show-current" }):wait()
	if obj.code ~= 0 then
		vim.notify("An error occurred while getting the branch name: " .. obj.stderr, vim.log.levels.ERROR, {})
		return
	end
	return obj.stdout:sub(1, -2)
end

function M.get_remote_repo()
	local obj = vim.system({ "git", "remote", "get-url", "origin" }):wait()
	if obj.code ~= 0 then
		vim.notify("An error occurred while getting the remote repo name: " .. obj.stderr, vim.log.levels.ERROR, {})
		return
	end
	local url = obj.stdout:sub(1, -2)
	local owner, repo = url:match("^.*github.com[:/](.*)/(.*).git$")
	if not owner or not repo then
		vim.notify("An error occurred while parsing the remote repo name from url: " .. url, vim.log.levels.ERROR, {})
		return
	end

	return { owner = owner, repo = repo }
end

-- We only imagine 2 possible cases: either master or main
function M.get_base_branch()
	local obj = vim.system({ "git", "branch", "--list", "master" }):wait()
	if obj.code ~= 0 then
		vim.notify(
			"An error occurred while figuring out the base branch name: " .. obj.stderr,
			vim.log.levels.ERROR,
			{}
		)
		return
	end

	local name = obj.stdout:sub(1, -2)
	if not name then
		return "main"
	end
	return "master"
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
