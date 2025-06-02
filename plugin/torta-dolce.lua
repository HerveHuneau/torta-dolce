vim.api.nvim_create_user_command("TortaDolce", function(opts)
	package.loaded["torta-dolce"] = nil

	if opts.args == "startWork" then
		require("torta-dolce").start_work()
	elseif opts.args == "reviewWork" then
		require("torta-dolce").review_work()()
	else
		vim.notify("Only startWork or reviewWork implemented yet", vim.log.levels.WARN, {})
	end
end, { nargs = "+" })
