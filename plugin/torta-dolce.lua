vim.api.nvim_create_user_command("TortaDolce", function(opts)
	package.loaded["torta-dolce"] = nil

	require("torta-dolce").start_work()
end, {})
