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

function M.issues()
	local token = get_youtrack_token()
	if not token then
		print("Could not get token. aborting.")
		return
	end

	local result = curl.get("https://prima-assicurazioni-spa.myjetbrains.com/youtrack/api/issues", {
		query = {
			query = "tag:Payments-Onyx",
			fields = "id,idReadable,summary",
			["$top"] = "20",
		},
		headers = {
			authorization = "Bearer " .. token,
		},
	})

	result = vim.fn.json_decode(result.body)
	return result
end

function M.update_state(issue_id)
	local payload = {
		customFields = {
			{
				name = "State",
				["$type"] = "StateIssueCustomField",
				value = { name = "In Progress" },
			},
		},
	}

	local token = get_youtrack_token()
	if not token then
		print("Could not get token. aborting.")
		return
	end

	local result = curl.post("https://prima-assicurazioni-spa.myjetbrains.com/youtrack/api/issues/" .. issue_id, {
		body = vim.fn.json_encode(payload),
		headers = {
			content_type = "application/json",
			authorization = "Bearer " .. token,
		},
	})

	if result.status ~= 200 then
		vim.notify("Error while updating the youtrack card: " .. result.body, vim.log.levels.ERROR, {})
	else
		vim.notify("Updated the youtrack card!", vim.log.levels.INFO, {})
	end
end

function M.get_issue(issue_id)
	local token = get_youtrack_token()
	if not token then
		print("Could not get token. aborting.")
		return
	end

	local result = curl.get("https://prima-assicurazioni-spa.myjetbrains.com/youtrack/api/issues/" .. issue_id, {
		query = {
			fields = "id,idReadable,summary",
		},
		headers = {
			authorization = "Bearer " .. token,
		},
	})

	result = vim.fn.json_decode(result.body)
	return result
end

return M
