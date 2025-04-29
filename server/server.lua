local QBCore = exports['qb-core']:GetCoreObject()

-- Buy items from shop
RegisterNetEvent('ghost_fishing:buyItem', function(item, price, quantity)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local totalPrice = price * quantity
    if Player.Functions.RemoveMoney('cash', totalPrice) then
        exports.ox_inventory:AddItem(src, item, quantity)
        TriggerClientEvent('QBCore:Notify', src, 'You bought ' .. quantity .. 'x ' .. item, 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, 'Not enough money!', 'error')
    end
end)

-- Fish data callback
QBCore.Functions.CreateCallback('ghost_fishing:getFishData', function(source, cb)
    local chance = math.random(1, 100)
    local fish = nil
    
    -- Simple probability distribution for fish types
    if chance <= 10 then           -- 10% Tuna (most valuable)
        fish = Config.fish[1]      -- Tuna
    elseif chance <= 25 then       -- 15% Salmon
        fish = Config.fish[2]      -- Salmon
    elseif chance <= 50 then       -- 25% Trout
        fish = Config.fish[3]      -- Trout
    elseif chance <= 75 then       -- 25% Bass
        fish = Config.fish[5]      -- Bass
    else                           -- 25% Anchovy (most common)
        fish = Config.fish[4]      -- Anchovy
    end
    
    cb(fish)
end)

-- Try to catch fish
RegisterNetEvent('ghost_fishing:tryFish', function(fishData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Remove bait
    if exports.ox_inventory:RemoveItem(src, Config.bait.itemName, 1) then
        -- Add fish to inventory
        exports.ox_inventory:AddItem(src, fishData.item, 1)
        TriggerClientEvent('QBCore:Notify', src, 'You caught a ' .. fishData.label, 'success')

        -- Random chance to break fishing rod
        if math.random(1, 100) <= Config.fishingRod.breakChance then
            if exports.ox_inventory:RemoveItem(src, Config.fishingRod.itemName, 1) then
                TriggerClientEvent('QBCore:Notify', src, 'Your fishing rod broke!', 'error')
            end
        end
    end
end)

-- Remove bait on failed attempt
RegisterNetEvent('ghost_fishing:removeBait', function()
    local src = source
    exports.ox_inventory:RemoveItem(src, Config.bait.itemName, 1)
end)

-- Sell fish items
RegisterNetEvent('ghost_fishing:sellFishItem', function(item, price)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local count = exports.ox_inventory:Search(src, 'count', item)
    if count > 0 then
        if exports.ox_inventory:RemoveItem(src, item, count) then
            local payment = count * price
            Player.Functions.AddMoney('cash', payment)
            TriggerClientEvent('QBCore:Notify', src, 'Sold ' .. count .. ' fish for $' .. payment, 'success')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'You don\'t have any fish to sell!', 'error')
    end
end)

-- Anti-cheat measures
local function isPositionValid(playerCoords, shopCoords, maxDistance)
    return #(playerCoords - shopCoords) <= maxDistance
end

RegisterNetEvent('ghost_fishing:sellFish', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    if not isPositionValid(playerCoords, vector3(Config.sellShop.coords.x, Config.sellShop.coords.y, Config.sellShop.coords.z), 5.0) then
        -- Possible cheating attempt
        return
    end
    -- Rest of selling logic...
end)