vim.api.nvim_create_user_command("TortaDolce", function(opts)
	package.loaded["torta-dolce"] = nil

	if opts.args == "startWork" then
		require("torta-dolce").start_work()
	else
		vim.notify("Only startWork implemented yet", vim.log.levels.WARN, {})
	end
end, { nargs = "+" })
