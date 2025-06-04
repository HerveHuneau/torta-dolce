local M = {}

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

M.get_tokens = function()
	local token_result = vim.system({ "python" }, {
		stdin = PYTHON_SCRIPT,
	}):wait()

	if token_result.code ~= 0 then
		vim.notify(
			"Could not find stored password in keyring. error: " .. token_result.stderr,
			vim.log.levels.ERROR,
			{}
		)
		return
	end

	return vim.json.decode(token_result.stdout)
end

return M
