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

local function create_branch(branch_name)
	local obj = vim.system({ "git", "checkout", "-b", branch_name }):wait()
	if obj.code ~= 0 then
		vim.notify("An error occurred while creating the branch: " .. obj.stderr, vim.log.levels.ERROR, {})
		return false
	end
	vim.notify("Created the local branch: " .. branch_name, vim.log.levels.INFO)
	return true
end

local function normalize_git_ref_segment(summary)
	return summary:gsub("[^A-Za-z0-9]+", "-"):lower():gsub("^%-+", ""):gsub("%-+$", "")
end

local function update_youtrack_state(issue_id)
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

M.youtrack_issues = function()
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

	local selection = { "Other..." }
	for index, issue in ipairs(result) do
		selection[index + 1] = issue.idReadable .. " | " .. issue.summary
	end

	vim.ui.select(selection, {
		prompt = "What issue do you want to work on ?",
	}, function(choice, index)
		if not choice then
			print("No choice")
			return
		end
		local issue = result[index - 1]

		local branch_created = create_branch(issue.idReadable .. "/" .. normalize_git_ref_segment(issue.summary))
		if not branch_created then
			return
		end

		update_youtrack_state(issue.id)
	end)
end

return M
