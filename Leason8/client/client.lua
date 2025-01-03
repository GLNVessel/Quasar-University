local Framework = nil
local FrameworkName = Config.Framework

Citizen.CreateThread(function()
    if FrameworkName == 'esx' then
        Framework = exports['es_extended']:getSharedObject()
    elseif FrameworkName == 'qbcore' then
        Framework = exports['qb-core']:GetCoreObject()
    else
        print('Error: Unsupported framework specified in config.')
    end
end)

CreateThread(function()
    for i = 1, #Config.locations do 
        local blip = AddBlipForCoord(Config.locations[i])
        SetBlipSprite(blip, Config.blipInfo.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, Config.blipInfo.scale)
        SetBlipColour(blip, Config.blipInfo.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(tostring(Config.blipInfo.name))
        EndTextCommandSetBlipName(blip)
    end
end)

CreateThread(function()
    for _, location in ipairs(Config.locations) do
        exports['qb-target']:AddBoxZone("bank_" .. tostring(location), location, 1.5, 1.5, {
            name = "bank_" .. tostring(location),
            heading = 0,
            debugPoly = false,
            minZ = location.z - 1,
            maxZ = location.z + 1
        }, {
            options = {
                {
                    type = "client",
                    event = "bank:client:loginMenu",
                    icon = "fas fa-university",
                    label = "Access Bank",
                },
            },
            distance = 5
        })
    end
end)

RegisterCommand('bank', function()
    if FrameworkName == 'esx' then
        Framework.TriggerServerCallback('bank:getBalance', function(balance, cash)
            if balance and cash then
                TriggerEvent('bank:client:loginMenu', balance, cash)
            else
                print('Error: Unable to retrieve balance.')
            end
        end)
    elseif FrameworkName == 'qbcore' then
        Framework.Functions.TriggerCallback('bank:getBalance', function(balance, cash)
            if balance and cash then
                TriggerEvent('bank:client:loginMenu', balance, cash)
            else
                print('Error: Unable to retrieve balance.')
            end
        end)
    else
        print('Error: Unsupported framework specified in config.')
    end
end)

RegisterNetEvent('bank:client:loginMenu')
AddEventHandler('bank:client:loginMenu', function()
    Framework.Functions.TriggerCallback('bank:getBalance', function(balance, cash)
        if balance and cash then
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = 'loginMenu',
                balance = balance,
                cash = cash
            })
        else
            print('Error: Unable to retrieve balance.')
        end
    end)
end)

-- NUI Callback for opening the menu
RegisterNUICallback('openMenu', function(data, cb)
    TriggerServerEvent('bank:server:openMenu')
    cb('ok')
end)

-- Event to open the bank menu
RegisterNetEvent('bank:client:openMenu', function(balance, cash)
    SendNUIMessage({
        action = 'openMenu',
        balance = balance,
        cash = cash
    })
    SetNuiFocus(true, true)
end)


-- Function to refresh the menu
function refreshMenu()
    if FrameworkName == 'esx' then
        Framework.TriggerServerCallback('bank:getBalance', function(balance, cash)
            if balance and cash then
                SendNUIMessage({
                    action = 'updateMenu',
                    balance = balance,
                    cash = cash
                })
            else
                print('Error: Unable to refresh balance.')
            end
        end)
    elseif FrameworkName == 'qbcore' then
        Framework.Functions.TriggerCallback('bank:getBalance', function(balance, cash)
            if balance and cash then
                SendNUIMessage({
                    action = 'updateMenu',
                    balance = balance,
                    cash = cash
                })
            else
                print('Error: Unable to refresh balance.')
            end
        end)
    end
end

RegisterNUICallback('deposit', function(data, cb)
    local amount = tonumber(data.amount)
    if amount and amount > 0 then
        TriggerServerEvent('bank:server:deposit', amount)
        cb('ok')
        refreshMenu() -- Refresh after deposit
    else
        cb('error')
    end
end)

RegisterNUICallback('withdraw', function(data, cb)
    local amount = tonumber(data.amount)
    if amount and amount > 0 then
        TriggerServerEvent('bank:server:withdraw', amount)
        cb('ok')
        refreshMenu() -- Refresh after withdrawal
    else
        cb('error')
    end
end)

RegisterNUICallback('transfer', function(data, cb)
    local targetId = tonumber(data.targetId)
    local amount = tonumber(data.amount)
    if targetId and amount and amount > 0 then
        TriggerServerEvent('bank:server:transfer', targetId, amount)
        cb('ok')
        refreshMenu() -- Refresh after transfer
    else
        cb('error')
    end
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNetEvent('bank:client:notify')
AddEventHandler('bank:client:notify', function(messageKey)
    local message = _U(messageKey)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(false, true)
end)
