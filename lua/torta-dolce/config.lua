local yaml = require("torta-dolce.simpleyaml")

---@class Config
---@field user User
---@field youtrack Youtrack
---@field okta Okta
---@field tokens Tokens
---
---@class User
---@field projects_home string
---@field review_channel string
---@field deploy_channel string
---@field default_slug string
---@field card_suggest_query string
---@field captainhook_timeout number in seconds
---@field captainhook_url string
---@field use_commits_in_pr_body boolean
---@field frequent_reviews_max_number number
---@field skip_confirmation boolean

---@class Youtrack
---@field url string
---@field picked_state string
---@field review_state string
---@field test_state string
---@field merged_state string
---@field release_state string
---@field add_reviewers_tags boolean
---@field default_issue_type string

---@class Okta
---@field base_url string
---@field client_id string

---@class Tokens
---@field youtrack string
---@field github string

---@type Config
local DEFAULT_CONF = {
	user = {
		projects_home = "projects",
		review_channel = "#review",
		deploy_channel = "#deploy",
		default_slug = "PAY-",
		card_suggest_query = "tag:Payment-Onyx",
		captainhook_timeout = 2,
		captainhook_url = "https://captainhook.prima.it",
		use_commits_in_pr_body = false,
		frequent_reviews_max_number = 5,
		skip_confirmation = false,
	},
	youtrack = {
		url = "",
		picked_state = "In Progress",
		review_state = "In Review",
		merged_state = "Staging",
		test_state = "Staging",
		release_state = "Staging",
		add_reviewers_tags = true,
		default_issue_type = "Task",
	},
	okta = {
		base_url = "https://login.helloprima.com/oauth2/v1",
		client_id = "0oaao88cg7kKPJ4GF417",
	},
	tokens = {
		youtrack = "",
		github = "",
	},
}
local local_config = yaml.parse_file(vim.fn.getenv("HOME") .. "/.suite_py/config.yml")

---@type Config
local M = vim.tbl_deep_extend("force", DEFAULT_CONF, local_config)

-- Need to do this in order to use the suite_py token.
-- Unfortunately it's marshallized in python
local PYTHON_SCRIPT = [[
# -*- encoding: utf-8 -*-
import base64
import marshal
import keyring
import json


def load_from_keyring():
    decoded = keyring.get_password("suite_py", "tokens")
    if decoded is None:
        return None

    decoded = base64.b64decode(decoded)
    decoded = marshal.loads(decoded)
    return decoded


if __name__ == "__main__":
    decoded = load_from_keyring()
    if decoded is None:
        exit(1)
    print(json.dumps(decoded))
]]

local get_tokens = function()
	local token_result = vim.system({ "python" }, {
		stdin = PYTHON_SCRIPT,
	}):wait()

	if token_result.code ~= 0 then
		vim.notify(
			"Could not find stored password in keyring. error: " .. token_result.stderr,
			vim.log.levels.ERROR,
			{}
		)
		return {}
	end

	return vim.json.decode(token_result.stdout)
end

M = vim.tbl_deep_extend("force", M, { tokens = get_tokens() })

return M
