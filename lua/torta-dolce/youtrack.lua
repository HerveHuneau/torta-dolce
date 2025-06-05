local M = {}
local curl = require("plenary.curl")
local config = require("torta-dolce.config")

local URL = config.youtrack.url
local token = config["tokens"]["youtrack"]

function M.issues()
	local result = curl.get(URL .. "/api/issues", {
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
	local result = curl.get(URL .. "/api/issues/" .. issue_id, {
		query = {
			fields = "id,idReadable,summary",
		},
		headers = {
			authorization = "Bearer " .. token,
		},
	})
	if result.status ~= 200 then
		vim.notify(
			"Error while getting the youtrack card " .. issue_id .. "error: " .. result.body,
			vim.log.levels.ERROR,
			{}
		)
		return
	end

	result = vim.fn.json_decode(result.body)
	result["url"] = URL .. "/issue/" .. result.idReadable
	return result
end

function M.update_state(issue_id, state)
	local payload = {
		customFields = {
			{
				name = "State",
				["$type"] = "StateIssueCustomField",
				value = { name = state },
			},
		},
	}

	local result = curl.post(URL .. "/api/issues/" .. issue_id, {
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
	local payload = {
		text = comment,
	}

	local result = curl.post(URL .. "/api/issues/" .. issue_id .. "/comments", {
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
