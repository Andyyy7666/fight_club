NDCore = exports["ND_Core"]:GetCoreObject() -- only needed if using a framework.

config = {
    winPrize = 10000,
    playPrice = 2500,

    pay = function(self, source)
        local player = NDCore.Functions.GetPlayer(source) -- get player info
        if player.cash >= self.playPrice then -- check if can pay
            NDCore.Functions.DeductMoney(self.playPrice, source, "cash") -- pay cash
            return true -- can pay
        end
        return false -- can't pay
    end,

    win = function(self, source)
        NDCore.Functions.AddMoney(self.winPrize, source, "cash")
    end
}