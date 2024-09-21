local dropoffloc 
local dropnpc
local vehicles = config.Vehicles

function randomcargen(vehicles, num)
    local selected = {}
    local tempList = {}

    for i, v in ipairs(vehicles) do
        table.insert(tempList, v)
    end
    for i = 1, num do
        if #tempList == 0 then
            break
        end

        local randIndex = math.random(1, #tempList)
        table.insert(selected, table.remove(tempList, randIndex))
    end

    return selected
end

CreateThread(function ()
    lib.requestModel(config.boss.model, 5000)
    local bossnpchash = GetHashKey(config.boss.model)
    npc = CreatePed(0, bossnpchash, config.boss.coords.x, config.boss.coords.y, config.boss.coords.z-1.0, config.boss.coords.h, false, false)
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
	TaskStartScenarioInPlace(npc, "WORLD_HUMAN_COP_IDLES", 0, true)

    if config.boss.blip.enable then
        local bossblip = AddBlipForCoord(config.boss.coords.x, config.boss.coords.y, config.boss.coords.z)
        SetBlipSprite(bossblip, config.boss.blip.sprite) 
        SetBlipColour(bossblip, config.boss.blip.color)
        SetBlipScale(bossblip, config.boss.blip.scale)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(config.boss.blip.text)
        EndTextCommandSetBlipName(bossblip)
        SetBlipAsShortRange(bossblip, true)
    end

    exports.ox_target:addLocalEntity(npc, {
        {
            label = "Start Job",
            distance = 4.0,
            icon = "fa-solid fa-person",
            onSelect = function ()
                TriggerServerEvent("gen-carheist:server:checkcooldown")
            end
        }
    })
end)

RegisterNetEvent("gen-carheist:client:startcarheist", function ()
    TriggerEvent("gen-carheist:client:start")
    TriggerEvent("gen-carheist:client:starttimer")
    Notify("Job Started", "inform")

end)


RegisterNetEvent('gen-carheist:client:deliversuccess', function(vehicle)
    CreateThread(function()
        while true do
            Wait(0)
            local playerPed = PlayerPedId()
            local inVehicle = IsPedInAnyVehicle(playerPed, false)
            if not inVehicle and DoesEntityExist(vehicle) then
                DeleteVehicle(vehicle)
                Notify("Vehicle delivered successfully!", "success")
                TriggerServerEvent("gen-carheist:server:reward")
                TriggerEvent("gen-carheist:client:deletezone")
                if DoesBlipExist(dropoffloc) then
                    RemoveBlip(dropoffloc)
                end
                if DoesEntityExist(dropnpc) then
                    DeleteEntity(dropnpc)
                end
                break 
            end
        end
    end)
end)


RegisterNetEvent("gen-carheist:client:start", function ()
    local randomVehicles = randomcargen(vehicles, 5)
    local dropran = math.random(1, #config.dropCoords)
    local dropLoc = config.dropCoords[dropran]

    local vehicleListText = ""
    for _, vehicle in ipairs(randomVehicles) do
        vehicleListText = "\n"..vehicleListText .. "- " .. vehicle .. "\n"
    end

    local timer = lib.timer(config.boss.robberytime * 1000, function()
        TriggerEvent("gen-carheist:client:deletezone")
        Notify("Timer ended! Better luck next time!", "error")
        lib.hideTextUI()

    end, true)

    CreateThread(function ()
        while true do
            Wait(1000)
            local timeLeft = math.floor(timer:getTimeLeft('s'))
            
            if timeLeft > 0 then
                lib.showTextUI("Time left: "..timeLeft.." seconds", {
                    position= 'top-center',
                    icon = "fa-solid fa-clock"
                })
            end
        end
    end)

    lib.showTextUI(vehicleListText)
    
    
    local dropoffloc = AddBlipForCoord(dropLoc.x, dropLoc.y, dropLoc.z)
    SetBlipSprite(dropoffloc, 1) 
    SetBlipColour(dropoffloc, 5)
    SetBlipScale(dropoffloc, 1.0)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Drop-off")
    EndTextCommandSetBlipName(dropoffloc)
    SetBlipAsShortRange(dropoffloc, true)

    SetBlipRoute(dropoffloc, true)
    SetBlipRouteColour(dropoffloc, 5)
    lib.requestModel(config.boss.model, 100)
    local dropnpcHash = GetHashKey(config.boss.model)

    dropnpc = CreatePed(0, dropnpcHash, dropLoc.x, dropLoc.y, dropLoc.z-1.0, dropLoc.h, false, false)
    SetEntityInvincible(dropnpc, true)
    FreezeEntityPosition(dropnpc, true)
    SetBlockingOfNonTemporaryEvents(dropnpc, true)

    local playerPed = PlayerPedId()

    local deliveryZone = lib.zones.box({
        coords = vec3(dropLoc.x, dropLoc.y, dropLoc.z),
        size = vec3(10, 10, 5),
        rotation = dropLoc.h,
        debug = true,
        inside = function (self)
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            local vehiclehash = GetEntityModel(vehicle)
            local plate = GetVehicleNumberPlateText(vehicle)
            local modelname = GetDisplayNameFromVehicleModel(vehiclehash)
            local inVehicle = IsPedInAnyVehicle(playerPed, false)
            if inVehicle then
                if checkList(modelname, randomVehicles) then
                    if config.boss.owned_cars then
                        TriggerEvent('gen-carheist:client:deliversuccess', vehicle)
                    else
                        TriggerServerEvent("gen-carheist:server:sql", plate, vehicle)
                    end 
                else
                    Notify("Wrong vehicle!", "error")
                    Wait(5000)
                end
            end
        end
    })
    
    RegisterNetEvent("gen-carheist:client:deletezone", function ()
        deliveryZone:remove()
        RemoveBlip(dropoffloc)
        DeleteEntity(dropnpc)
        lib.hideTextUI()
        timer:forceEnd(false)
    end)

end)

function checkList(vehicle, vehicleList)
    if type(vehicleList) ~= "table" then
        return false
    end

    for _, name in ipairs(vehicleList) do
        if name == vehicle then
            return true
        end
    end
    return false
end





function Notify(text, type)
    if config.NotificationType == "ox_lib" then
        lib.notify({
            title = "Genesis",
            description = text,
            type = type,
            duration = 5000,
        })
    elseif config.NotificationType == "qbx_core" then
        exports.qbx_core:Notify(text, type, 5000, "Genesis", 'center-right')
    end
end 
