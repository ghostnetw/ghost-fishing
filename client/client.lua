-- azotea-fishing client.lua
-- Based and adapted for QBCore + ox_inventory (old)
local QBCore = exports['qb-core']:GetCoreObject()
local fishing = false

function ShowHelp(msg)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

-- OX_LIB CONTEXT MENU (RIGHT, MOUSE SELECTION)
local shopCoords = vector3(Config.sellShop.coords.x, Config.sellShop.coords.y, Config.sellShop.coords.z)
local shopDistance = 2.0

CreateThread(function()
    local shown = false
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local dist = #(playerCoords - shopCoords)
        if dist < 20.0 then
            DrawMarker(2, shopCoords.x, shopCoords.y, shopCoords.z + 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 153, 255, 150, false, true, 2, nil, nil, false)
            if dist < shopDistance then
                if not shown then
                    ShowHelp('[E] Open Fishing Shop')
                    shown = true
                end
                if IsControlJustReleased(0, 38) then
                    openFishingShopMenu()
                end
            elseif shown then
                shown = false
                ClearAllHelpMessages()
            end
        elseif shown then
            shown = false
            ClearAllHelpMessages()
        end
    end
end)

function openFishingShopMenu()
    local menu = {
        id = 'fishing_shop',
        title = 'Fishing Shop',
        position = 'top-right',
        options = {
            {
                title = 'Buy Fishing Rod',
                description = 'Price: $500 each',
                icon = 'fa-solid fa-fish',
                iconColor = '#3498db',
                onSelect = function()
                    local input = lib.inputDialog('Buy Fishing Rod', {{
                        type = 'number',
                        label = 'Amount',
                        description = 'How many do you want to buy?',
                        min = 1,
                        max = 100,
                        default = 1,
                    }})
                    if input and input[1] then
                        local amount = tonumber(input[1])
                        if amount and amount > 0 and amount <= 100 then
                            TriggerServerEvent('ghost_fishing:buyItem', 'fishingrod', 500, amount)
                        end
                    end
                end
            },
            {
                title = 'Buy Fish Bait',
                description = 'Price: $50 each',
                icon = 'fa-solid fa-bug',
                iconColor = '#e67e22',
                onSelect = function()
                    local input = lib.inputDialog('Buy Fish Bait', {{
                        type = 'number',
                        label = 'Amount',
                        description = 'How many do you want to buy?',
                        min = 1,
                        max = 100,
                        default = 1,
                    }})
                    if input and input[1] then
                        local amount = tonumber(input[1])
                        if amount and amount > 0 and amount <= 100 then
                            TriggerServerEvent('ghost_fishing:buyItem', 'fishbait', 50, amount)
                        end
                    end
                end
            },
        }
    }
    -- Add sell options for each fish
    for _, fish in ipairs(Config.fish) do
        table.insert(menu.options, {
            title = 'Sell '..fish.label,
            description = 'Sell for $'..fish.price[2]..' each',
            icon = 'fa-solid fa-money-bill',
            iconColor = '#27ae60', -- green
            onSelect = function()
                TriggerServerEvent('ghost_fishing:sellFishItem', fish.item, fish.price[2])
            end
        })
    end
    lib.registerContext(menu)
    lib.showContext('fishing_shop')
end


local function ShowHelp(msg)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

local function WaterCheck()
    local headPos = GetPedBoneCoords(PlayerPedId(), 31086, 0.0, 0.0, 0.0)
    local offsetPos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 50.0, -25.0)
    local water, waterPos = TestProbeAgainstWater(headPos.x, headPos.y, headPos.z, offsetPos.x, offsetPos.y, offsetPos.z)
    return water, waterPos
end

CreateThread(function()
    local shown = false
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        local water, _ = WaterCheck()
        
        if water and not fishing then
            local hasRod = exports.ox_inventory:Search('count', Config.fishingRod.itemName) > 0
            local hasBait = exports.ox_inventory:Search('count', Config.bait.itemName) > 0
            
            if hasRod and hasBait then
                if not shown then
                    ShowHelp('Right Click to Fish')
                    shown = true
                end
                
                if IsControlJustPressed(0, 25) then -- RIGHT MOUSE BUTTON (Changed from 24 to 25)
                    shown = false
                    ClearAllHelpMessages()
                    TriggerEvent('ghost_fishing:tryStartFishing')
                end
            end
        elseif shown then
            shown = false
            ClearAllHelpMessages()
        end
    end
end)

RegisterNetEvent('ghost_fishing:tryStartFishing', function()
    if IsPedInAnyVehicle(PlayerPedId()) or IsPedSwimming(PlayerPedId()) then
        TriggerEvent('ghost_fishing:notify', 'Cannot fish here', 'You cannot fish while swimming or in a vehicle', 'error')
        return
    end

    local hasRod = exports.ox_inventory:Search('count', Config.fishingRod.itemName) > 0
    local hasBait = exports.ox_inventory:Search('count', Config.bait.itemName) > 0

    if hasBait and hasRod then
        local water, waterLoc = WaterCheck()
        if water or IsEntityInWater(PlayerPedId()) then
            if not fishing then
                fishing = true
                local model = `prop_fishing_rod_01`
                RequestModel(model)
                while not HasModelLoaded(model) do Wait(10) end
                
                -- Better rod positioning and animation
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                local pole = CreateObject(model, coords, true, false, false)
                
                -- Get water direction and set ped heading
                local waterCoords = vector3(waterLoc.x, waterLoc.y, waterLoc.z)
                local direction = waterCoords - coords
                local heading = GetHeadingFromVector_2d(direction.x, direction.y)
                SetEntityHeading(ped, heading)
                
                -- Improved rod attachment
                AttachEntityToEntity(pole, ped, GetPedBoneIndex(ped, 18905), 
                    0.1, 0.05, 0.0,     -- Offset
                    266.0, 0.0, 0.0,    -- Rotation
                    true, true, false, true, 1, true)
                
                SetModelAsNoLongerNeeded(model)
                
                -- Better animation handling
                local dict = "amb@world_human_stand_fishing@idle_a"
                RequestAnimDict(dict)
                while not HasAnimDictLoaded(dict) do Wait(10) end
                
                -- Play proper fishing animation with better flags
                TaskPlayAnim(ped, dict, "idle_c", 8.0, -8.0, -1, 1, 0, false, false, false)
                
                CreateThread(function()
                    while fishing do
                        Wait(0)
                        if IsControlJustReleased(0, 202) then -- BACKSPACE
                            fishing = false
                            ClearPedTasks(PlayerPedId())
                            DeleteObject(pole)
                            TriggerEvent('QBCore:Notify', 'Fishing cancelled', 'error')
                            break
                        end
                        
                        -- Start skillbar immediately
                        local Skillbar = exports['qb-skillbar']:GetSkillbarObject()
                        Skillbar.Start({
                            duration = 2500,
                            pos = math.random(10, 30),
                            width = math.random(10, 20),
                        }, function()
                            -- Success
                            QBCore.Functions.TriggerCallback('ghost_fishing:getFishData', function(fishData)
                                if fishData then
                                    fishing = false
                                    TriggerServerEvent('ghost_fishing:tryFish', fishData)
                                    DeleteObject(pole)
                                    ClearPedTasks(PlayerPedId())
                                end
                            end)
                        end, function()
                            -- Fail
                            TriggerEvent('QBCore:Notify', 'The fish got away!', 'error')
                            TriggerServerEvent('ghost_fishing:removeBait')
                            fishing = false
                            DeleteObject(pole)
                            ClearPedTasks(PlayerPedId())
                        end)
                        break -- Exit the loop after starting skillbar
                    end
                end)
            end
        else
            TriggerEvent('QBCore:Notify', 'You need to be near water to fish', 'error')
        end
    else
        TriggerEvent('QBCore:Notify', 'You need a fishing rod and bait to fish', 'error')
    end
end)

RegisterNetEvent('ghost_fishing:notify', function(title, message, msgType)
    -- Add your preferred notification logic here
    QBCore.Functions.Notify(message, msgType or 'inform')
end)

-- Sell fish event
RegisterNetEvent('ghost_fishing:sellFish', function()
    TriggerServerEvent('ghost_fishing:sellFish')
end)
