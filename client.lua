local garageCoords = vector3(51.8718, -1057.1113, 28.6)
local bikeSpawnPositions = {
    vector3(47.6415, -1053.5491, 30.4275),
    vector3(46.9226, -1057.5236, 30.2454),
}
local bikeHeading = 244.4126

local garageNPC = 0
local isGarageActive = false

ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        ESX = exports["es_extended"]:getSharedObject()
        Citizen.Wait(0)
    end
end)

-- NPC
local NPC = { x = 51.8718, y = -1057.1113, z = 29.6, rotation = 250.0389, NetworkSync = false}
Citizen.CreateThread(function()
  modelHash = GetHashKey("csb_ramp_gang")
  RequestModel(modelHash)
  while not HasModelLoaded(modelHash) do
       Wait(1)
  end
  createNPC() 
end)

function createNPC()
	created_ped = CreatePed(0, modelHash , NPC.x,NPC.y,NPC.z - 1, NPC.rotation, NPC.NetworkSync)
	FreezeEntityPosition(created_ped, true)
	SetEntityInvincible(created_ped, true)
	SetBlockingOfNonTemporaryEvents(created_ped, true)
	TaskStartScenarioInPlace(created_ped, "WORLD_HUMAN_COP_IDLES", 0, true)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = GetDistanceBetweenCoords(playerCoords, garageCoords, true)

        if distance < 2.0 then
            ESX.ShowHelpNotification("Presiona ~r~E ~s~para abrir el garage")

            if IsControlJustReleased(0, 38) then
                if not isGarageActive then
                    local randomPosition = bikeSpawnPositions[math.random(#bikeSpawnPositions)]
                    SpawnVehicle("r1", randomPosition, bikeHeading)
                    isGarageActive = true
                end
            end
        else
            if isGarageActive then
                isGarageActive = false
            end
        end
    end
end)

function SpawnVehicle(model, coords, heading)
    RequestModel(model)

    while not HasModelLoaded(model) do
        Wait(500)
    end

    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
end
