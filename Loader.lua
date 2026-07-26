--[[
    Loader HorizonHub
]]
local baseUrl = "https://raw.githubusercontent.com/JustSEMI/HorizonHub/refs/heads/main/Main/"

local scriptMap = {
    [128736949265057] = baseUrl .. "Gakuran.lua",
    [115681808123944] = baseUrl .. "ThrowCoin.lua"
}

local universalScript = baseUrl .. "Universal.lua"

local function loadHub()
    assert(game, "Environment Not Found.")
    local targetUrl = scriptMap[game.GameId] or scriptMap[game.PlaceId] or universalScript
    local success, response = pcall(function()
        return game:HttpGet(targetUrl)
    end)
    assert(success, "Failed to Download Script. Error: " .. tostring(response))
    local executeFunc, compileError = loadstring(response)
    assert(executeFunc, "Failed to Compile Script. Error: " .. tostring(compileError))
    executeFunc()
end

loadHub()