local ped 
local pedCoords
local guard
local clothing
local nearGuard = false
local lvl = 0
local guardLocation = vector4(-685.70, -858.74, 18.95, 100.05)
local fightStarted = false
local opps = {
    {
        `a_m_m_hillbilly_02`,
        `a_m_m_rurmeth_01`,
        `a_m_m_tennis_01`
    },
    {
        `a_m_m_soucent_01`,
        `a_m_m_beach_01`,
        `a_m_y_soucent_02`
    },
    {
        `a_m_y_jetski_01`,
        `a_m_y_surfer_01`,
        `a_m_y_beach_03`
    },
    {
        `s_m_y_prismuscl_01`,
        `s_m_y_marine_02`,
        `s_m_y_baywatch_01`
    },
    {
        `ig_tylerdix`,
        `a_m_y_musclbeac_01`,
        `a_m_y_musclbeac_02`
    },
    {
        `u_m_y_babyd`
    }
}
local oppHealth = {
    350,
    600,
    1000,
    1400,
    2800,
    2500
}
local spawnedOpps = {}
local control1, control2, control3, control4, control5, control6 = false, false, false, false, false, false

AddRelationshipGroup("opps")

function loadAnimDict(dict)
    if HasAnimDictLoaded(dict) then return end
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(1)
    end
end

function spawnWorker(model, location)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Wait(100)
    end
    guard = CreatePed(4, model, location.x, location.y, location.z - 0.8, location.w, false, false)

    SetPedCanBeTargetted(guard, false)
    SetEntityCanBeDamaged(guard, false)
    SetBlockingOfNonTemporaryEvents(guard, true)
    SetPedCanRagdollFromPlayerImpact(guard, false)
    SetPedResetFlag(guard, 249, true)
    SetPedConfigFlag(guard, 185, true)
    SetPedConfigFlag(guard, 108, true)
    SetPedConfigFlag(guard, 208, true)

    loadAnimDict("anim@amb@casino@valet_scenario@pose_d@")
    TaskPlayAnim(guard, "anim@amb@casino@valet_scenario@pose_d@", "base_a_m_y_vinewood_01", 2.0, 8.0, -1, 1, 0, 0, 0, 0)

    if not clothing then Wait(1000) end
    if not clothing then return end
    SetPedComponentVariation(guard, 0, clothing.face[1], clothing.face[2], 0) -- face
    SetPedComponentVariation(guard, 2, clothing.hair[1], clothing.hair[2], 0) -- hair
    SetPedComponentVariation(guard, 3, clothing.hands[1], clothing.hands[2], 0) -- hands
    SetPedComponentVariation(guard, 4, clothing.pants[1], clothing.pants[2], 0) -- pants
    SetPedComponentVariation(guard, 8, clothing.shirt[1], clothing.shirt[2], 0) -- shirt
end


function loadOpp(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Wait(100)
    end
    local opp = CreatePed(4, model, -686.62, -866.25, 18.95, 353.08, true, false)
    SetPedRelationshipGroupHash(opp, `opps`)
    SetRelationshipBetweenGroups(0, `opps`, `PLAYER`)
    return opp
end

function startOpp(opp)
    TaskGoStraightToCoord(opp, vector3(-684.88, -857.73, 18.95), 1.1, 7000, 223.82, 0.01)
    TaskGoStraightToCoord(ped, vector3(-679.80, -862.53, 18.95), 1.0, 4000, 50.19, 0.01)

    Wait(7000)
    SetPedCombatAbility(opp, 3)
    SetPedCombatAttributes(opp, 46, true)
    SetPedCombatMovement(ped, 3)
    SetPedCombatRange(opp, 2)
    SetEntityMaxHealth(opp, oppHealth[lvl])
    SetEntityHealth(opp, oppHealth[lvl])
    TaskGoStraightToCoord(opp, pedCoords, 3.0, 1500, 223.82, 0.01)
    Wait(1500)
    SetRelationshipBetweenGroups(5, `opps`, `PLAYER`)
end

function startFight()
    local opp = loadOpp(opps[lvl][math.random(1, #opps[lvl])])
    spawnedOpps[#spawnedOpps + 1] = opp
    startOpp(opp)
    while GetEntityHealth(opp) > 0 and GetEntityHealth(ped) > 0 do
        Wait(100)
    end
    if GetEntityHealth(opp) == 0 then
        return true, opp
    else
        return false
    end
end

RegisterNetEvent("Andyyy:fadeOut", function(opp)
    Wait(10000)
    NetworkFadeOutEntity(opp, false, true)
    Wait(2000)
    DeletePed(opp)
end)

function endFight(win)
    fightStarted = false
    SendNUIMessage({
        type = "barStatus",
        display = false
    })
    TriggerServerEvent("Andyyy:fightEnd", win)
end

RegisterNetEvent("Andyyy:startFight", function()
    for i = 1, 6 do
        lvl = i
        local fight, opp = startFight()
        if not fight then
            lib.notify({
                title = "Guard:",
                description = "You lost, better luck next time.",
                type = "error",
                position = "bottom",
                duration = 3500
            })
            endFight(false)
            return
        end
        if i < 6 then
            lib.notify({
                title = "Guard:",
                description = "Round " .. i + 1 .. ", let's go!",
                type = "inform",
                position = "top",
                duration = 3500
            })
        end
        SetPedCanBeTargetted(opp, false)
        TriggerEvent("Andyyy:fadeOut", opp)
    end
    endFight(true)
end)

RegisterNetEvent("Andyyy:Clohes", function(clothes, price)
    playPrice = price
    clothing = clothes
end)

CreateThread(function()
    local wait = 500
    while true do
        Wait(wait)
        ped = PlayerPedId()
        pedCoords = GetEntityCoords(ped)
        local dist = #(pedCoords - vector3(guardLocation.x, guardLocation.y, guardLocation.z))
        if dist < 50.0 then
            if not guard then
                spawnWorker(`s_m_m_bouncer_01`, guardLocation)
            end
            if dist < 1.0 and not fightStarted then
                nearGuard = true
                lib.showTextUI("[E] - compete: $" .. playPrice)
            elseif nearGuard then
                nearGuard = false
                lib.hideTextUI()
            end
        else
            if nearGuard then
                nearGuard = false
                lib.hideTextUI()
            end
            DeletePed(guard)
            guard = nil
            startedPay = false
            fightStarted = false
        end
    end
end)

RegisterNetEvent("Andyyy:regen", function()
    finishedRegen = false
    Wait(3000)
    while barLevel < 100 and (not control1 and not control2 and not control3 and not control4 and not control5 and not control6) do
        Wait(10)
        barLevel = barLevel + 0.3
        SendNUIMessage({
            type = "barLevel",
            level = barLevel
        })
    end
    finishedRegen = true
end)

RegisterNetEvent("Andyyy:paidConfirmed", function()
    if not startedPay then return end
    startedPay = false
    fightStarted = true
    barLevel = 100
    finishedRegen = true
    TriggerEvent("Andyyy:startFight")

    Wait(3000)
    SendNUIMessage({
        type = "barStatus",
        display = true
    })

    while fightStarted do
        Wait(0)
        if barLevel < 0.0 then
            DisableControlAction(0, 24, true) -- INPUT_ATTACK
            DisableControlAction(0, 257, true) -- INPUT_ATTACK2
            DisableControlAction(0, 142, true) -- INPUT_MELEE_ATTACK_ALTERNATE
            DisableControlAction(0, 140, true) -- INPUT_MELEE_ATTACK_LIGHT
            DisableControlAction(0, 141, true) -- INPUT_MELEE_ATTACK_HEAVY
            DisableControlAction(0, 143, true) -- INPUT_MELEE_BLOCK
        end
        control1, control2, control3, control4, control5, control6 = IsControlJustPressed(0, 24), IsControlJustPressed(0, 142), IsControlJustPressed(0, 140), IsControlJustPressed(0, 141), IsControlPressed(0, 143), IsControlJustPressed(0, 257)
        if barLevel < 50 and (not control1 and not control2 and not control3 and not control4 and not control5 and not control6) and finishedRegen then
            TriggerEvent("Andyyy:regen")
        end
        if control1 or control2 or control6 or control3 or control4 then -- INPUT_ATTACK, INPUT_MELEE_ATTACK_ALTERNATE, INPUT_ATTACK2, INPUT_MELEE_ATTACK_LIGHT, INPUT_MELEE_ATTACK_HEAVY
            barLevel = barLevel - 15
            SendNUIMessage({
                type = "barLevel",
                level = barLevel
            })
        end
        if control5 then -- INPUT_MELEE_BLOCK
            barLevel = barLevel - 0.5
            SendNUIMessage({
                type = "barLevel",
                level = barLevel
            })
        end
    end
end)

CreateThread(function()
    local wait = 500
    while true do
        Wait(wait)
        if nearGuard then
            wait = 0
            if IsControlJustPressed(0, 51) then
                startedPay = true
                TriggerServerEvent("Andyyy:startCompete")
            end
        else
            wait = 500
        end
    end
end)
TriggerServerEvent("Andyyy:Clohes")

AddEventHandler("onResourceStop", function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    if guard then
        DeletePed(guard)
    end
    for _, opp in pairs(spawnedOpps) do
        DeletePed(opp)
    end
    if nearGuard then
        nearGuard = false
        lib.hideTextUI()
    end
end)
