local M = {}
local curl = require("plenary.curl")
local config = require("torta-dolce.config")

local get_github_token = function()
	local tokens = config.get_tokens()
	if not tokens then
		return
	end
	return tokens["github"]
end

function M.create_pull_request(repo, title, body, branch_name, base_branch_name)
	local token = get_github_token()
	if not token then
		return
	end

	local result = curl.post("https://api.github.com/repos/" .. repo.owner .. "/" .. repo.repo .. "/pulls", {
		body = vim.json.encode({
			title = title,
			body = body,
			head = branch_name,
			base = base_branch_name,
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
