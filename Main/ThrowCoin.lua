--[[
    Throw a Coin v1.0.0
    Dev script by HorizonTeam
]]

-- Section Inisialisasi Layanan
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local HorizonUnloaded = false

-- CONFIG
local Config = {
    AutoFarm = false,
    CoinType = "",
    ShowReward = true,
    AntiAFK = false,
    AutoSell = false,
    AutoSellDelay = 300,
    AutoUpgradeLuck = false,
    AutoUpgradeValue = false,
    ThrowDelay = 1,
    BypassAnim = false,
    SellMethod = "Biasa (Sell All)",
    FountainID = 3,
}

local MyRevealFunction

-- LOAD UI
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)
assert(success and type(WindUI) == "table", "Gagal memuat WindUI! Pastikan koneksi internet stabil.")

-- WINDOW INIT
local Window = WindUI:CreateWindow({
    Title = "Horizon Hub X Throw a Coin",
    Author = "@HorizonTeam",
    Folder = "HorizonDevConfig",
    Size = UDim2.fromOffset(750, 460),
    Transparent = false,
    Theme = "Dark",
    SideBarWidth = 200,
    HasOutline = false
})

-- FPS & Ping Tags removed to optimize performance (already in Overlay)
-- VERSION TAG
local VersionTeg = Window:Tag({
    Title = "v1.0.0",
    Color = Color3.fromRGB(190, 140, 255),
})

-- TAB DASHBOARD
local TabDashboard = Window:Tab({Title = "Dashboard", Icon = "layout-dashboard"})
local SectionWelcome = TabDashboard:Section({Title = "System Information", Icon = "info", Opened = true})
SectionWelcome:Paragraph({
    Title = "Welcome to Horizon Hub, " .. LocalPlayer.Name .. "!",
    Desc = "Script eksklusif dengan optimasi tingkat tinggi. Gunakan menu di samping untuk menavigasi seluruh fitur yang tersedia."
})
local execName = "Unknown Executor"
pcall(function()
    if identifyexecutor then
        execName = tostring(identifyexecutor())
    end
end)

-- Environment
local uncScore = 0
local sUncScore = 0
pcall(function()
    local genv = getgenv and getgenv() or _G
    
    -- Unc
    local uncList = {
        "getnamecallmethod", "hookmetamethod", "newcclosure", "checkcaller",
        "getrawmetatable", "setrawmetatable", "setreadonly", "isreadonly",
        "identifyexecutor", "request", "readfile", "writefile", "listfiles",
        "isfile", "isfolder", "makefolder", "delfile", "delfolder",
        "setclipboard", "getcustomasset", "Drawing", "mouse1click", "fireclickdetector",
        "getinstances", "getnilinstances", "gethui", "gethiddenproperty", "sethiddenproperty",
        "getthreadidentity", "setthreadidentity", "cloneref", "compareinstances"
    }
    
    -- sUnc
    local sUncList = {
        "cache.invalidate", "cache.iscached", "cache.replace", 
        "debug.getupvalue", "debug.setupvalue", "debug.getconstant", "debug.setconstant",
        "debug.getinfo", "debug.getproto", "debug.getstack", "debug.setstack",
        "hookfunction", "clonefunction", "restorefunction", "isXClosure"
    }
    
    local function checkExist(name)
        local parts = string.split(name, ".")
        if #parts == 1 then
            return genv[name] ~= nil
        else
            local lib = genv[parts[1]]
            return type(lib) == "table" and lib[parts[2]] ~= nil
        end
    end
    
    local countUnc = 0
    for _, v in ipairs(uncList) do if checkExist(v) then countUnc += 1 end end
    uncScore = math.floor((countUnc / #uncList) * 100)
    
    local countSUnc = 0
    for _, v in ipairs(sUncList) do if checkExist(v) then countSUnc += 1 end end
    sUncScore = math.floor((countSUnc / #sUncList) * 100)
end)

SectionWelcome:Paragraph({
    Title = "System Status & Environment",
    Desc = string.format(
        "Executor: %s\nStandard UNC: %d%%\nStrict sUNC: %d%%\nStatus Injeksi: Sukses\nVersi Engine: 1.1.0 (release)",
        execName, uncScore, sUncScore
    )
})

SectionWelcome:Paragraph({
    Title = "Developer Information",
    Desc = "Creator: -\nTeam: Horizon Team\nLanguage: Luau (Roblox)\nUI Library: WindUI"
})


-- TAB AUTO FARM / THROW COIN
local TabMain = Window:Tab({Title = "Main", Icon = "swords"})
local SectionFarm = TabMain:Section({Title = "Auto Farm", Icon = "coins", Opened = true})

SectionFarm:Toggle({
    Title = "Auto Throw Coin",
    Desc = "Otomatis melempar koin dengan hasil Perfect (x3)",
    Value = Config.AutoFarm,
    Callback = function(state)
        Config.AutoFarm = state
    end
})




SectionFarm:Slider({
    Title = "Throw Delay",
    Desc = "Kecepatan lempar koin",
    Step = 0.1,
    Value = {Min = 0.5, Max = 3, Default = Config.ThrowDelay},
    Callback = function(value)
        Config.ThrowDelay = value
    end
})

local CoinDropdown = SectionFarm:Dropdown({
    Title = "Coin Type",
    Desc = "Pilih koin yang ingin dilempar",
    Values = {},
    Value = Config.CoinType,
    Callback = function(val)
        Config.CoinType = val
    end
})

-- LOGIC SYNC COINS
task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local SyncEvent = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Events"):WaitForChild("SyncCoins")
    
    SyncEvent.OnClientEvent:Connect(function(coinsList)
        if type(coinsList) == "table" and not HorizonUnloaded then
            pcall(function()
                if CoinDropdown.Refresh then
                    CoinDropdown:Refresh(coinsList)
                end
            end)
        end
    end)
    pcall(function()
        SyncEvent:FireServer()
    end)
end)

SectionFarm:Toggle({
    Title = "Notifikasi Reward",
    Desc = "Tampilkan notifikasi saat mendapatkan item dari lemparan",
    Value = Config.ShowReward,
    Callback = function(state)
        Config.ShowReward = state
    end
})

SectionFarm:Toggle({
    Title = "Anti-AFK",
    Desc = "Mencegah game menganggapmu AFK",
    Value = Config.AntiAFK,
    Callback = function(state)
        Config.AntiAFK = state
    end
})

SectionFarm:Toggle({
    Title = "Bypass Animasi",
    Desc = "Menghapus visual item/animasi",
    Value = Config.BypassAnim,
    Callback = function(state)
        Config.BypassAnim = state
        pcall(function()
            if not getconnections then return end
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local Events = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Events")
            
            local RevealEvent = Events:FindFirstChild("ItemReveal")
            if RevealEvent then
                for _, conn in pairs(getconnections(RevealEvent.OnClientEvent)) do
                    if conn.Function ~= MyRevealFunction then
                        if state then conn:Disable() else conn:Enable() end
                    end
                end
            end
            
            local ThrowEvent = Events:FindFirstChild("ThrowCoinClient")
            if ThrowEvent then
                for _, conn in pairs(getconnections(ThrowEvent.OnClientEvent)) do
                    if state then conn:Disable() else conn:Enable() end
                end
            end
        end)
    end
})

local SectionShop = TabMain:Section({Title = "Shop & Upgrades", Icon = "shopping-cart", Opened = true})

SectionShop:Toggle({
    Title = "Auto Sell All",
    Desc = "Otomatis menjual seluruh item yang didapatkan",
    Value = Config.AutoSell,
    Callback = function(state) Config.AutoSell = state end
})



SectionShop:Slider({
    Title = "Jeda Auto Sell (Detik)",
    Desc = "Berapa detik sekali Auto Sell akan berjalan",
    Step = 1,
    Value = {Min = 1, Max = 300, Default = Config.AutoSellDelay},
    Callback = function(value)
        Config.AutoSellDelay = value
    end
})

local ToggleAutoLuck = SectionShop:Toggle({
    Title = "Auto Upgrade Luck",
    Desc = "Terus menerus membeli Luck Multiplier",
    Value = Config.AutoUpgradeLuck,
    Callback = function(state) Config.AutoUpgradeLuck = state end
})

local ToggleAutoValue = SectionShop:Toggle({
    Title = "Auto Upgrade Value",
    Desc = "Terus menerus membeli Value Multiplier",
    Value = Config.AutoUpgradeValue,
    Callback = function(state) Config.AutoUpgradeValue = state end
})

-- LOGIC ANTI-AFK
task.spawn(function()
    local VirtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        if Config.AntiAFK and not HorizonUnloaded then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end)
end)

-- LOGIC AUTO SELL
task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local SellAllEvent = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Events"):WaitForChild("SellAll")
    
    while true do
        task.wait(Config.AutoSellDelay or 5)
        if not HorizonUnloaded then
            if Config.AutoSell then
                pcall(function() SellAllEvent:FireServer() end)
            end
        end
    end
end)

-- LOGIC AUTO SHOP (UPGRADES)
task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RequestUpgradeEvent = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Events"):WaitForChild("RequestUpgrade")
    
    while task.wait(1) do
        if not HorizonUnloaded then
            if Config.AutoUpgradeLuck then
                pcall(function() RequestUpgradeEvent:FireServer("Luck Multiplier") end)
            end
            if Config.AutoUpgradeValue then
                pcall(function() RequestUpgradeEvent:FireServer("Value Multiplier") end)
            end
        end
    end
end)

-- LOGIC NOTIFIKASI KEUANGAN (AUTO DISABLE UPGRADE)
task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local PopupEvent = ReplicatedStorage:WaitForChild("DisplayPopup")
    
    PopupEvent.OnClientEvent:Connect(function(msg, dur)
        if not HorizonUnloaded then
            if type(msg) == "string" then
                if string.match(msg, "Insufficient") or string.match(msg, "afford") then
                    if Config.AutoUpgradeLuck or Config.AutoUpgradeValue then
                        Config.AutoUpgradeLuck = false
                        Config.AutoUpgradeValue = false
                        
                        pcall(function()
                            if ToggleAutoLuck and ToggleAutoLuck.SetValue then ToggleAutoLuck:SetValue(false) end
                            if ToggleAutoValue and ToggleAutoValue.SetValue then ToggleAutoValue:SetValue(false) end
                        end)
                        
                        WindUI:Notify({
                            Title = "Auto Shop Dihentikan",
                            Content = "Uang tidak cukup! Fitur Auto Upgrades dimatikan.",
                            Icon = "alert-triangle",
                            Duration = 5
                        })
                    end
                end
            end
        end
    end)
end)

-- LOGIC AUTO FARM
task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local CoinEvent = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Events"):WaitForChild("CoinLanded")
    
    while true do
        if Config.ThrowDelay and Config.ThrowDelay > 0 then
            task.wait(Config.ThrowDelay)
        else
            task.wait()
        end
        
        if Config.AutoFarm and not HorizonUnloaded then
            pcall(function()
                local pos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.new(-1160, 0.7, -176)
                CoinEvent:FireServer(3, pos, Config.CoinType, nil, nil)
            end)
        end
    end
end)

-- LOGIC NOTIF REWARD
MyRevealFunction = function(playerId, itemName, itemPos, data, something1, something2)
    if Config.ShowReward and not HorizonUnloaded then
        -- Cek apakah UserId cocok dengan akun kita
        if tostring(playerId) == tostring(LocalPlayer.UserId) then
            WindUI:Notify({
                Title = "Item Didapatkan!",
                Content = "Kamu mendapatkan: " .. tostring(itemName),
                Icon = "gift",
                Duration = 3
            })
        end
    end
end

task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RevealEvent = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Events"):WaitForChild("ItemReveal")
    
    RevealEvent.OnClientEvent:Connect(MyRevealFunction)
end)

-- TAB CONFIG
local TabConfig = Window:Tab({Title = "Configuration", Icon = "save"})
local SectionConfig = TabConfig:Section({Title = "Config Manager", Icon = "folder", Opened = true})

local HttpService = game:GetService("HttpService")
local folderName = "HorizonHub_Configs"

if makefolder and not isfolder(folderName) then
    makefolder(folderName)
end

local function getConfigs()
    local list = {}
    if listfiles and isfolder(folderName) then
        for _, file in ipairs(listfiles(folderName)) do
            if file:match("%.json$") then
                local name = file:match("([^/\\]+)%.json$")
                if name then table.insert(list, name) end
            end
        end
    end
    if #list == 0 then table.insert(list, "No Configs Found") end
    return list
end

local selectedConfig = ""
local configNameInput = ""

SectionConfig:Input({
    Title = "Config Name",
    Desc = "Ketik nama untuk file konfigurasi barumu",
    Placeholder = "",
    Callback = function(val)
        configNameInput = val
    end
})

SectionConfig:Button({
    Title = "Save Config",
    Desc = "Simpan settingan UI saat ini ke dalam folder Workspace",
    Callback = function()
        if configNameInput == "" then
            WindUI:Notify({Title = "Config Error", Content = "Nama config tidak boleh kosong!", Duration = 3})
            return
        end
        if writefile then
            local json = HttpService:JSONEncode(Config)
            writefile(folderName .. "/" .. configNameInput .. ".json", json)
            WindUI:Notify({Title = "Config Saved", Content = "Berhasil menyimpan: " .. configNameInput, Duration = 3})
        end
    end
})

SectionConfig:Dropdown({
    Title = "Select Config",
    Desc = "Pilih config untuk diload (Pastikan mengetik manual nama jika belum terupdate)",
    Values = getConfigs(),
    Value = "",
    Callback = function(val)
        selectedConfig = val
    end
})

SectionConfig:Button({
    Title = "Load Config",
    Desc = "Memuat settingan. (Catatan: Toggle di UI tidak akan berubah secara visual, tapi scriptnya sudah aktif!)",
    Callback = function()
        if selectedConfig ~= "" and selectedConfig ~= "No Configs Found" then
            if readfile and isfile(folderName .. "/" .. selectedConfig .. ".json") then
                local json = readfile(folderName .. "/" .. selectedConfig .. ".json")
                local loaded = HttpService:JSONDecode(json)
                for k, v in pairs(loaded) do
                    Config[k] = v
                end
                WindUI:Notify({Title = "Config Loaded", Content = "Berhasil memuat: " .. selectedConfig, Duration = 3})
            end
        end
    end
})

local SectionAutoLoad = TabConfig:Section({Title = "Auto Load", Icon = "refresh-cw", Opened = true})
SectionAutoLoad:Toggle({
    Title = "Enable Auto-Load",
    Desc = "Otomatis load config yang dipilih di atas setiap script ini di execute",
    Value = (isfile and isfile(folderName .. "/autoload.txt")) or false,
    Callback = function(state)
        if state then
            if selectedConfig ~= "" and selectedConfig ~= "No Configs Found" then
                if writefile then writefile(folderName .. "/autoload.txt", selectedConfig) end
                WindUI:Notify({Title = "Auto-Load Set", Content = "Akan otomatis memuat: " .. selectedConfig, Duration = 3})
            else
                WindUI:Notify({Title = "Error", Content = "Pilih config di dropdown terlebih dahulu!", Duration = 3})
            end
        else
            if isfile and isfile(folderName .. "/autoload.txt") and delfile then
                delfile(folderName .. "/autoload.txt")
                WindUI:Notify({Title = "Auto-Load Disabled", Content = "Auto-load dimatikan.", Duration = 3})
            end
        end
    end
})

-- AUTO LOAD LOGIC ON STARTUP
if isfile and readfile then
    if isfile(folderName .. "/autoload.txt") then
        local autoConf = readfile(folderName .. "/autoload.txt")
        if isfile(folderName .. "/" .. autoConf .. ".json") then
            local json = readfile(folderName .. "/" .. autoConf .. ".json")
            local loaded = HttpService:JSONDecode(json)
            for k, v in pairs(loaded) do Config[k] = v end
            -- Supaya tidak bentrok dengan notifikasi awal, kita spawn
            task.spawn(function()
                task.wait(2)
                WindUI:Notify({Title = "Auto-Load", Content = "Config " .. autoConf .. " telah dimuat secara otomatis!", Duration = 5})
            end)
        end
    end
end

-- TAB SETTINGS
local TabSettings = Window:Tab({Title = "Settings", Icon = "settings"})
local SectionInterface = TabSettings:Section({Title = "Interface", Icon = "monitor", Opened = true})
SectionInterface:Keybind({
    Title = "Toggle UI Key",
    Desc = "Pintasan untuk membuka/menutup (minimize) menu",
    Value = Enum.KeyCode.Insert,
    Callback = function(key)
        local success, keyCode = pcall(function() return Enum.KeyCode[key] end)
        if success and keyCode then
            Window:SetToggleKey(keyCode)
        end
    end
})

local SectionOverlay = TabSettings:Section({Title = "Overlay Info", Icon = "layout-dashboard", Opened = true})

SectionOverlay:Toggle({Title = "Show Watermark", Desc = "Menampilkan tulisan Horizon Hub", Value = getgenv().HZNShowWatermark or false, Callback = function(s) getgenv().HZNShowWatermark = s end})
SectionOverlay:Toggle({Title = "Show FPS & Ping", Desc = "Kinerja jaringan dan frame rate", Value = getgenv().HZNShowFPS or false, Callback = function(s) getgenv().HZNShowFPS = s end})
SectionOverlay:Toggle({Title = "Show Session Time", Desc = "Durasi bermain", Value = getgenv().HZNShowSession or false, Callback = function(s) getgenv().HZNShowSession = s end})
SectionOverlay:Toggle({Title = "Show Local Clock", Desc = "Waktu asli di dunia nyata", Value = getgenv().HZNShowClock or false, Callback = function(s) getgenv().HZNShowClock = s end})
SectionOverlay:Toggle({Title = "Show Memory (RAM)", Desc = "Penggunaan memori game", Value = getgenv().HZNShowRAM or false, Callback = function(s) getgenv().HZNShowRAM = s end})
SectionOverlay:Toggle({Title = "Show Player Count", Desc = "Jumlah pemain di server", Value = getgenv().HZNShowPlayers or false, Callback = function(s) getgenv().HZNShowPlayers = s end})
SectionOverlay:Toggle({Title = "Show Movement Speed", Desc = "Kecepatan karakter berjalan", Value = getgenv().HZNShowSpeed or false, Callback = function(s) getgenv().HZNShowSpeed = s end})

SectionOverlay:Dropdown({
    Title = "Overlay Position",
    Desc = "Pilih lokasi overlay di layar",
    Values = {"Top Left", "Top Right", "Bottom Left", "Bottom Right"},
    Value = getgenv().HorizonOverlayPos or "Top Left",
    Callback = function(val)
        getgenv().HorizonOverlayPos = val
        if getgenv().UpdateHorizonOverlayPosition then getgenv().UpdateHorizonOverlayPosition() end
    end
})

local SectionThemes = TabSettings:Section({Title = "Theme Customization", Icon = "palette", Opened = true})
-- Fitur ubah tema, WindUI mendukung SetTheme secara bawaan (Dark, Light, Rose, dll)
SectionThemes:Dropdown({
    Title = "Select UI Theme",
    Desc = "Ubah warna antarmuka WindUI secara instan",
    Values = {"Dark", "Light", "Rose", "Aqua", "Amethyst"},
    Value = "Dark",
    Callback = function(val)
        pcall(function() Window:SetTheme(val) end)
    end
})
local SectionDanger = TabSettings:Section({Title = "System & Security", Icon = "shield-alert", Opened = true})
SectionDanger:Button({
    Title = "Unload Hub Script",
    Desc = "Membersihkan GUI dari memori secara permanen dan mematikan ESP",
    Callback = function()
        -- Kita pakai Dialog untuk konfirmasi sebelum keluar
        Window:Dialog({
            Title = "Unload Confirmation",
            Content = "Apakah kamu yakin ingin mematikan script Horizon Hub ini secara total?",
            Buttons = {
                {
                    Title = "Yes, Unload",
                    Callback = function()
                        print("[Horizon] Menghentikan script...")
                        pcall(function() Window:Destroy() end)
                        local ui = game.CoreGui:FindFirstChild("WindUI") or PlayerGui:FindFirstChild("WindUI")
                        if ui then ui:Destroy() end
                        HorizonUnloaded = true
                        pcall(function()
                            game:GetService("StarterGui"):SetCore("SendNotification", {
                                Title = "Horizon Hub",
                                Text = "Terima kasih sudah menggunakan HorizonHub",
                                Duration = 5,
                            })
                        end)
                    end
                },
                {
                    Title = "Cancel",
                    Callback = function() end
                }
            }
        })
    end
})

Window:SelectTab(1)

-- NOTIF
if WindUI and WindUI.NotificationModule then
    WindUI.NotificationModule.Size = UDim2.new(0, 250, 1, -156)
    WindUI.NotificationModule.SizeLower = UDim2.new(0, 250, 1, -56)
    WindUI.NotificationModule.UIPadding = 8
    WindUI.NotificationModule.UICorner = 8
    WindUI:SetNotificationLower(true)

    task.spawn(function()
        local NotificationFrame = WindUI.NotificationGui:WaitForChild("Frame", 5) or WindUI.NotificationGui:FindFirstChildOfClass("Frame")
        if NotificationFrame then
            NotificationFrame.Position = UDim2.new(1, -15, 0, 56)
            local padding = NotificationFrame:FindFirstChildOfClass("UIPadding")
            if padding then
                padding.PaddingBottom = UDim.new(0, 15)
            end
        end
    end)

    local originalNew = WindUI.NotificationModule.New
    WindUI.NotificationModule.New = function(configNotif)
        local notification = originalNew(configNotif)
        local holder = WindUI.NotificationGui:FindFirstChildOfClass("Frame")
        if holder then
            task.spawn(function()
                task.wait()
                local children = holder:GetChildren()
                local lastChild
                for i = #children, 1, -1 do
                    local child = children[i]
                    if child:IsA("Frame") and child.Name ~= "UIPadding" and child.Name ~= "UIListLayout" then
                        lastChild = child
                        break
                    end
                end
                if lastChild then
                    local r = lastChild:FindFirstChildOfClass("ImageLabel")
                    if r then
                        for _, child in ipairs(r:GetChildren()) do
                            if child:IsA("ImageLabel") and child.Name ~= "Background" then
                                child.Size = UDim2.new(0, 14, 0, 14)
                            elseif child:IsA("ImageButton") then
                                child.Size = UDim2.new(0, 10, 0, 10)
                            end
                        end
                        local p = r:FindFirstChildOfClass("Frame")
                        if p then
                            for _, txt in ipairs(p:GetChildren()) do
                                if txt:IsA("TextLabel") then
                                    if txt.TextSize == 18 then
                                        txt.TextSize = 12
                                    elseif txt.TextSize == 15 then
                                        txt.TextSize = 9
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
        return notification
    end
end

WindUI:Notify({
    Title = "Horizon Hub",
    Content = "Semua modul berhasil dimuat!",
    Icon = "cpu",
    Duration = 10
})

-- MODULE RETURN
local ThrowCoinModule = {}

-- ==========================================
-- OVERLAY SYSTEM
-- ==========================================
if not getgenv().HorizonOverlaySetup2 then
    getgenv().HorizonOverlaySetup2 = true
    getgenv().HorizonOverlayPos = getgenv().HorizonOverlayPos or "Top Left"
    getgenv().HZNSessionStart = getgenv().HZNSessionStart or os.time()

    local OverlayGui = Instance.new("ScreenGui")
    OverlayGui.Name = "HorizonHubOverlay"
    OverlayGui.ResetOnSpawn = false
    OverlayGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local CoreGui = game:GetService("CoreGui")
    if CoreGui:FindFirstChild("HorizonHubOverlay") then
        CoreGui.HorizonHubOverlay:Destroy()
    end
    OverlayGui.Parent = CoreGui

    local OverlayText = Instance.new("TextLabel")
    OverlayText.Parent = OverlayGui
    OverlayText.BackgroundTransparency = 1
    OverlayText.Size = UDim2.new(0, 300, 0, 300)
    OverlayText.Font = Enum.Font.GothamBold
    OverlayText.TextSize = 14
    OverlayText.TextColor3 = Color3.new(1, 1, 1)
    OverlayText.TextStrokeTransparency = 0.5
    OverlayText.TextXAlignment = Enum.TextXAlignment.Left
    OverlayText.TextYAlignment = Enum.TextYAlignment.Top
    OverlayText.Visible = true

    getgenv().UpdateHorizonOverlayPosition = function()
        local pos = getgenv().HorizonOverlayPos
        if pos == "Top Left" then
            OverlayText.Position = UDim2.new(0, 10, 0, 10)
            OverlayText.TextXAlignment = Enum.TextXAlignment.Left
            OverlayText.TextYAlignment = Enum.TextYAlignment.Top
        elseif pos == "Top Right" then
            OverlayText.Position = UDim2.new(1, -310, 0, 10)
            OverlayText.TextXAlignment = Enum.TextXAlignment.Right
            OverlayText.TextYAlignment = Enum.TextYAlignment.Top
        elseif pos == "Bottom Left" then
            OverlayText.Position = UDim2.new(0, 10, 1, -310)
            OverlayText.TextXAlignment = Enum.TextXAlignment.Left
            OverlayText.TextYAlignment = Enum.TextYAlignment.Bottom
        elseif pos == "Bottom Right" then
            OverlayText.Position = UDim2.new(1, -310, 1, -310)
            OverlayText.TextXAlignment = Enum.TextXAlignment.Right
            OverlayText.TextYAlignment = Enum.TextYAlignment.Bottom
        end
    end
    getgenv().UpdateHorizonOverlayPosition()

    local RunService = game:GetService("RunService")
    local Stats = game:GetService("Stats")
    local Players = game:GetService("Players")
    
    local lastUpdate = 0
    local frames = 0
    RunService.Heartbeat:Connect(function(deltaTime)
        frames = frames + 1
        if os.clock() - lastUpdate >= 1 then
            local str = ""
            
            if getgenv().HZNShowWatermark then
                str = str .. "Horizon Hub | Premium\n"
            end
            if getgenv().HZNShowFPS then
                local ping = 0
                pcall(function() ping = math.round(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
                str = str .. string.format("FPS: %d | Ping: %d ms\n", frames, ping)
            end
            if getgenv().HZNShowSession then
                local sec = os.time() - getgenv().HZNSessionStart
                local h = math.floor(sec / 3600)
                local m = math.floor((sec % 3600) / 60)
                local s = sec % 60
                str = str .. string.format("Session: %02d:%02d:%02d\n", h, m, s)
            end
            if getgenv().HZNShowClock then
                local date = os.date("*t")
                str = str .. string.format("Time: %02d:%02d:%02d\n", date.hour, date.min, date.sec)
            end
            if getgenv().HZNShowRAM then
                local mem = 0
                pcall(function() mem = math.round(Stats:GetTotalMemoryUsageMb()) end)
                str = str .. string.format("RAM: %d MB\n", mem)
            end
            if getgenv().HZNShowPlayers then
                str = str .. string.format("Players: %d/%d\n", #Players:GetPlayers(), Players.MaxPlayers)
            end
            if getgenv().HZNShowSpeed then
                local speed = 0
                pcall(function()
                    local char = Players.LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        speed = math.round(char.HumanoidRootPart.Velocity.Magnitude)
                    end
                end)
                str = str .. string.format("Speed: %d\n", speed)
            end
            
            OverlayText.Text = str
            frames = 0
            lastUpdate = os.clock()
        end
    end)
end

return ThrowCoinModule
