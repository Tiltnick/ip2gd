local nk = require("nakama")

local function delete_account(context, payload)
    local user_id = context.user_id

    if not user_id then
        error("No user ID")
    end

    nk.account_delete_id(user_id)

    return nk.json_encode({
        success = true
    })
end

nk.register_rpc(delete_account, "delete_account")