local M = {}
local curl = require("plenary.curl")
local config = require("torta-dolce.config")

local get_youtrack_token = function()
	local tokens = config.get_tokens()
	if not tokens then
		return
	end
	return tokens["youtrack"]
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
	result["url"] = "https://prima-assicurazioni-spa.myjetbrains.com/youtrack/issue/" .. result.idReadable
	return result
end

function M.update_state(issue_id, state)
	local token = get_youtrack_token()
	if not token then
		print("Could not get token. aborting.")
		return
	end

	local payload = {
		customFields = {
			{
				name = "State",
				["$type"] = "StateIssueCustomField",
				value = { name = state },
			},
		},
	}

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

function M.comment(issue_id, comment)
	local token = get_youtrack_token()
	if not token then
		print("Could not get token. aborting.")
		return
	end

	local payload = {
		text = comment,
	}

	local result =
		curl.post("https://prima-assicurazioni-spa.myjetbrains.com/youtrack/api/issues/" .. issue_id .. "/comments", {
			body = vim.fn.json_encode(payload),
			headers = {
				content_type = "application/json",
				authorization = "Bearer " .. token,
			},
		})

	if result.status ~= 200 then
		vim.notify("Error while adding the comment to the youtrack card: " .. result.body, vim.log.levels.ERROR, {})
	else
		vim.notify("Updated the youtrack card with the link to the PR", vim.log.levels.INFO, {})
	end
end

return M
