-- HORIZON HUB — UNIVERSAL SCRIPT LOADER
-- GitHub: https://github.com/JustSEMI/HorizonHub

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

local SupportedGames = {
    [111385005478215] = {
        Name = "Fish and Monster",
        ScriptPath = "HH/111385005478215.lua",
        GithubURLs = {
            "https://raw.githubusercontent.com/JustSEMI/HorizonHub/main/HH/111385005478215.lua"
        }
    },
    ["111385005478215"] = {
        Name = "Fish and Monster",
        ScriptPath = "HH/111385005478215.lua",
        GithubURLs = {
            "https://raw.githubusercontent.com/JustSEMI/HorizonHub/main/HH/111385005478215.lua"
        }
    }
}

local currentGameId = game.GameId
local currentPlaceId = game.PlaceId

local function getSupportedGame(id)
    if not id then return nil end
    return SupportedGames[id] or SupportedGames[tostring(id)] or SupportedGames[tonumber(id)]
end

local targetGame = getSupportedGame(currentGameId) or getSupportedGame(currentPlaceId)

if not targetGame then
    pcall(function()
        local info = MarketplaceService:GetProductInfo(currentPlaceId)
        if info and info.Name then
            local nameLower = tostring(info.Name):lower()
            if nameLower:find("fish") and (nameLower:find("monst") or nameLower:find("horizon")) then
                print("[Horizon Hub Loader] Auto-detected game by title: " .. tostring(info.Name))
                targetGame = SupportedGames[111385005478215] or SupportedGames["111385005478215"]
            end
        end
    end)
end

if not targetGame then
    local autoPath = "HH/" .. tostring(currentGameId) .. ".lua"
    local autoPlacePath = "HH/" .. tostring(currentPlaceId) .. ".lua"
    local localDevPath = "d:/LUA/HH/" .. tostring(currentGameId) .. ".lua"
    
    if (isfile and isfile(autoPath)) or (isfile and isfile(localDevPath)) then
        targetGame = {
            Name = "Local Game (" .. tostring(currentGameId) .. ")",
            ScriptPath = autoPath,
            GithubURLs = {
                "https://raw.githubusercontent.com/JustSEMI/HorizonHub/main/HH/" .. tostring(currentGameId) .. ".lua"
            }
        }
    elseif isfile and isfile(autoPlacePath) then
        targetGame = {
            Name = "Local Place (" .. tostring(currentPlaceId) .. ")",
            ScriptPath = autoPlacePath,
            GithubURLs = {
                "https://raw.githubusercontent.com/JustSEMI/HorizonHub/main/HH/" .. tostring(currentPlaceId) .. ".lua"
            }
        }
    end
end

if targetGame then
    print("[Horizon Hub Loader] Memuat script untuk: " .. tostring(targetGame.Name))
    
    local scriptLoaded = false
    
    local localPathsToTry = {
        targetGame.ScriptPath,
        "d:/LUA/" .. targetGame.ScriptPath
    }
    
    for _, path in ipairs(localPathsToTry) do
        if not scriptLoaded and isfile and isfile(path) then
            local success, err = pcall(function()
                local rawContent = readfile(path)
                if rawContent then
                    rawContent = rawContent:gsub("^\239\187\191", "")
                    local fn, syntaxErr = loadstring(rawContent)
                    if fn then
                        fn()
                        scriptLoaded = true
                        print("[Horizon Hub Loader] Berhasil dimuat dari file lokal: " .. tostring(path))
                    else
                        warn("[Horizon Hub Loader] Syntax error lokal (" .. tostring(path) .. "): " .. tostring(syntaxErr))
                    end
                end
            end)
            if not success then
                warn("[Horizon Hub Loader] Error saat eksekusi file lokal (" .. tostring(path) .. "): " .. tostring(err))
            end
        end
    end
    
    if not scriptLoaded and targetGame.GithubURLs then
        for _, url in ipairs(targetGame.GithubURLs) do
            if not scriptLoaded then
                local success, err = pcall(function()
                    local fetchUrl = url .. (url:find("?") and "&" or "?") .. "nocache=" .. tostring(tick())
                    local scriptContent = game:HttpGet(fetchUrl)
                    if scriptContent and #scriptContent > 50 and not scriptContent:find("<!DOCTYPE html>") then
                        scriptContent = scriptContent:gsub("^\239\187\191", "")
                        local fn, syntaxErr = loadstring(scriptContent)
                        if fn then
                            fn()
                            scriptLoaded = true
                            print("[Horizon Hub Loader] Berhasil dimuat dari GitHub: " .. tostring(url))
                        else
                            warn("[Horizon Hub Loader] Syntax error dari GitHub (" .. tostring(url) .. "): " .. tostring(syntaxErr))
                        end
                    end
                end)
                if not success then
                    warn("[Horizon Hub Loader] Coba fetch dari (" .. tostring(url) .. ") gagal: " .. tostring(err))
                end
            end
        end
    end
    
    if not scriptLoaded then
        pcall(function()
            local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
            if WindUI then
                WindUI:Notify({
                    Title = "LOADER ERROR",
                    Content = "Gagal memuat script untuk game ini.\nPastikan repository GitHub kamu sudah di-update dengan file loader.lua & 111385005478215.lua terbaru!",
                    Duration = 8,
                })
            end
        end)
    end
else
    warn("[Horizon Hub Loader] Game tidak didukung. GameId: " .. tostring(currentGameId) .. " | PlaceId: " .. tostring(currentPlaceId))
    
    pcall(function()
        if setclipboard then
            setclipboard(tostring(currentGameId))
        end
    end)
    
    pcall(function()
        local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
        if WindUI then
            WindUI:Notify({
                Title = "GAME BELUM DIDUKUNG",
                Content = "Horizon Hub belum mendukung game ini.\nGame ID (" .. tostring(currentGameId) .. ") | Place ID (" .. tostring(currentPlaceId) .. ") sudah disalin ke clipboard.",
                Duration = 8,
            })
        end
    end)
end
