local M = {}
local curl = require("plenary.curl")

local get_youtrack_token = function()
	local token = io.open(os.getenv("HOME") .. "/.suite_py/token_youtrack.txt", "r")

	if token then
		local content = token:read("*a")
		token:close()
		token = content
	else
		print("Failed to open ~/.suite_py/token_youtrack.txt file. Maybe you should import it ?")
		return
	end
	return token:match("^%s*(.-)%s*$")
end

M.youtrack_issues = function()
	local token = get_youtrack_token()
	if not token then
		print("Could not get token. aborting.")
		return
	end

	local result = curl.get("https://prima-assicurazioni-spa.myjetbrains.com/youtrack/api/issues", {
		query = {
			query = "tag:Payments-Onyx",
			fields = "idReadable,summary",
			["$top"] = "10",
		},
		headers = {
			authorization = "Bearer " .. token,
		},
	})

	result = vim.fn.json_decode(result.body)

	local selection = { "Other..." }
	for index, issue in ipairs(result) do
		selection[index + 1] = issue.idReadable .. " | " .. issue.summary
	end

	vim.ui.select(selection, {
		prompt = "What issue do you want to work on ?",
	}, function(choice)
		if not choice then
			print("No choice")
			return
		end
		print("Issue is: " .. choice)
	end)
end

return M
