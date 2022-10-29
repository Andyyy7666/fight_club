local guardClothes = {
    {
        face = {0, 0},
        hair = {0, 0},
        hands = {0, 2},
        pants = {0, 0},
        shirt = {1, 1}
    },
    {
        face = {1, 2},
        hair = {1, 0},
        hands = {0, 4},
        pants = {0, 1},
        shirt = {1, 0}
    },
}
local clothes = guardClothes[math.random(1, #guardClothes)]
local fightOngoing = false

RegisterNetEvent("Andyyy:Clohes", function()
    local src = source
    TriggerClientEvent("Andyyy:Clohes", src, clothes, config.playPrice)
end)

RegisterNetEvent("Andyyy:startCompete", function()
    local src = source
    local canPay = config:pay(src)
    if fightOngoing then
        TriggerClientEvent("ox_lib:notify", src, {
            title = "Guard:",
            description = "You gotta wait for the curent fight to end brother.",
            type = "error",
            position = "bottom",
            duration = 3500
        })
        return
    elseif not canPay then
        TriggerClientEvent("ox_lib:notify", src, {
            title = "Guard:",
            description = "That's not enought money, bring $" .. config.playPrice .. " cash for a chance to win $" .. config.winPrize .. ".",
            type = "error",
            position = "bottom",
            duration = 5000
        })
        return
    end
    TriggerClientEvent("ox_lib:notify", src, {
        title = "Guard:",
        description = "Thank you champ, now get into the cage and win!",
        type = "success",
        position = "bottom",
        duration = 3000
    })
    TriggerClientEvent("Andyyy:paidConfirmed", src)
    fightOngoing = src
end)

RegisterNetEvent("Andyyy:fightEnd", function(win)
    local src = source
    if fightOngoing ~= src then return end
    if win then
        config:win(src)
        TriggerClientEvent("ox_lib:notify", src, {
            title = "Guard:",
            description = "Here you go, you fucking won $" .. config.winPrize .. ".",
            type = "success",
            position = "bottom",
            duration = 3000
        })
    end
    fightOngoing = false
end)