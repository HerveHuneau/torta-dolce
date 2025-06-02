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

	print(vim.inspect(result))
end

--curl -L \
-- -X POST \
-- -H "Accept: application/vnd.github+json" \
-- -H "Authorization: Bearer <YOUR-TOKEN>" \
-- -H "X-GitHub-Api-Version: 2022-11-28" \
-- https://api.github.com/repos/OWNER/REPO/pulls \
-- -d '{"title":"Amazing new feature","body":"Please pull these awesome changes in!","head":"octocat:new-feature","base":"master"}'

function M.create_pull_request()
	local token = get_github_token()
	if not token then
		return
	end

	local result = curl.post("https://api.github.com/repos/HerveHuneau/torta-dolce/pulls", {
		body = vim.json.encode({
			title = "Amazing new feature",
			body = "Please pull these awesome changes in!",
			head = "test",
			base = "main",
		}, {}),
		headers = {
			authorization = "Bearer " .. token,
			["Accept"] = "application/vnd.github+json",
			["X-GitHub-Api-Version"] = "2022-11-28",
		},
	})

	print(vim.inspect(result))
end

return M
