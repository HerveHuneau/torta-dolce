local youtrack = require("torta-dolce.youtrack")
local git = require("torta-dolce.git")

local M = {}
local function normalize_git_ref_segment(summary)
	return summary:gsub("[^A-Za-z0-9]+", "-"):lower():gsub("^%-+", ""):gsub("%-+$", "")
end

M.start_work = function()
	local issues = youtrack.issues()
	if not issues or #issues == 0 then
		return
	end

	local selection = { "Other..." }
	for _, issue in ipairs(issues) do
		table.insert(selection, issue.idReadable .. " | " .. issue.summary)
	end

	vim.ui.select(selection, {
		prompt = "What issue do you want to work on ?",
	}, function(choice, index)
		if not choice then
			return
		end

		local issue
		if index == 1 then
			local issue_id = vim.fn.input("What issue do you want to work on ?", "PAY-")
			issue = youtrack.get_issue(issue_id)
			if not issue then
				return
			end
		else
			issue = issues[index - 1]
		end

		local branch_created = git.create_branch(issue.idReadable .. "/" .. normalize_git_ref_segment(issue.summary))
		if not branch_created then
			return
		end

		youtrack.update_state(issue.id)
	end)
end

return M
