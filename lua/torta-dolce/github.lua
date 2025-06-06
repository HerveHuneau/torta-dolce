local M = {}
local curl = require("plenary.curl")
local config = require("torta-dolce.config")

local GITHUB_API_URL = "https://api.github.com/repos/"

function M.create_pull_request(repo, title, body, branch_name, base_branch_name, draft)
	local result = curl.post(GITHUB_API_URL .. repo.owner .. "/" .. repo.repo .. "/pulls", {
		body = vim.json.encode({
			title = title,
			body = body,
			head = branch_name,
			base = base_branch_name,
			draft = draft,
		}, {}),
		headers = {
			authorization = "Bearer " .. config.tokens.github,
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

function M.get_pull_request(repo, branch_name)
	local result = curl.get(GITHUB_API_URL .. repo.owner .. "/" .. repo.repo .. "/pulls", {
		query = {
			head = repo.owner .. ":" .. branch_name,
		},
		headers = {
			authorization = "Bearer " .. config.tokens.github,
			["Accept"] = "application/vnd.github+json",
			["X-GitHub-Api-Version"] = "2022-11-28",
		},
	})
	result = vim.fn.json_decode(result.body)

	-- This calls returns all matching PRs.
	-- I just want the first most likely
	local first_pr = result[1]
	if not first_pr then
		vim.notify(
			"No PR found that matches current branch: " .. repo.owner .. ":" .. branch_name,
			vim.log.levels.INFO,
			{}
		)
		return
	end

	local pr_details_response =
		curl.get(GITHUB_API_URL .. repo.owner .. "/" .. repo.repo .. "/pulls/" .. first_pr.number, {
			headers = {
				authorization = "Bearer " .. config.tokens.github,
				["Accept"] = "application/vnd.github.raw+json",
				["X-GitHub-Api-Version"] = "2022-11-28",
			},
		})
	if pr_details_response.status ~= 200 then
		vim.notify("Error getting PR details " .. pr_details_response.body, vim.log.levels.ERROR, {})
		return
	end

	pr_details_response = vim.fn.json_decode(pr_details_response.body)
	return pr_details_response
end

function M.merge_pull_request(repo, pr_number, commit_title, commit_message)
	local result = curl.put(GITHUB_API_URL .. repo.owner .. "/" .. repo.repo .. "/pulls/" .. pr_number .. "/merge", {
		body = vim.json.encode({
			commit_title = commit_title,
			commit_message = commit_message,
			merge_method = "squash", -- "merge", "squash", or "rebase"
		}, {}),
		headers = {
			authorization = "Bearer " .. config.tokens.github,
			["Accept"] = "application/vnd.github+json",
			["X-GitHub-Api-Version"] = "2022-11-28",
		},
	})
	if result.status ~= 200 then
		vim.notify("Error merging PR: " .. result.body, vim.log.levels.ERROR, {})
		return
	end
	local response = vim.fn.json_decode(result.body)
	vim.notify("PR merged! SHA: " .. (response.sha or ""), vim.log.levels.INFO, {})
	return response
end

return M
