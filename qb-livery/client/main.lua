local QBCore = exports['qb-core']:GetCoreObject()

local function HasJobAccess()
    if not Config.AllowedJobs or next(Config.AllowedJobs) == nil then
        return true
    end
    local PlayerData = QBCore.Functions.GetPlayerData()
    if not PlayerData or not PlayerData.job then return false end
    local gradeReq = Config.AllowedJobs[PlayerData.job.name]
    if gradeReq == nil then return false end
    return (PlayerData.job.grade and PlayerData.job.grade.level or 0) >= gradeReq
end

local function Notify(msg, ntype)
    ntype = ntype or 'primary'
    if QBCore and QBCore.Functions and QBCore.Functions.Notify then
        QBCore.Functions.Notify(msg, ntype)
    else
        print(('[qb-livery] %s: %s'):format(ntype, msg))
    end
end

local function GetDriverVehicle()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then return 0 end
    if Config.RequireDriver and GetPedInVehicleSeat(veh, -1) ~= ped then
        return 0
    end
    return veh
end

--========================
-- LIVERY MENU + HANDLERS
--========================
local function openLiveryMenu()
    if not HasJobAccess() then
        Notify('You are not allowed to use this.', 'error')
        return
    end

    local veh = GetDriverVehicle()
    if veh == 0 then
        if Config.RequireDriver then
            Notify('You must be driving a vehicle to change its livery.', 'error')
        else
            Notify('You must be in a vehicle to change its livery.', 'error')
        end
        return
    end

    -- First, try native liveries
    local nativeCount = GetVehicleLiveryCount(veh)
    local menu = {}

    if nativeCount and nativeCount > 1 then
        local current = GetVehicleLivery(veh) or 0
        for i = 0, nativeCount - 1 do
            local isActive = (current == i)
            local title = ('Livery %d%s'):format(i + 1, isActive and ' ✓' or '')
            menu[#menu + 1] = {
                header = title,
                txt = 'Apply native livery #' .. (i + 1),
                params = { event = 'qb-livery:client:apply-native', args = { index = i } }
            }
        end
    else
        -- Fall back to Vehicle Mod Type 48 (Livery)
        SetVehicleModKit(veh, 0)
        local modCount = GetNumVehicleMods(veh, 48)
        if modCount and modCount > 0 then
            local current = GetVehicleMod(veh, 48) -- -1 = stock
            if Config.ShowStockForModType then
                local title = ('Stock%s'):format(current == -1 and ' ✓' or '')
                menu[#menu + 1] = {
                    header = title,
                    txt = 'Remove livery / use stock',
                    params = { event = 'qb-livery:client:apply-modtype', args = { index = -1 } }
                }
            end
            for i = 0, modCount - 1 do
                local isActive = (current == i)
                local title = ('Livery %d%s'):format(i + 1, isActive and ' ✓' or '')
                menu[#menu + 1] = {
                    header = title,
                    txt = 'Apply mod-type livery #' .. (i + 1),
                    params = { event = 'qb-livery:client:apply-modtype', args = { index = i } }
                }
            end
        else
            Notify('This vehicle has no liveries.', 'error')
            return
        end
    end

    if Config.UseQbMenu then
        local qbMenu = {
            { header = 'Vehicle Livery', isMenuHeader = true },
        }
        for i = 1, #menu do qbMenu[#qbMenu + 1] = menu[i] end
        qbMenu[#qbMenu + 1] = { header = 'Close', params = { event = 'qb-menu:client:closeMenu' } }
        exports['qb-menu']:openMenu(qbMenu)
    else
        Notify('qb-menu not found. Install qb-menu or set Config.UseQbMenu = false to use simple cycling commands.', 'error')
    end
end

RegisterNetEvent('qb-livery:client:apply-native', function(data)
    local veh = GetDriverVehicle()
    if veh == 0 then return Notify('No vehicle / not driver.', 'error') end
    local idx = tonumber(data.index or 0) or 0
    SetVehicleLivery(veh, idx)
    Notify(('Applied livery %d.'):format(idx + 1), 'success')
end)

RegisterNetEvent('qb-livery:client:apply-modtype', function(data)
    local veh = GetDriverVehicle()
    if veh == 0 then return Notify('No vehicle / not driver.', 'error') end
    local idx = tonumber(data.index or -1) or -1
    SetVehicleModKit(veh, 0)
    SetVehicleMod(veh, 48, idx, false)
    Notify(idx >= 0 and ('Applied livery %d.'):format(idx + 1) or 'Reverted to stock livery.', 'success')
end)

RegisterCommand('livery', function()
    openLiveryMenu()
end, false)

TriggerEvent('chat:addSuggestion', '/livery', 'Open the livery menu for the vehicle you are driving.')

--========================
-- EXTRAS MENU + HANDLERS
--========================
local function openExtrasMenu()
    if not HasJobAccess() then
        Notify('You are not allowed to use this.', 'error')
        return
    end

    local veh = GetDriverVehicle()
    if veh == 0 then
        if Config.RequireDriver then
            Notify('You must be driving a vehicle to change extras.', 'error')
        else
            Notify('You must be in a vehicle to change extras.', 'error')
        end
        return
    end

    local items = {}
    local any = false
    -- GTA extras typically 1..14, but some vehicles use higher indices. We'll check 1..20.
    for i = 1, 20 do
        if DoesExtraExist(veh, i) then
            any = true
            local isOn = IsVehicleExtraTurnedOn(veh, i)
            items[#items + 1] = {
                header = ('Extra %d %s'):format(i, isOn and '✓' or ''),
                txt = isOn and 'Toggle OFF' or 'Toggle ON',
                params = { event = 'qb-livery:client:toggle-extra', args = { index = i, state = not isOn } }
            }
        end
    end

    if not any then
        Notify('This vehicle has no extras.', 'error')
        return
    end

    if Config.UseQbMenu then
        local qbMenu = { { header = 'Vehicle Extras', isMenuHeader = true } }
        for i = 1, #items do qbMenu[#qbMenu + 1] = items[i] end
        qbMenu[#qbMenu + 1] = { header = 'Close', params = { event = 'qb-menu:client:closeMenu' } }
        exports['qb-menu']:openMenu(qbMenu)
    else
        Notify('qb-menu not found. Install qb-menu for the extras UI.', 'error')
    end
end

RegisterNetEvent('qb-livery:client:toggle-extra', function(data)
    local veh = GetDriverVehicle()
    if veh == 0 then return Notify('No vehicle / not driver.', 'error') end
    local idx = tonumber(data.index or -1) or -1
    if idx < 0 then return end
    if not DoesExtraExist(veh, idx) then
        return Notify(('Extra %d does not exist on this vehicle.'):format(idx), 'error')
    end
    local enable = data.state and true or false
    -- SetVehicleExtra(vehicle, extraId, disable)
    SetVehicleExtra(veh, idx, not enable)
    Notify(enable and ('Enabled Extra %d.'):format(idx) or ('Disabled Extra %d.'):format(idx), 'success')
end)

RegisterCommand('extras', function()
    openExtrasMenu()
end, false)

TriggerEvent('chat:addSuggestion', '/extras', 'Open the extras menu for the vehicle you are driving.')
