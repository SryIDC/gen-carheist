local robberyCooldown = config.boss.cooldown  
local lastRobberyTimes = {}

RegisterNetEvent("gen-carheist:server:reward")
AddEventHandler("gen-carheist:server:reward", function (amount)
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)

    Player.Functions.AddMoney(config.Reward.account, amount, config.Reward.reason)
    TriggerClientEvent('ox_lib:notify', src, {
        title = "Genesis",
        description = "You have delivered the vehicle and was rewarded: $"..amount,
        type = "success",
        icon = "fa-solid fa-money-bill",
        duration = 8000
    })
end)

RegisterNetEvent("gen-carheist:server:cooldown")
AddEventHandler("gen-carheist:server:cooldown", function()
    local src = source
    local currentTime = os.time()

    if lastRobberyTimes[src] then
        local lastRobberyTime = lastRobberyTimes[src]
        local timeElapsed = currentTime - lastRobberyTime

        if timeElapsed < robberyCooldown then
            local timeRemaining = robberyCooldown - timeElapsed
            TriggerClientEvent('ox_lib:notify', src, {
                title = "Genesis",
                description = string.format("You must wait %d seconds before starting another car theft!", timeRemaining)
            })
            return
        end
    end
    TriggerClientEvent("gen-carheist:client:startcarheist", src)
    lastRobberyTimes[src] = currentTime

end)
