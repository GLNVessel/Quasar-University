-- Detectar framework
if Config.Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
elseif Config.Framework == 'qbcore' then
    QBCore = exports['qb-core']:GetCoreObject()
else
    print('Error: Unsupported framework specified in config.')
end

-- Callback para obtener saldo
if Config.Framework == 'esx' then
    ESX.RegisterServerCallback('bank:getBalance', function(source, cb)
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then
            cb(0, 0)
            return
        end

        local balance = xPlayer.getAccount('bank').money
        local cash = xPlayer.getMoney()
        cb(balance, cash)
    end)
elseif Config.Framework == 'qbcore' then
    QBCore.Functions.CreateCallback('bank:getBalance', function(source, cb)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if not xPlayer then
            cb(0, 0)
            return
        end

        local balance = xPlayer.Functions.GetMoney('bank')
        local cash = xPlayer.Functions.GetMoney('cash')
        cb(balance, cash)
    end)
end

-- Eventos del servidor
RegisterNetEvent('bank:server:deposit')
AddEventHandler('bank:server:deposit', function(amount)
    local src = source
    local xPlayer = GetPlayerFromId(src)

    if not xPlayer then
        TriggerClientEvent('bank:client:notify', src, 'error_retrieve')
        return
    end

    local cash = GetCash(xPlayer)

    if amount > 0 and cash >= amount then
        RemoveCash(xPlayer, amount)
        AddBank(xPlayer, amount)
        TriggerClientEvent('bank:client:notify', src, 'deposit_success')
    else
        TriggerClientEvent('bank:client:notify', src, 'invalid_amount')
    end
end)

RegisterNetEvent('bank:server:withdraw')
AddEventHandler('bank:server:withdraw', function(amount)
    local src = source
    local xPlayer = GetPlayerFromId(src)

    if not xPlayer then
        TriggerClientEvent('bank:client:notify', src, 'error_retrieve')
        return
    end

    local bank = GetBank(xPlayer)

    if amount > 0 and bank >= amount then
        AddCash(xPlayer, amount)
        RemoveBank(xPlayer, amount)
        TriggerClientEvent('bank:client:notify', src, 'withdraw_success')
    else
        TriggerClientEvent('bank:client:notify', src, 'invalid_amount')
    end
end)

RegisterNetEvent('bank:server:transfer')
AddEventHandler('bank:server:transfer', function(targetId, amount)
    local src = source
    local xPlayer = GetPlayerFromId(src)
    local targetPlayer = GetPlayerFromId(targetId)

    if not xPlayer or not targetPlayer then
        TriggerClientEvent('bank:client:notify', src, 'error_retrieve')
        return
    end

    local bank = GetBank(xPlayer)

    if amount > 0 and bank >= amount then
        RemoveBank(xPlayer, amount)
        AddBank(targetPlayer, amount)
        TriggerClientEvent('bank:client:notify', src, 'transfer_success')
    else
        TriggerClientEvent('bank:client:notify', src, 'invalid_amount')
    end
end)

RegisterNetEvent('bank:server:openMenu', function()
    local src = source
    local Player = GetPlayerFromId(src)
    if Player then
        local balance = GetBank(Player)
        local cash = GetCash(Player)
        TriggerClientEvent('bank:client:openMenu', src, balance, cash)
    else
        TriggerClientEvent('bank:client:notify', src, 'error_retrieve')
    end
end)


-- Funciones auxiliares
function GetPlayerFromId(playerId)
    if Config.Framework == 'esx' then
        return ESX.GetPlayerFromId(playerId)
    elseif Config.Framework == 'qbcore' then
        return QBCore.Functions.GetPlayer(playerId)
    end
end

function GetCash(player)
    if Config.Framework == 'esx' then
        return player.getMoney()
    elseif Config.Framework == 'qbcore' then
        return player.Functions.GetMoney('cash')
    end
end

function AddCash(player, amount)
    if Config.Framework == 'esx' then
        player.addMoney(amount)
    elseif Config.Framework == 'qbcore' then
        player.Functions.AddMoney('cash', amount)
    end
end

function RemoveCash(player, amount)
    if Config.Framework == 'esx' then
        player.removeMoney(amount)
    elseif Config.Framework == 'qbcore' then
        player.Functions.RemoveMoney('cash', amount)
    end
end

function GetBank(player)
    if Config.Framework == 'esx' then
        return player.getAccount('bank').money
    elseif Config.Framework == 'qbcore' then
        return player.Functions.GetMoney('bank')
    end
end

function AddBank(player, amount)
    if Config.Framework == 'esx' then
        player.addAccountMoney('bank', amount)
    elseif Config.Framework == 'qbcore' then
        player.Functions.AddMoney('bank', amount)
    end
end

function RemoveBank(player, amount)
    if Config.Framework == 'esx' then
        player.removeAccountMoney('bank', amount)
    elseif Config.Framework == 'qbcore' then
        player.Functions.RemoveMoney('bank', amount)
    end
end
