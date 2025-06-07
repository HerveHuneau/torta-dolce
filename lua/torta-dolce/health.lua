local M = {}

function M.check()
	local github = require("torta-dolce.github")
	local youtrack = require("torta-dolce.youtrack")

	vim.health.start("torta-dolce report")
	local check_github = github.check()
	if check_github then
		vim.health.ok("Github connectivity is fine")
	else
		vim.health.error("Missing or Invalid Github token")
	end
	local current_user = youtrack.get_current_user()
	if current_user then
		vim.health.ok("Youtrack connectivity is fine")
	else
		vim.health.error("Missing or Invalid Youtrack token")
	end
end

return M
