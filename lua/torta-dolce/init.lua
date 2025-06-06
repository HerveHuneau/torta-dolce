local youtrack = require("torta-dolce.youtrack")
local git = require("torta-dolce.git")
local github = require("torta-dolce.github")
local config = require("torta-dolce.config")

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
			local issue_id = vim.fn.input("What issue do you want to work on ?", config.user.default_slug)
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

		youtrack.update_state(issue.id, config.youtrack.picked_state)
	end)
end

M.review_work = function()
	local branch_name = git.get_current_branch_name()
	if not branch_name then
		return
	end

	local repo = git.get_remote_repo()
	if not repo then
		vim.notify("No remote branch found, push your changes to a remote branch first.", vim.log.levels.WARN, {})
		return
	end

	local issue_id = branch_name:match("^([a-zA-Z0-9-]*)/.*$")
	if not issue_id then
		vim.notify("No issue_id found for current branch. Did you start work?", vim.log.levels.WARN, {})
		return
	end

	local issue = youtrack.get_issue(issue_id)
	if not issue then
		vim.notify("No youtrack card linked to current branch. Nothing to review", vim.log.levels.WARN, {})
		return
	end

	local title = "[" .. issue_id .. "] " .. issue.summary
	local body = "Issue: " .. issue["url"]
	local base_branch_name = git.get_base_branch()

	vim.ui.select({ "Yes", "No" }, {
		prompt = "Do you want to open the PR as a draft?",
	}, function(choice, _)
		if not choice then
			return
		end

		local draft = choice == "Yes"
		local pr = github.create_pull_request(repo, title, body, branch_name, base_branch_name, draft)
		if not pr then
			return
		end

		youtrack.update_state(issue_id, config.youtrack.review_state)
		youtrack.comment(issue_id, "PR " .. repo.repo .. " -> " .. pr.html_url)
	end)
end

M.merge_pr = function()
	local branch_name = git.get_current_branch_name()
	if not branch_name then
		return
	end

	local repo = git.get_remote_repo()
	if not repo then
		vim.notify("No remote branch found, push your changes to a remote branch first.", vim.log.levels.WARN, {})
		return
	end

	local issue_id = branch_name:match("^([a-zA-Z0-9-]*)/.*$")
	if not issue_id then
		vim.notify("No issue_id found for current branch. Did you start work?", vim.log.levels.WARN, {})
		return
	end

	local issue = youtrack.get_issue(issue_id)
	if not issue then
		vim.notify("No youtrack card linked to current branch. Nothing to review", vim.log.levels.WARN, {})
		return
	end

	local pr = github.get_pull_request(repo, branch_name)
	if not pr then
		vim.notify("No pull request found for current branch.", vim.log.levels.WARN, {})
		return
	end

	if pr.draft or not pr.mergeable or pr.mergeable_state ~= "clean" then
		vim.notify("Pull request is not in a mergeable state. Please check it on Github", vim.log.levels.WARN, {})
		return
	end

	local title = "[" .. issue_id .. "] " .. issue.summary
	local commit_title = vim.fn.input("Commit title for merge: ", title)
	local commit_message = vim.fn.input("Commit message for merge: ")

	github.merge_pull_request(repo, pr.number, commit_title, commit_message)
	youtrack.update_state(issue_id, config.youtrack.merged_state)
end

return M
