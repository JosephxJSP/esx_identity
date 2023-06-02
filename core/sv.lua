local script_name = GetCurrentResourceName()
local playerIdentity = {}
local alreadyRegistered = {}
local ESX = nil
TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)

AddEventHandler("playerConnecting", function(playerName, setKickReason, deferrals)
    deferrals.defer()
    local playerId, identifier = source
    Citizen.Wait(100)

    for k,v in ipairs(GetPlayerIdentifiers(playerId)) do
        if string.match(v, "steam:") then
            identifier = v
            break
        end
    end

    if identifier then
        exports.mongodb:findOne({collection = "users", query = {identifier = identifier}, options = {projection = {firstname = 1, lastname = 1, dateofbirth = 1, sex = 1, height = 1}}}, function(success, result)
            if success then
                if #result > 0 then
                    if result[1].firstname then
                        playerIdentity[identifier] = {
                            firstName = result[1].firstname,
                            lastName = result[1].lastname,
                            dateOfBirth = result[1].dateofbirth,
                            sex = result[1].sex,
                            height = result[1].height
                        }
                        alreadyRegistered[identifier] = true
                        deferrals.done()
                    else
                        playerIdentity[identifier] = nil
                        alreadyRegistered[identifier] = false
                        deferrals.done()
                    end
                else
                    playerIdentity[identifier] = nil
                    alreadyRegistered[identifier] = false
                    deferrals.done()
                end
            else
                deferrals.done(("[ERROR] exports.mongodb:findOne => %s"):format(tostring(result)))
            end
        end)
    else
        deferrals.done(_U("no_identifier"))
    end
end)

AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        Citizen.Wait(1000)
        
        while not ESX do
            Citizen.Wait(10)
        end

        local xPlayers = ESX.GetPlayers()
        for i=1, #xPlayers, 1 do
            local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
            if xPlayer then	
                checkIdentity(xPlayer)
            end
        end
    end
end)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(playerId, xPlayer)
    local currentIdentity = playerIdentity[xPlayer.identifier]
    if currentIdentity and alreadyRegistered[xPlayer.identifier] == true then
        xPlayer.setName(("%s %s"):format(currentIdentity.firstName, currentIdentity.lastName))
        xPlayer.set("firstName", currentIdentity.firstName)
        xPlayer.set("lastName", currentIdentity.lastName)
        xPlayer.set("dateofbirth", currentIdentity.dateOfBirth)
        xPlayer.set("sex", currentIdentity.sex)
        xPlayer.set("height", currentIdentity.height)

        if currentIdentity.saveToDatabase then
            saveIdentityToDatabase(xPlayer.identifier, currentIdentity)
        end

        Citizen.Wait(10)
        TriggerClientEvent("esx_identity:alreadyRegistered", xPlayer.source)
        playerIdentity[xPlayer.identifier] = nil
    else
        TriggerClientEvent("esx_identity:showRegisterIdentity", xPlayer.source)
    end
end)

ESX.RegisterServerCallback("esx_identity:registerIdentity", function(source, cb, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        if not alreadyRegistered[xPlayer.identifier] then
            playerIdentity[xPlayer.identifier] = {
                firstName = data.firstname,
                lastName = data.lastname,
                dateOfBirth = data.dateofbirth,
                sex = data.sex,
                height = data.height
            }

            local currentIdentity = playerIdentity[xPlayer.identifier]
            xPlayer.setName(("%s %s"):format(currentIdentity.firstName, currentIdentity.lastName))
            xPlayer.set("firstName", currentIdentity.firstName)
            xPlayer.set("lastName", currentIdentity.lastName)
            xPlayer.set("dateofbirth", currentIdentity.dateOfBirth)
            xPlayer.set("sex", currentIdentity.sex)
            xPlayer.set("height", currentIdentity.height)

            saveIdentityToDatabase(xPlayer.identifier, currentIdentity)
            alreadyRegistered[xPlayer.identifier] = true
            playerIdentity[xPlayer.identifier] = nil
            cb(true)
        else
            cb(false)
        end
    else
        cb(false)
    end
end)

function checkIdentity(xPlayer)
    exports.mongodb:findOne({collection = "users", query = {identifier = identifier}, options = {projection = {firstname = 1, lastname = 1, dateofbirth = 1, sex = 1, height = 1}}}, function(success, result)
        if success then
            if #result > 0 then
                if result[1].firstname then
                    playerIdentity[xPlayer.identifier] = {
                        firstName = result[1].firstname,
                        lastName = result[1].lastname,
                        dateOfBirth = result[1].dateofbirth,
                        sex = result[1].sex,
                        height = result[1].height
                    }
                    alreadyRegistered[xPlayer.identifier] = true
                    setIdentity(xPlayer)
                else
                    playerIdentity[xPlayer.identifier] = nil
                    alreadyRegistered[xPlayer.identifier] = false
                    TriggerClientEvent("esx_identity:showRegisterIdentity", xPlayer.source)
                end
            else
                TriggerClientEvent("esx_identity:showRegisterIdentity", xPlayer.source)
            end
        else
            print(("[^1ERROR^7] exports.mongodb:findOne => %s"):format(tostring(result)))
        end
    end)
end

function setIdentity(xPlayer)
    if alreadyRegistered[xPlayer.identifier] then
        local currentIdentity = playerIdentity[xPlayer.identifier]
        xPlayer.setName(("%s %s"):format(currentIdentity.firstName, currentIdentity.lastName))
        xPlayer.set("firstName", currentIdentity.firstName)
        xPlayer.set("lastName", currentIdentity.lastName)
        xPlayer.set("dateofbirth", currentIdentity.dateOfBirth)
        xPlayer.set("sex", currentIdentity.sex)
        xPlayer.set("height", currentIdentity.height)

        if currentIdentity.saveToDatabase then
            saveIdentityToDatabase(xPlayer.identifier, currentIdentity)
        end
        playerIdentity[xPlayer.identifier] = nil
    end
end

function saveIdentityToDatabase(identifier, identity)
	exports.mongodb:updateOne({
		collection = "users", 
		query = {
			identifier = identifier
		}, 
		update = {
			["$set"] = {
				firstname = identity.firstName, 
				lastname = identity.lastName, 
				dateofbirth = identity.dateOfBirth, 
				sex = identity.sex, 
				height = identity.height
			}
		}
	})
end