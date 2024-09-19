local onDuty = false

local dropoffloc 
local dropnpc
local cooldown
local dropzone
local randomVehicles
local vehicles = config.Vehicles
local randomVehicles = {}

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

Citizen.CreateThread(function ()
    lib.requestModel(config.boss.model, 100)
    modelHash = GetHashKey(config.boss.model)
    npc = CreatePed(0, modelHash, config.boss.coords.x, config.boss.coords.y, config.boss.coords.z-1.0, config.boss.coords.h, false, false)
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
	TaskStartScenarioInPlace(npc, "WORLD_HUMAN_COP_IDLES", 0, true)

    if config.boss.blip then
        local bossblip = AddBlipForCoord(config.boss.coords.x, config.boss.coords.y, config.boss.coords.z)
        SetBlipSprite(bossblip, 229) 
        SetBlipColour(bossblip, 1)
        SetBlipScale(bossblip, 1.0)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Illegal Car Theft")
        EndTextCommandSetBlipName(bossblip)
        SetBlipAsShortRange(bossblip, true)
    end

    exports.ox_target:addLocalEntity(npc, {
        {
            label = "Start Job",
            distance = 4.0,
            icon = "fa-solid fa-person",
            onSelect = function ()
                TriggerServerEvent("gen-carheist:server:cooldown")
            end
        },
        {
            label = "Quit Job",
            distance = 4.0,
            icon = "fa-solid fa-person",
            onSelect = function ()
                if onDuty then
                    lib.notify({
                        title = "Genesis",
                        description = "You quit the job!",
                        type = "inform",
                        icon = "fa-solid fa-person"
                    })
                    lib.hideTextUI()
                    onDuty = false
                    if DoesBlipExist(dropoffloc) then
                        RemoveBlip(dropoffloc)
                    end
                    DeleteEntity(dropnpc)
                    dropzone:remove()
                else
                    lib.notify({
                        title = "Genesis",
                        description = "You are not doing any jobs currently!",
                        type = "error",
                        icon = "fa-solid fa-person"
                    })
                end
            end
        }
    })
end)

RegisterNetEvent("gen-carheist:client:startcarheist")
AddEventHandler("gen-carheist:client:startcarheist", function ()
    if not onDuty then
        TriggerEvent("gen-carheist:client:start")
        lib.notify({
            title = "Genesis",
            description = "Job Started",
            type = "inform",
            icon = "fa-solid fa-person"
        })
        onDuty = true
    else
        lib.notify({
            title = "Genesis",
            description = "You already have this job!",
            type = "error",
            icon = "fa-solid fa-person"
        })
    end
end)

function checkList(vehicle, vehicleList)
    print("vehicleList:", vehicleList)  -- Debug print
    if type(vehicleList) ~= "table" then
        print("vehicleList is not a table or is nil")
        return false
    end

    for _, name in ipairs(vehicleList) do
        if name == vehicle then
            return true
        end
    end
    return false
end

RegisterNetEvent("gen-carheist:client:start")
AddEventHandler("gen-carheist:client:start", function ()
    local randomVehicles = randomcargen(vehicles, 5)
    local dropran = math.random(1, #config.dropCoords)
    local dropLoc = config.dropCoords[dropran]

    local vehicleListText = ""
    for _, vehicle in ipairs(randomVehicles) do
        vehicleListText = "\n"..vehicleListText .. "- " .. vehicle .. "\n"
    end

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
    modelHash = GetHashKey(config.boss.model)

    dropnpc = CreatePed(0, modelHash, dropLoc.x, dropLoc.y, dropLoc.z-1.0, dropLoc.h, false, false)
    SetEntityInvincible(dropnpc, true)
    FreezeEntityPosition(dropnpc, true)
    SetBlockingOfNonTemporaryEvents(dropnpc, true)

    local playerPed = PlayerPedId()

    local dropzone = lib.points.new({
        coords = vector3(dropLoc.x, dropLoc.y, dropLoc.z-1.0),
        distance = 8,
    })
    print(dropzone)

    function dropzone:onEnter()
        print(vehicle)
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        local vehicleClass = GetVehicleClass(vehicle)
        local reward = config.Rewards[vehicleClass]
        local vehiclehash = GetEntityModel(vehicle)
        local modelname = GetDisplayNameFromVehicleModel(vehiclehash)
        local inVehicle = IsPedInAnyVehicle(playerPed, false)
        if inVehicle then
            if checkList(modelname, randomVehicles) then
                lib.notify({
                    title = "Genesis",
                    description = "Press [E] to deliver the vehicle",
                    duration = 5000,
                    type = "inform",
                    icon = "fa-solid fa-person"
                })
                while true do
                    Wait(0)
                    if IsControlJustReleased(0, 38) then
                        DeleteVehicle(vehicle)
                        TriggerServerEvent("gen-carheist:server:reward", reward)
                        lib.hideTextUI()
                        onDuty = false
                        if DoesBlipExist(dropoffloc) then
                            RemoveBlip(dropoffloc)
                        end
                        DeleteEntity(dropnpc)
                        dropzone:remove()
                        break
                    end
                end
            elseif not checkList(modelname, randomVehicles) then
                lib.notify({
                    title = "Genesis",
                    description = "Wrong vehicle",
                    type = "error",
                    icon = "fa-solid fa-person"
                })
            end
        elseif not inVehicle then
            lib.notify({
                title = "Genesis",
                description = "You are not in a vehicle",
                type = "error",
                icon = "fa-solid fa-person"
            })
        end
    end

end)