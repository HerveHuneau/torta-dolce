vim.api.nvim_create_user_command("TortaDolce", function(opts)
	-- Live reload
	package.loaded["torta-dolce"] = nil
	package.loaded["torta-dolce.git"] = nil
	package.loaded["torta-dolce.github"] = nil
	package.loaded["torta-dolce.youtrack"] = nil
	package.loaded["torta-dolce.config"] = nil

	if opts.args == "startWork" then
		require("torta-dolce").start_work()
	elseif opts.args == "reviewWork" then
		require("torta-dolce").review_work()
	elseif opts.args == "mergePR" then
		require("torta-dolce").merge_pr()
	else
		vim.notify("Only startWork, reviewWork and mergePR are implemented yet", vim.log.levels.WARN, {})
	end
end, { nargs = "+" })
