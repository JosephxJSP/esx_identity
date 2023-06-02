local loadingScreenFinished = false
local script_name = GetCurrentResourceName()
local guiEnabled, isDead = false, false
local ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

AddEventHandler("esx:onPlayerDeath", function()
    isDead = true
end)
AddEventHandler("esx:onPlayerSpawn", function()
    isDead = false
end)

RegisterNetEvent("esx_identity:alreadyRegistered")
AddEventHandler("esx_identity:alreadyRegistered", function()
	while not loadingScreenFinished do
		Citizen.Wait(100)
	end
end)

AddEventHandler("esx:loadingScreenOff", function()
	loadingScreenFinished = true
end)

function EnableGui(state)
    SetNuiFocus(state, state)
    guiEnabled = state
    if state then
        TriggerScreenblurFadeIn(100.0)
        SendNUIMessage({
            type = "show",
            min_char = Config["MinChar"]
        })
    else
        TriggerScreenblurFadeOut(200.0)
    end
end

RegisterNetEvent("esx_identity:showRegisterIdentity")
AddEventHandler("esx_identity:showRegisterIdentity", function()
    TriggerEvent("esx_skin:resetFirstSpawn")

    if not isDead then
        EnableGui(true)
    end
end)

RegisterNUICallback("submit", function(data, cb)
    ESX.TriggerServerCallback("esx_identity:registerIdentity", function(callback)
        if callback then
            TriggerEvent("esx_skin:playerRegistered")
            EnableGui(false)
        end
    end, data)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if guiEnabled then
            DisableControlAction(0, 1,   true) -- LookLeftRight
            DisableControlAction(0, 2,   true) -- LookUpDown
            DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
            DisableControlAction(0, 142, true) -- MeleeAttackAlternate
            DisableControlAction(0, 30,  true) -- MoveLeftRight
            DisableControlAction(0, 31,  true) -- MoveUpDown
            DisableControlAction(0, 21,  true) -- disable sprint
            DisableControlAction(0, 24,  true) -- disable attack
            DisableControlAction(0, 25,  true) -- disable aim
            DisableControlAction(0, 47,  true) -- disable weapon
            DisableControlAction(0, 58,  true) -- disable weapon
            DisableControlAction(0, 263, true) -- disable melee
            DisableControlAction(0, 264, true) -- disable melee
            DisableControlAction(0, 257, true) -- disable melee
            DisableControlAction(0, 140, true) -- disable melee
            DisableControlAction(0, 141, true) -- disable melee
            DisableControlAction(0, 143, true) -- disable melee
            DisableControlAction(0, 75,  true) -- disable exit vehicle
            DisableControlAction(27, 75, true) -- disable exit vehicle
        end
    end
end)