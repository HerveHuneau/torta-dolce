local M = {}
local curl = require("plenary.curl")

local get_github_token = function()
	local token = io.open(os.getenv("HOME") .. "/.suite_py/token_github.txt", "r")

	if token then
		local content = token:read("*a")
		token:close()
		token = content
	else
		print("Failed to open ~/.suite_py/token_github.txt file. Maybe you should import it ?")
		return
	end
	return token:match("^%s*(.-)%s*$")
end

function M.list_issues()
	local token = get_github_token()
	if not token then
		return
	end

	local result = curl.get("https://api.github.com/issues", {
		headers = {
			authorization = "Bearer " .. token,
			["Accept"] = "application/vnd.github+json",
			["X-GitHub-Api-Version"] = "2022-11-28",
		},
	})
end

function M.create_pull_request(repo, title, branch_name)
	local token = get_github_token()
	if not token then
		return
	end

	local result = curl.post("https://api.github.com/repos/" .. repo.owner .. "/" .. repo.repo .. "/pulls", {
		body = vim.json.encode({
			title = title,
			body = "",
			head = branch_name,
			base = "main",
		}, {}),
		headers = {
			authorization = "Bearer " .. token,
			["Accept"] = "application/vnd.github+json",
			["X-GitHub-Api-Version"] = "2022-11-28",
		},
	})

	if result.status ~= 201 then
		vim.notify("Error while creating the pull request : " .. result.body, vim.log.levels.ERROR, {})
		return
	end

	result = vim.fn.json_decode(result.body)
	vim.notify("Created the PR!" .. result.html_url, vim.log.levels.INFO, {})
	return result
end

return M
