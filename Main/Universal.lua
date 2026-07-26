--[[
    HorizonHub x Dev
    By HorizonHub
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local HorizonUnloaded = false
local Config = {
    -- Esp Config
    ESPEnabled = false,
    ESPHighlight = true,
    ESPHighlightFillAlpha = 55,
    ESPHighlightOutlineAlpha = 10,
    ESPBox = true,
    ESPBoxStyle = "Corner Box",
    ESPBoxThickness = 2,
    ESPName = false,
    ESPNameFormat = "Display + Username",
    ESPHealthBar = true,
    ESPTextSize = 13,
    ESPDistance = true,
    ESPMaxDistance = 1500,
    ESPTracer = false,
    ESPTracerOrigin = "Bottom Center",
    ESPTracerThickness = 1,
    ESPTracerThickness = 1,
    ESPUseTeamColor = false,
    ESPTransparency = 1,
    ESPBoxColor = Color3.fromRGB(255, 0, 0),
    ESPNameColor = Color3.fromRGB(255, 255, 255),
    ESPTracerColor = Color3.fromRGB(255, 0, 0),
    ESPDistanceColor = Color3.fromRGB(200, 200, 200),
    ESPTextFont = 1,
    ESPBoxFill = false,
    -- Aimbot Config
    AimbotEnabled = false,
    AimbotHitpart = "Head",
    AimbotSmoothness = 5,
    AimbotFOV = false,
    AimbotFOVRadius = 100,
    AimbotFOVColor = Color3.fromRGB(255, 255, 255),
    AimbotTeamCheck = true,
    AimbotWallCheck = true,
    -- Misc Config
    NoRecoil = false,
    NoSpread = false,
    NoRecoil = false,
    NoSpread = false,
    AimbotTeamCheck = true,
    AimbotWallCheck = true,
}
-- LOAD WINUI
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)
if not success or type(WindUI) ~= "table" then
    error("Failed to load WindUI! Please make sure your internet connection is stable.")
end
-- INIT
local Window = WindUI:CreateWindow({
    Title = "Horizon Hub X Dev",
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
    Title = "v1.1.0",
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

-- TAB AIMBOT
local TabAimbot = Window:Tab({Title = "Aimbot", Icon = "crosshair"})
local SectionMainAimbot = TabAimbot:Section({Title = "Aimbot", Icon = "target", Opened = true})
SectionMainAimbot:Toggle({
    Title = "Enable Aimbot",
    Desc = "Otomatis mengunci kamera atau tembakan ke musuh terdekat dari cursor",
    Value = Config.AimbotEnabled,
    Callback = function(state)
        Config.AimbotEnabled = state
    end
})
SectionMainAimbot:Dropdown({
    Title = "Target Hitpart",
    Desc = "Pilih letak penguncian (Hitpart) yang diinginkan",
    Values = {"Head", "Torso", "HumanoidRootPart"},
    Value = Config.AimbotHitpart,
    Callback = function(val)
        Config.AimbotHitpart = val
    end
})
SectionMainAimbot:Slider({
    Title = "Aimbot Smoothness",
    Desc = "Semakin tinggi angkanya, semakin natural pergerakan kamera (legit)",
    Step = 1,
    Value = {Min = 1, Max = 10, Default = Config.AimbotSmoothness},
    Callback = function(val)
        Config.AimbotSmoothness = val
    end
})

local SectionFOVAimbot = TabAimbot:Section({Title = "FOV Configuration", Icon = "circle"})

SectionFOVAimbot:Toggle({
    Title = "Show FOV Circle",
    Desc = "Menampilkan radius area jangkauan aimbot di layar",
    Value = Config.AimbotFOV,
    Callback = function(state)
        Config.AimbotFOV = state
    end
})

SectionFOVAimbot:Slider({
    Title = "FOV Radius",
    Desc = "Mengatur seberapa besar jangkauan aimbot mengunci target",
    Step = 1,
    Value = {Min = 10, Max = 500, Default = Config.AimbotFOVRadius},
    Callback = function(val)
        Config.AimbotFOVRadius = val
    end
})

SectionFOVAimbot:Colorpicker({
    Title = "FOV Circle Color",
    Desc = "Mengubah warna garis lingkaran FOV",
    Default = Config.AimbotFOVColor,
    Callback = function(val)
        Config.AimbotFOVColor = val
    end
})

local SectionTacticalAimbot = TabAimbot:Section({Title = "Tactical Checks", Icon = "shield"})

local TacticalStack = SectionTacticalAimbot:HStack({Title = "Tactical Checks Config"})

TacticalStack:Toggle({
    Title = "Team Check",
    Desc = "Abaikan teman",
    Value = Config.AimbotTeamCheck,
    Callback = function(state)
        Config.AimbotTeamCheck = state
    end
})

TacticalStack:Toggle({
    Title = "Wall Check",
    Desc = "Abaikan balik tembok",
    Value = Config.AimbotWallCheck,
    Callback = function(state)
        Config.AimbotWallCheck = state
    end
})
-- TAB VISUAL (ESP)
local TabVisual = Window:Tab({Title = "Visuals", Icon = "eye"})
local SectionMasterESP = TabVisual:Section({Title = "ESP (Extra-Sensory Perception)", Icon = "power", Opened = true})
SectionMasterESP:Toggle({
    Title = "Enable Player ESP",
    Desc = "Saklar utama untuk menyalakan/mematikan semua sistem visual pemain",
    Value = Config.ESPEnabled,
    Callback = function(state) Config.ESPEnabled = state end
})
SectionMasterESP:Toggle({
    Title = "Use Team Color",
    Desc = "Otomatis menggunakan warna tim musuh untuk semua ESP",
    Value = Config.ESPUseTeamColor,
    Callback = function(state) Config.ESPUseTeamColor = state end
})
SectionMasterESP:Slider({
    Title = "Master Transparency",
    Desc = "Tingkat transparan semua elemen 2D ESP",
    Step = 10,
    Value = {Min = 10, Max = 100, Default = (Config.ESPTransparency or 1) * 100},
    Callback = function(val) Config.ESPTransparency = val / 100 end
})
SectionMasterESP:Slider({
    Title = "Max Render Distance",
    Desc = "Batas maksimum jarak render (mengurangi lag)",
    Step = 50,
    Value = {Min = 200, Max = 5000, Default = Config.ESPMaxDistance},
    Callback = function(val) Config.ESPMaxDistance = val end
})

local SectionColorESP = TabVisual:Section({Title = "Color Settings", Icon = "palette"})
SectionColorESP:Colorpicker({
    Title = "Box Color", Default = Config.ESPBoxColor or Color3.new(1,0,0), Callback = function(val) Config.ESPBoxColor = val end
})
SectionColorESP:Colorpicker({
    Title = "Name Color", Default = Config.ESPNameColor or Color3.new(1,1,1), Callback = function(val) Config.ESPNameColor = val end
})
SectionColorESP:Colorpicker({
    Title = "Tracer Color", Default = Config.ESPTracerColor or Color3.new(1,0,0), Callback = function(val) Config.ESPTracerColor = val end
})
SectionColorESP:Colorpicker({
    Title = "Distance Color", Default = Config.ESPDistanceColor or Color3.new(0.8,0.8,0.8), Callback = function(val) Config.ESPDistanceColor = val end
})

local SectionInfoESP = TabVisual:Section({Title = "Player Information", Icon = "users"})
local InfoStack = SectionInfoESP:HStack({Title = "Display Options"})

InfoStack:Toggle({Title = "Show Name", Value = Config.ESPName, Callback = function(s) Config.ESPName = s end})
InfoStack:Toggle({Title = "Show Distance", Value = Config.ESPDistance, Callback = function(s) Config.ESPDistance = s end})
InfoStack:Toggle({Title = "Show Health Bar", Value = Config.ESPHealthBar, Callback = function(s) Config.ESPHealthBar = s end})

SectionInfoESP:Dropdown({
    Title = "Text Font Style",
    Values = {"UI", "System", "Plex", "Monospace"},
    Value = "System",
    Callback = function(val)
        if val == "UI" then Config.ESPTextFont = 0
        elseif val == "System" then Config.ESPTextFont = 1
        elseif val == "Plex" then Config.ESPTextFont = 2
        elseif val == "Monospace" then Config.ESPTextFont = 3 end
    end
})
SectionInfoESP:Slider({
    Title = "Text Size", Step = 1, Value = {Min = 10, Max = 25, Default = Config.ESPTextSize},
    Callback = function(val) Config.ESPTextSize = val end
})

local SectionDrawESP = TabVisual:Section({Title = "Graphic Rendering", Icon = "pen-tool"})
SectionDrawESP:Toggle({
    Title = "Character Highlight (Chams)",
    Desc = "Karakter musuh akan dilapisi warna yang tembus pandang",
    Value = Config.ESPHighlight,
    Callback = function(state) Config.ESPHighlight = state end
})
SectionDrawESP:Slider({
    Title = "Highlight Fill Alpha (%)", Step = 1, Value = {Min = 0, Max = 100, Default = Config.ESPHighlightFillAlpha or 55},
    Callback = function(val) Config.ESPHighlightFillAlpha = val end
})
SectionDrawESP:Slider({
    Title = "Highlight Outline Alpha (%)", Step = 1, Value = {Min = 0, Max = 100, Default = Config.ESPHighlightOutlineAlpha or 10},
    Callback = function(val) Config.ESPHighlightOutlineAlpha = val end
})
SectionDrawESP:Divider()
SectionDrawESP:Toggle({
    Title = "Target Box", Value = Config.ESPBox, Callback = function(state) Config.ESPBox = state end
})
SectionDrawESP:Toggle({
    Title = "Fill Box Inside", Value = Config.ESPBoxFill, Callback = function(state) Config.ESPBoxFill = state end
})
SectionDrawESP:Slider({
    Title = "Box Outline Thickness", Step = 1, Value = {Min = 1, Max = 5, Default = Config.ESPBoxThickness},
    Callback = function(val) Config.ESPBoxThickness = val end
})
SectionDrawESP:Divider()
SectionDrawESP:Toggle({
    Title = "Tracer Lines", Value = Config.ESPTracer, Callback = function(state) Config.ESPTracer = state end
})
SectionDrawESP:Dropdown({
    Title = "Tracer Origin", Values = {"Bottom Center", "Screen Center", "Top Center"}, Value = Config.ESPTracerOrigin,
    Callback = function(val) Config.ESPTracerOrigin = val end
})
SectionDrawESP:Slider({
    Title = "Tracer Thickness", Step = 1, Value = {Min = 1, Max = 5, Default = Config.ESPTracerThickness},
    Callback = function(val) Config.ESPTracerThickness = val end
})
-- TAB MISC
local TabMisc = Window:Tab({Title = "Misc", Icon = "box"})

local SectionGunMods = TabMisc:Section({Title = "Universal Gun Mods", Icon = "crosshair", Opened = true})
SectionGunMods:Toggle({
    Title = "No Recoil",
    Desc = "Menghilangkan getaran senjata (Hanya work di beberapa game yang pakai module)",
    Value = Config.NoRecoil,
    Callback = function(state) Config.NoRecoil = state end
})
SectionGunMods:Toggle({
    Title = "No Spread / High Accuracy",
    Desc = "Membuat peluru lurus 100% tanpa sebaran",
    Value = Config.NoSpread,
    Callback = function(state) Config.NoSpread = state end
})

-- TAB DEBUG
local TabDebug = Window:Tab({Title = "Terminal Debug", Icon = "terminal"})
local SectionUtils = TabDebug:Section({Title = "External Tools", Icon = "code", Opened = true})
SectionUtils:Button({
    Title = "Infinite Yield",
    Desc = "Meluncurkan script Admin Commands terlengkap (IY)",
    Callback = function()
        print("[Horizon] Memuat Infinite Yield...")
        local successIY = pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
        end)
        if not successIY then
            WindUI:Notify({Title = "Error", Content = "Gagal memuat Infinite Yield.", Duration = 3})
        end
    end
})
SectionUtils:Button({
    Title = "SimpleSpy (Safe Remote Spy)",
    Desc = "Melihat komunikasi jaringan rahasia (Bypass Anti-Cheat)",
    Callback = function()
        print("[Horizon] Memuat SimpleSpy...")
        local successSpy = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua"))()
        end)
        if not successSpy then
            WindUI:Notify({Title = "Error", Content = "Gagal memuat SimpleSpy.", Duration = 3})
        end
    end
})
SectionUtils:Button({
    Title = "Cobalt (Aggressive Spy)",
    Desc = "Remote spy agresif, rentan terdeteksi oleh beberapa anti-cheat",
    Callback = function()
        print("[Horizon] Memuat Cobalt...")
        local successCobalt = pcall(function()
            loadstring(game:HttpGet("https://github.com/notpoiu/cobalt/releases/latest/download/Cobalt.luau", true))()
        end)
        if not successCobalt then
            WindUI:Notify({Title = "Error", Content = "Gagal memuat Cobalt.", Duration = 3})
        end
    end
})
SectionUtils:Button({
    Title = "Grab All Remotes",
    Desc = "Mencari semua RemoteEvent/RemoteFunction dan menyimpannya ke file TXT",
    Callback = function()
        local count = 0
        local remoteNames = {}
        
        -- Cari di seluruh game
        for _, obj in ipairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                count = count + 1
                table.insert(remoteNames, "- " .. obj.Name .. " (" .. obj.ClassName .. ") | " .. obj:GetFullName())
            end
        end
        
        if count > 0 then
            -- Buat folder log jika belum ada
            local logFolder = "HorizonHub_Logs"
            if makefolder and not isfolder(logFolder) then makefolder(logFolder) end
            
            -- Susun isi text file
            local fileName = "RemoteSpy_" .. game.PlaceId .. ".txt"
            local logData = "=== BUKTI REMOTE UNTUK GAME " .. game.PlaceId .. " ===\n"
            logData = logData .. "Total Remote Ditemukan: " .. count .. "\n\n"
            logData = logData .. table.concat(remoteNames, "\n")
            
            -- Tulis ke file
            if writefile then
                writefile(logFolder .. "/" .. fileName, logData)
                WindUI:Notify({Title = "Success", Content = "Berhasil menemukan " .. count .. " Remotes.\nTersimpan di folder workspace: " .. logFolder .. "/" .. fileName, Duration = 5})
            else
                WindUI:Notify({Title = "Failed", Content = "Executor kamu tidak mendukung writefile!", Duration = 3})
            end
        else
            WindUI:Notify({Title = "Not Found", Content = "Tidak ada satupun Remote yang ditemukan di map ini.", Duration = 3})
        end
    end
})

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

-- Mengkonfigurasi modul notifikasi bawaan WindUI
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
    WindUI.NotificationModule.New = function(config)
        local notification = originalNew(config)
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

-- [INJECTED ESP ENGINE]
-- OPTIMIZED ESP ENGINE v3
local espFolder = Instance.new("Folder")
espFolder.Name = "GakuranESPFolder"
pcall(function() espFolder.Parent = game:GetService("CoreGui") end)
if not espFolder.Parent then espFolder.Parent = PlayerGui end
local espCache = {}
local lastESPUpdate = 0
local espFrameCounter = 0
local tracerDrawingsSupported = false
pcall(function()
    local test = Drawing.new("Line")
    test:Remove()
    tracerDrawingsSupported = true
end)
-- Lightweight hide helper
local function hideESPData(data)
    if data.Highlight then data.Highlight.Enabled = false end
    if data.Billboard then data.Billboard.Enabled = false end
    if data.NameBillboard then data.NameBillboard.Enabled = false end
    if data.Tracer then data.Tracer.Visible = false end
    if data.NameDrawing then data.NameDrawing.Visible = false end
    if data.InfoDrawing then data.InfoDrawing.Visible = false end
    if data.HealthBGDraw then data.HealthBGDraw.Visible = false end
    if data.HealthFillDraw then data.HealthFillDraw.Visible = false end
    if data.HealthTextDraw then data.HealthTextDraw.Visible = false end
end
local function safeRemoveDrawing(d)
    if d then pcall(function() d:Remove() end) end
end
local function removeESP(player)
    local data = espCache[player]
    if not data then return end
    if data.Highlight then pcall(function() data.Highlight:Destroy() end) end
    if data.Billboard then pcall(function() data.Billboard:Destroy() end) end
    if data.NameBillboard then pcall(function() data.NameBillboard:Destroy() end) end
    safeRemoveDrawing(data.Tracer)
    safeRemoveDrawing(data.NameDrawing)
    safeRemoveDrawing(data.InfoDrawing)
    safeRemoveDrawing(data.HealthBGDraw)
    safeRemoveDrawing(data.HealthFillDraw)
    safeRemoveDrawing(data.HealthTextDraw)
    espCache[player] = nil
end
Players.PlayerRemoving:Connect(removeESP)
local function createCornerLine(parent, name, size, pos)
    local f = Instance.new("Frame")
    f.Name = name
    f.Size = size
    f.Position = pos
    f.BorderSizePixel = 0
    f.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    f.Parent = parent
    return f
end
RunService.Heartbeat:Connect(function()
    if HorizonUnloaded then
        if espFolder then pcall(function() espFolder:Destroy() end) end
        for plr, data in pairs(espCache) do
            safeRemoveDrawing(data.Tracer)
            safeRemoveDrawing(data.NameDrawing)
            safeRemoveDrawing(data.InfoDrawing)
            safeRemoveDrawing(data.HealthBGDraw)
            safeRemoveDrawing(data.HealthFillDraw)
            safeRemoveDrawing(data.HealthTextDraw)
        end
        return
    end
    
    -- Teleport logic always runs, no throttle
    if isLoopTeleporting and selectedTeleportTarget then
        local ok, _ = pcall(function()
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local targetRoot = selectedTeleportTarget.Character and selectedTeleportTarget.Character:FindFirstChild("HumanoidRootPart")
            if myRoot and targetRoot then
                local lookVec = targetRoot.CFrame.LookVector
                local rightVec = targetRoot.CFrame.RightVector
                myRoot.CFrame = CFrame.new(
                    targetRoot.Position + (lookVec * (teleportOffsetZ or -3)) + (rightVec * (teleportOffsetX or 0)) + Vector3.new(0, teleportOffsetY or 0, 0),
                    targetRoot.Position
                )
            end
        end)
    end
    
    if isSpectating and selectedTeleportTarget then
        pcall(function()
            local cam = workspace.CurrentCamera
            local targetHum = selectedTeleportTarget.Character and selectedTeleportTarget.Character:FindFirstChild("Humanoid")
            if targetHum and cam.CameraSubject ~= targetHum then cam.CameraSubject = targetHum end
        end)
    end
    
    -- Throttle ESP instance management to every 0.2s
    if tick() - lastESPUpdate < 0.2 then return end
    lastESPUpdate = tick()
    
    if not Config.ESPEnabled then return end
    
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local espCol = Config.ESPColor or Color3.fromRGB(255, 255, 255)
    local boxThick = Config.ESPBoxThickness or 2
    local maxDist = Config.ESPMaxDistance or 1500
    local isCorner = (Config.ESPBoxStyle == "Corner Box")
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char then
            if espCache[plr] then hideESPData(espCache[plr]) end
            continue
        end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        local head = char:FindFirstChild("Head")
        
        if not root or not hum or hum.Health <= 0 then
            if espCache[plr] then hideESPData(espCache[plr]) end
            continue
        end
        
        local dist = myRoot and math.floor((myRoot.Position - root.Position).Magnitude) or 0
        if maxDist > 0 and dist > maxDist then
            if espCache[plr] then hideESPData(espCache[plr]) end
            continue
        end
        
        -- Create ESP objects (only once per character)
        if not espCache[plr] then
            local hl = Instance.new("Highlight")
            hl.Name = plr.Name .. "_HL"
            hl.Adornee = char
            hl.Parent = espFolder
            
            local bb = Instance.new("BillboardGui")
            bb.Name = plr.Name .. "_BoxBB"
            bb.Adornee = root
            bb.Size = UDim2.new(4, 0, 5.8, 0)
            bb.AlwaysOnTop = true
            bb.ClipsDescendants = false
            bb.Parent = espFolder
            
            local boxFrame = Instance.new("Frame")
            boxFrame.Name = "FullBox"
            boxFrame.Size = UDim2.new(1, 0, 1, 0)
            boxFrame.BackgroundTransparency = 1
            boxFrame.Parent = bb
            
            local stroke = Instance.new("UIStroke")
            stroke.Thickness = boxThick
            stroke.Parent = boxFrame
            
            local cornerHolder = Instance.new("Frame")
            cornerHolder.Name = "CornerHolder"
            cornerHolder.Size = UDim2.new(1, 0, 1, 0)
            cornerHolder.BackgroundTransparency = 1
            cornerHolder.Parent = bb
            
            local corners = {}
            local cLen, cThick = 0.22, boxThick
            table.insert(corners, createCornerLine(cornerHolder, "TL_H", UDim2.new(cLen, 0, 0, cThick), UDim2.new(0, 0, 0, 0)))
            table.insert(corners, createCornerLine(cornerHolder, "TL_V", UDim2.new(0, cThick, cLen, 0), UDim2.new(0, 0, 0, 0)))
            table.insert(corners, createCornerLine(cornerHolder, "TR_H", UDim2.new(cLen, 0, 0, cThick), UDim2.new(1 - cLen, 0, 0, 0)))
            table.insert(corners, createCornerLine(cornerHolder, "TR_V", UDim2.new(0, cThick, cLen, 0), UDim2.new(1, -cThick, 0, 0)))
            table.insert(corners, createCornerLine(cornerHolder, "BL_H", UDim2.new(cLen, 0, 0, cThick), UDim2.new(0, 0, 1, -cThick)))
            table.insert(corners, createCornerLine(cornerHolder, "BL_V", UDim2.new(0, cThick, cLen, 0), UDim2.new(0, 0, 1 - cLen, 0)))
            table.insert(corners, createCornerLine(cornerHolder, "BR_H", UDim2.new(cLen, 0, 0, cThick), UDim2.new(1 - cLen, 0, 1, -cThick)))
            table.insert(corners, createCornerLine(cornerHolder, "BR_V", UDim2.new(0, cThick, cLen, 0), UDim2.new(1, -cThick, 1 - cLen, 0)))
            
            local hbBG = Instance.new("Frame")
            hbBG.Name = "HealthBG"
            hbBG.Size = UDim2.new(0, 5, 1, 0)
            hbBG.Position = UDim2.new(0, -11, 0, 0)
            hbBG.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            hbBG.BorderSizePixel = 0
            hbBG.Parent = bb
            
            local hbStroke = Instance.new("UIStroke")
            hbStroke.Thickness = 1.2
            hbStroke.Color = Color3.new(0, 0, 0)
            hbStroke.Parent = hbBG
            
            local hbFill = Instance.new("Frame")
            hbFill.Name = "HealthFill"
            hbFill.Size = UDim2.new(1, 0, 1, 0)
            hbFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
            hbFill.BorderSizePixel = 0
            hbFill.Parent = hbBG
            
            local hbText = Instance.new("TextLabel")
            hbText.Name = "HealthText"
            hbText.Size = UDim2.new(0, 35, 0, 16)
            hbText.Position = UDim2.new(1, 3, 0, 0)
            hbText.BackgroundTransparency = 1
            hbText.Font = Enum.Font.GothamBold
            hbText.TextSize = 11
            hbText.TextColor3 = Color3.fromRGB(0, 255, 100)
            hbText.TextStrokeTransparency = 0
            hbText.TextStrokeColor3 = Color3.new(0, 0, 0)
            hbText.TextXAlignment = Enum.TextXAlignment.Left
            hbText.Parent = hbFill
            
            local nameBB = Instance.new("BillboardGui")
            nameBB.Name = plr.Name .. "_NameBB"
            nameBB.Adornee = head or root
            nameBB.Size = UDim2.new(12, 0, 2.5, 0)
            nameBB.ExtentsOffset = head and Vector3.new(0, 1.6, 0) or Vector3.new(0, 3.6, 0)
            nameBB.AlwaysOnTop = true
            nameBB.ClipsDescendants = false
            nameBB.Parent = espFolder
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Name = "NameLabel"
            nameLabel.Size = UDim2.new(1, 0, 0.55, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = Config.ESPTextSize or 14
            nameLabel.TextColor3 = Color3.new(1, 1, 1)
            nameLabel.TextStrokeTransparency = 0
            nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            nameLabel.ZIndex = 10
            nameLabel.Parent = nameBB
            
            local infoLabel = Instance.new("TextLabel")
            infoLabel.Name = "InfoLabel"
            infoLabel.Size = UDim2.new(1, 0, 0.45, 0)
            infoLabel.Position = UDim2.new(0, 0, 0.55, 0)
            infoLabel.BackgroundTransparency = 1
            infoLabel.Font = Enum.Font.GothamMedium
            infoLabel.TextSize = math.max(11, (Config.ESPTextSize or 14) - 1)
            infoLabel.TextColor3 = Color3.new(1, 1, 1)
            infoLabel.TextStrokeTransparency = 0
            infoLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            infoLabel.ZIndex = 10
            infoLabel.Parent = nameBB
            
            -- Drawing objects (created once, reused forever)
            local tracerLine, nameDraw, infoDraw, hbBGDraw, hbFillDraw, hbTextDraw
            if tracerDrawingsSupported then
                pcall(function()
                    tracerLine = Drawing.new("Line")
                    tracerLine.Thickness = 1.5
                    tracerLine.Transparency = 1
                    
                    nameDraw = Drawing.new("Text")
                    nameDraw.Center = true
                    nameDraw.Outline = true
                    nameDraw.Transparency = 1
                    
                    infoDraw = Drawing.new("Text")
                    infoDraw.Center = true
                    infoDraw.Outline = true
                    infoDraw.Transparency = 1
                    
                    hbBGDraw = Drawing.new("Square")
                    hbBGDraw.Filled = true
                    hbBGDraw.Color = Color3.fromRGB(25, 25, 25)
                    hbBGDraw.Transparency = 0.8
                    
                    hbFillDraw = Drawing.new("Square")
                    hbFillDraw.Filled = true
                    hbFillDraw.Transparency = 1
                    
                    hbTextDraw = Drawing.new("Text")
                    hbTextDraw.Size = 11
                    hbTextDraw.Outline = true
                    hbTextDraw.Transparency = 1
                end)
            end
            
            espCache[plr] = {
                Highlight = hl, Billboard = bb, NameBillboard = nameBB,
                BoxFrame = boxFrame, Stroke = stroke,
                CornerHolder = cornerHolder, Corners = corners,
                HealthBG = hbBG, HealthFill = hbFill, HealthText = hbText,
                NameLabel = nameLabel, InfoLabel = infoLabel,
                Tracer = tracerLine, NameDrawing = nameDraw, InfoDrawing = infoDraw,
                HealthBGDraw = hbBGDraw, HealthFillDraw = hbFillDraw, HealthTextDraw = hbTextDraw,
                -- Cached refs (updated each slow tick to avoid FindFirstChild in fast loop)
                _root = root, _hum = hum, _head = head, _char = char,
                _active = true
            }
        end
        
        local data = espCache[plr]
        -- Update cached refs every slow tick
        data._root = root
        data._hum = hum
        data._head = head
        data._char = char
        data._active = true
        
        -- Highlight (only update properties when they could have changed)
        local hl = data.Highlight
        if hl then
            hl.Adornee = char
            hl.FillColor = espCol
            hl.OutlineColor = Color3.new(1, 1, 1)
            hl.FillTransparency = (Config.ESPHighlightFillAlpha or 55) / 100
            hl.OutlineTransparency = (Config.ESPHighlightOutlineAlpha or 10) / 100
            hl.Enabled = Config.ESPHighlight
        end
        
        -- Billboard Box
        local bb2 = data.Billboard
        if bb2 then
            bb2.Adornee = root
            bb2.Enabled = true
            
            if data.BoxFrame and data.Stroke then
                data.BoxFrame.Visible = Config.ESPBox and not isCorner
                data.Stroke.Thickness = boxThick
                data.Stroke.Color = espCol
            end
            if data.CornerHolder then
                data.CornerHolder.Visible = Config.ESPBox and isCorner
                if data.CornerHolder.Visible then
                    for _, cf in ipairs(data.Corners) do
                        cf.BackgroundColor3 = espCol
                    end
                end
            end
        end
        
        -- Health Bar (Billboard side)
        local hpPct = math.clamp(hum.Health / (hum.MaxHealth > 0 and hum.MaxHealth or 100), 0, 1)
        local hpVal = math.floor(hum.Health)
        local hpColor = Color3.fromRGB(math.floor(255 * (1 - hpPct)), math.floor(255 * hpPct), 50)
        
        if data.HealthBG then
            data.HealthBG.Visible = Config.ESPHealthBar
            if data.HealthBG.Visible and data.HealthFill then
                data.HealthFill.Size = UDim2.new(1, 0, hpPct, 0)
                data.HealthFill.Position = UDim2.new(0, 0, 1 - hpPct, 0)
                data.HealthFill.BackgroundColor3 = hpColor
                if data.HealthText then
                    data.HealthText.Text = hpVal .. " HP"
                    data.HealthText.TextColor3 = hpColor
                end
            end
        end
        
        -- Cache HP values for fast loop
        data._hpPct = hpPct
        data._hpVal = hpVal
        data._hpColor = hpColor
        data._dist = dist
        
        -- Name Tag (Billboard side — slow update is fine for text)
        local nameStr
        local fmt = Config.ESPNameFormat or "Display + Username"
        if fmt == "Display Name Only" then nameStr = plr.DisplayName
        elseif fmt == "Username Only" then nameStr = plr.Name
        else nameStr = plr.DisplayName .. " (" .. plr.Name .. ")" end
        data._nameStr = nameStr
        data._infoStr = "[" .. dist .. "m] | HP: " .. hpVal
        
        local nbb = data.NameBillboard
        if nbb then
            nbb.Adornee = head or root
            nbb.ExtentsOffset = head and Vector3.new(0, 1.6, 0) or Vector3.new(0, 3.6, 0)
            nbb.Enabled = (Config.ESPName or Config.ESPDistance)
            
            if data.NameLabel then
                data.NameLabel.Visible = Config.ESPName
                data.NameLabel.Text = nameStr
                data.NameLabel.TextSize = Config.ESPTextSize or 14
                data.NameLabel.TextColor3 = espCol
            end
            if data.InfoLabel then
                data.InfoLabel.Visible = Config.ESPDistance
                data.InfoLabel.Text = data._infoStr
                data.InfoLabel.TextSize = math.max(11, (Config.ESPTextSize or 14) - 1)
            end
        end
    end
    
    -- Clean up ESP for players no longer in game
    for plr, _ in pairs(espCache) do
        if not plr.Parent then removeESP(plr) end
    end
end)
local renderEvent = RunService.RenderStepped or RunService.Heartbeat
renderEvent:Connect(function()
    if HorizonUnloaded then return end
    
    espFrameCounter = espFrameCounter + 1
    
    if not Config.ESPEnabled then
        -- Only hide once per disable (use frame counter trick)
        if espFrameCounter % 15 == 1 then
            for _, data in pairs(espCache) do hideESPData(data) end
        end
        return
    end
    
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local vpSize = camera.ViewportSize
    local espCol = Config.ESPColor or Color3.fromRGB(255, 255, 255)
    local tracerThick = Config.ESPTracerThickness or 1.5
    local textSize = Config.ESPTextSize or 14
    local showTracer = Config.ESPTracer
    local showName = Config.ESPName
    local showDist = Config.ESPDistance
    local showHealth = Config.ESPHealthBar
    
    -- Pre-calculate tracer origin (same for all players)
    local originX = vpSize.X * 0.5
    local originY = vpSize.Y
    local tracerOrigin = Config.ESPTracerOrigin
    if tracerOrigin == "Screen Center" then originY = vpSize.Y * 0.5
    elseif tracerOrigin == "Top Center" then originY = 0 end
    local tracerFrom = Vector2.new(originX, originY)
    
    for _, data in pairs(espCache) do
        local root = data._root
        local head = data._head
        
        if not data._active or not root or not root.Parent then
            -- Skip entirely — slow loop will clean up
            if data.Tracer then data.Tracer.Visible = false end
            if data.NameDrawing then data.NameDrawing.Visible = false end
            if data.InfoDrawing then data.InfoDrawing.Visible = false end
            if data.HealthBGDraw then data.HealthBGDraw.Visible = false end
            if data.HealthFillDraw then data.HealthFillDraw.Visible = false end
            if data.HealthTextDraw then data.HealthTextDraw.Visible = false end
            continue
        end
        
        local rootPos, onScreen = camera:WorldToViewportPoint(root.Position)
        
        if not onScreen or rootPos.Z <= 0 then
            if data.Tracer then data.Tracer.Visible = false end
            if data.NameDrawing then data.NameDrawing.Visible = false end
            if data.InfoDrawing then data.InfoDrawing.Visible = false end
            if data.HealthBGDraw then data.HealthBGDraw.Visible = false end
            if data.HealthFillDraw then data.HealthFillDraw.Visible = false end
            if data.HealthTextDraw then data.HealthTextDraw.Visible = false end
            -- Show billboard fallback for off-screen-ish cases handled by Roblox
            if data.NameBillboard then data.NameBillboard.Enabled = (showName or showDist) end
            continue
        end
        
        -- Tracer (smooth every frame)
        local tracer = data.Tracer
        if tracer then
            if showTracer then
                tracer.From = tracerFrom
                tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                tracer.Color = espCol
                tracer.Thickness = tracerThick
                tracer.Visible = true
            else
                tracer.Visible = false
            end
        end
        
        -- Head position for name tags
        local headTarget = head or root
        local headPos = camera:WorldToViewportPoint(headTarget.Position + Vector3.new(0, 1.8, 0))
        
        -- Drawing Name Tags (smooth position, text cached from slow loop)
        local nd = data.NameDrawing
        local id = data.InfoDrawing
        if nd and id then
            if headPos.Z > 0 and (showName or showDist) then
                -- Use Drawing text instead of Billboard (smoother)
                if data.NameBillboard then data.NameBillboard.Enabled = false end
                
                if showName then
                    nd.Text = data._nameStr or ""
                    nd.Size = textSize
                    nd.Position = Vector2.new(headPos.X, headPos.Y - textSize - 4)
                    nd.Color = espCol
                    nd.Visible = true
                else
                    nd.Visible = false
                end
                
                if showDist then
                    id.Text = data._infoStr or ""
                    id.Size = math.max(11, textSize - 1)
                    id.Position = Vector2.new(headPos.X, headPos.Y - 2)
                    id.Color = Color3.new(1, 1, 1)
                    id.Visible = true
                else
                    id.Visible = false
                end
            else
                nd.Visible = false
                id.Visible = false
                if data.NameBillboard then data.NameBillboard.Enabled = (showName or showDist) end
            end
        end
        
        -- Drawing Health Bar (smooth position)
        local hbg = data.HealthBGDraw
        local hbf = data.HealthFillDraw
        local hbt = data.HealthTextDraw
        if hbg and hbf and hbt then
            if showHealth then
                local legPos = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2.8, 0))
                local boxHeight = math.abs(headPos.Y - legPos.Y) * 1.15
                local boxLeft = rootPos.X - (boxHeight * 0.65 * 0.5)
                local boxTop = headPos.Y
                local hpPct = data._hpPct or 1
                local hpColor = data._hpColor or Color3.fromRGB(0, 255, 100)
                local hpVal = data._hpVal or 100
                
                hbg.Size = Vector2.new(4, boxHeight)
                hbg.Position = Vector2.new(boxLeft - 8, boxTop)
                hbg.Visible = true
                
                local fillH = boxHeight * hpPct
                hbf.Size = Vector2.new(4, fillH)
                hbf.Position = Vector2.new(boxLeft - 8, boxTop + boxHeight - fillH)
                hbf.Color = hpColor
                hbf.Visible = true
                
                hbt.Text = hpVal .. " HP"
                hbt.Position = Vector2.new(boxLeft - 38, boxTop + boxHeight - fillH - 6)
                hbt.Color = hpColor
                hbt.Visible = true
            else
                hbg.Visible = false
                hbf.Visible = false
                hbt.Visible = false
            end
        end
    end
end)

-- [INJECTED AIMBOT & ESP ENGINE]
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local camera = workspace.CurrentCamera

local Dev = {
    Drawings = {},
    Highlights = {}
}

-- Helpers
local function v2_new(x, y) return Vector2.new(x, y) end
local function c3_rgb(r, g, b) return Color3.fromRGB(r, g, b) end
local function m_floor(x) return math.floor(x) end
local function m_clamp(x, min, max) return math.clamp(x, min, max) end

local function createESP(player)
    if Dev.Drawings[player] then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.ZIndex = 1
    
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.ZIndex = 1
    
    local name = Drawing.new("Text")
    name.Center = true
    name.Outline = true
    name.Visible = false
    name.ZIndex = 2
    
    local distance = Drawing.new("Text")
    distance.Center = true
    distance.Outline = true
    distance.Visible = false
    distance.ZIndex = 2
    
    local hpText = Drawing.new("Text")
    hpText.Center = true
    hpText.Outline = true
    hpText.Visible = false
    hpText.ZIndex = 2
    
    local hpBg = Drawing.new("Line")
    hpBg.Visible = false
    hpBg.ZIndex = 1
    
    local hpBar = Drawing.new("Line")
    hpBar.Visible = false
    hpBar.ZIndex = 2
    
    Dev.Drawings[player] = {Box = box, Tracer = tracer, Name = name, Distance = distance, HpText = hpText, HpBg = hpBg, HpBar = hpBar}
    
    local hl = Instance.new("Highlight")
    hl.Name = "ESP_HL_" .. player.Name
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Enabled = false
    
    local parentGui = (gethui and gethui()) or CoreGui
    local successHL = pcall(function() hl.Parent = parentGui end)
    if not successHL then pcall(function() hl.Parent = LocalPlayer:WaitForChild("PlayerGui") end) end
    
    Dev.Highlights[player] = hl
end

local function removeESP(player)
    if Dev.Drawings[player] then
        for _, drawing in pairs(Dev.Drawings[player]) do
            drawing:Remove()
        end
        Dev.Drawings[player] = nil
    end
    if Dev.Highlights[player] then
        Dev.Highlights[player]:Destroy()
        Dev.Highlights[player] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then createESP(p) end
end

Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then createESP(p) end
end)

Players.PlayerRemoving:Connect(function(p)
    removeESP(p)
end)

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Transparency = 1

local isAiming = false
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isAiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isAiming = false
    end
end)

local function isVisible(targetPart)
    if not Config.AimbotWallCheck then return true end
    local origin = camera.CFrame.Position
    local dir = (targetPart.Position - origin)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, camera}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true
    
    local result = workspace:Raycast(origin, dir, raycastParams)
    if result and result.Instance then
        if result.Instance:IsDescendantOf(targetPart.Parent) then return true end
        return false
    end
    return true
end

RunService.Heartbeat:Connect(function(deltaTime)
    if HorizonUnloaded then
        FOVCircle.Visible = false
        for p, _ in pairs(Dev.Drawings) do removeESP(p) end
        return
    end
    
    local mouseLocation = UserInputService:GetMouseLocation()
    
    if Config.AimbotFOV then
        FOVCircle.Visible = true
        FOVCircle.Position = mouseLocation
        FOVCircle.Radius = Config.AimbotFOVRadius
        FOVCircle.Color = Config.AimbotFOVColor
    else
        FOVCircle.Visible = false
    end
    
    local closestTarget = nil
    local closestDist = Config.AimbotFOVRadius
    local myPos = camera.CFrame.Position
    
    local tAlpha = Config.ESPTransparency or 1
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local drawings = Dev.Drawings[player]
        local highlight = Dev.Highlights[player]
        if not drawings then continue end
        
        local char = player.Character
        local humanoid = char and char:FindFirstChild("Humanoid")
        local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
        
        local isValid = char and humanoid and humanoid.Health > 0 and root
        local isTeam = player.Team and player.Team == LocalPlayer.Team
        
        -- TEAM CHECK LOGIC
        if isValid and Config.AimbotTeamCheck and isTeam then
            isValid = false
        end
        
        if not isValid or not Config.ESPEnabled then
            for _, d in pairs(drawings) do d.Visible = false end
            if highlight then highlight.Enabled = false end
            continue
        end
        
        local distance3D = (myPos - root.Position).Magnitude
        if distance3D > Config.ESPMaxDistance then
            for _, d in pairs(drawings) do d.Visible = false end
            if highlight then highlight.Enabled = false end
            continue
        end
        
        -- Determine Colors
        local pColor = player.TeamColor and player.TeamColor.Color or Color3.new(1,1,1)
        local boxColor = Config.ESPUseTeamColor and pColor or Config.ESPBoxColor
        local nameColor = Config.ESPUseTeamColor and pColor or Config.ESPNameColor
        local tracerColor = Config.ESPUseTeamColor and pColor or Config.ESPTracerColor
        local distColor = Config.ESPUseTeamColor and pColor or Config.ESPDistanceColor
        
        -- CHAMS (HIGHLIGHT)
        if highlight then
            if Config.ESPHighlight then
                highlight.Enabled = true
                highlight.Adornee = char
                highlight.FillColor = boxColor
                highlight.OutlineColor = c3_rgb(255, 255, 255)
                highlight.FillTransparency = Config.ESPHighlightFillAlpha / 100
                highlight.OutlineTransparency = Config.ESPHighlightOutlineAlpha / 100
            else
                highlight.Enabled = false
            end
        end
        
        -- 2D ESP DRAWINGS
        local rootPos, onScreen = camera:WorldToViewportPoint(root.Position)
        if onScreen then
            local topPos, topOn = camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
            local botPos, botOn = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.5, 0))
            
            local height = math.abs(botPos.Y - topPos.Y)
            local width = height * 0.65
            
            if Config.ESPBox then
                drawings.Box.Size = v2_new(width, height)
                drawings.Box.Position = v2_new(rootPos.X - width/2, rootPos.Y - height/2)
                drawings.Box.Color = boxColor
                drawings.Box.Thickness = Config.ESPBoxThickness
                drawings.Box.Filled = Config.ESPBoxFill
                drawings.Box.Transparency = tAlpha
                drawings.Box.Visible = true
            else
                drawings.Box.Visible = false
            end
            
            if Config.ESPTracer then
                local originY = camera.ViewportSize.Y
                if Config.ESPTracerOrigin == "Screen Center" then originY = camera.ViewportSize.Y / 2
                elseif Config.ESPTracerOrigin == "Top Center" then originY = 0 end
                
                drawings.Tracer.From = v2_new(camera.ViewportSize.X / 2, originY)
                drawings.Tracer.To = v2_new(rootPos.X, rootPos.Y + (height/2))
                drawings.Tracer.Color = tracerColor
                drawings.Tracer.Thickness = Config.ESPTracerThickness
                drawings.Tracer.Transparency = tAlpha
                drawings.Tracer.Visible = true
            else
                drawings.Tracer.Visible = false
            end
            
            local textOffset = (height/2) + 5
            
            if Config.ESPName then
                local nFormat = Config.ESPNameFormat or "Display + Username"
                local nameStr = (nFormat == "Display + Username") and (player.DisplayName .. " (@" .. player.Name .. ")") or player.Name
                drawings.Name.Text = nameStr
                drawings.Name.Position = v2_new(rootPos.X, rootPos.Y - textOffset - Config.ESPTextSize)
                drawings.Name.Color = nameColor
                drawings.Name.Size = Config.ESPTextSize
                drawings.Name.Font = Config.ESPTextFont or 1
                drawings.Name.Transparency = tAlpha
                drawings.Name.Visible = true
            else
                drawings.Name.Visible = false
            end
            
            if Config.ESPHealthBar then
                local hp = humanoid.Health
                local maxHp = humanoid.MaxHealth
                local hpPercent = m_clamp(hp / maxHp, 0, 1)
                local r = (1 - hpPercent) * 255
                local g = hpPercent * 255
                local hColor = c3_rgb(r, g, 0)
                
                -- Visual Health Bar (Lines)
                local barX = (rootPos.X - width/2) - 6
                local barY = rootPos.Y - height/2
                
                drawings.HpBg.From = v2_new(barX, barY)
                drawings.HpBg.To = v2_new(barX, barY + height)
                drawings.HpBg.Color = c3_rgb(20, 20, 20)
                drawings.HpBg.Thickness = 3
                drawings.HpBg.Transparency = tAlpha
                drawings.HpBg.Visible = true
                
                local hpHeight = height * hpPercent
                drawings.HpBar.From = v2_new(barX, barY + height)
                drawings.HpBar.To = v2_new(barX, (barY + height) - hpHeight)
                drawings.HpBar.Color = hColor
                drawings.HpBar.Thickness = 1.5
                drawings.HpBar.Transparency = tAlpha
                drawings.HpBar.Visible = true
                
                -- Health Text
                drawings.HpText.Text = "HP: " .. m_floor(hp)
                drawings.HpText.Position = v2_new(rootPos.X, rootPos.Y + textOffset)
                drawings.HpText.Color = hColor
                drawings.HpText.Size = Config.ESPTextSize
                drawings.HpText.Font = Config.ESPTextFont or 1
                drawings.HpText.Transparency = tAlpha
                drawings.HpText.Visible = true
                textOffset = textOffset + Config.ESPTextSize
            else
                drawings.HpBg.Visible = false
                drawings.HpBar.Visible = false
                drawings.HpText.Visible = false
            end
            
            if Config.ESPDistance then
                drawings.Distance.Text = "[" .. m_floor(distance3D) .. " m]"
                drawings.Distance.Position = v2_new(rootPos.X, rootPos.Y + textOffset)
                drawings.Distance.Color = distColor
                drawings.Distance.Size = Config.ESPTextSize
                drawings.Distance.Font = Config.ESPTextFont or 1
                drawings.Distance.Transparency = tAlpha
                drawings.Distance.Visible = true
            else
                drawings.Distance.Visible = false
            end
        else
            for _, d in pairs(drawings) do d.Visible = false end
        end
        
        -- AIMBOT CALCULATION
        if Config.AimbotEnabled and isAiming then
            local hitpart = char:FindFirstChild(Config.AimbotHitpart) or root
            local targetPos = hitpart.Position
            
            -- Simple Prediction (Velocity)
            if root.Velocity.Magnitude > 0.5 then
                local travelTime = distance3D / 1500 -- Approx bullet velocity
                targetPos = targetPos + (root.Velocity * travelTime)
            end
            
            local aimPos, aimOnScreen = camera:WorldToViewportPoint(targetPos)
            if aimOnScreen then
                local dist2D = (v2_new(aimPos.X, aimPos.Y) - mouseLocation).Magnitude
                if dist2D < Config.AimbotFOVRadius and dist2D < closestDist then
                    if isVisible(hitpart) then
                        closestDist = dist2D
                        closestTarget = targetPos
                    end
                end
            end
        end
    end
    
    -- EXECUTE AIMBOT
    if Config.AimbotEnabled and isAiming and closestTarget then
        local smooth = Config.AimbotSmoothness
        if smooth < 1 then smooth = 1 end
        
        local sensitivity = smooth == 1 and 1 or (1 / (smooth * 1.5))
        if sensitivity > 1 then sensitivity = 1 end
        
        local aimCFrame = CFrame.new(camera.CFrame.Position, closestTarget)
        camera.CFrame = camera.CFrame:Lerp(aimCFrame, sensitivity)
    end
end)

-- [INJECTED MISC ENGINE]
-- Universal Gun Mods
task.spawn(function()
    while not HorizonUnloaded do
        if Config.NoRecoil or Config.NoSpread then
            for _, v in pairs(getgc(true)) do
                if type(v) == "table" then
                    pcall(function()
                        if rawget(v, "FireRate") or rawget(v, "MagSize") or rawget(v, "RecoilData") or rawget(v, "CameraKick") or rawget(v, "Spread") then
                            if setreadonly then setreadonly(v, false) end
                            
                            if Config.NoRecoil then
                                local recoilKeys = {
                                    "Recoil", "CameraRecoil", "CamKickMin", "CamKickMax", "AimCamKickMin", "AimCamKickMax",
                                    "RecoilMin", "RecoilMax", "AimRecoilMin", "AimRecoilMax", "ModelRecoil",
                                    "CameraKick", "AimCameraKick", "GunKick", "AimGunKick", "RecoilKick"
                                }
                                for _, key in ipairs(recoilKeys) do
                                    local val = rawget(v, key)
                                    if val ~= nil then
                                        if type(val) == "number" then v[key] = 0
                                        elseif typeof(val) == "Vector3" then v[key] = Vector3.zero
                                        elseif typeof(val) == "CFrame" then v[key] = CFrame.new()
                                        elseif type(val) == "table" then
                                            if setreadonly then setreadonly(val, false) end
                                            if rawget(val, "Min") then val.Min = 0 end
                                            if rawget(val, "Max") then val.Max = 0 end
                                        end
                                    end
                                end
                                
                                if rawget(v, "RecoilData") and type(v.RecoilData) == "table" then
                                    if setreadonly then setreadonly(v.RecoilData, false) end
                                    for key, val in pairs(v.RecoilData) do
                                        if type(val) == "number" then v.RecoilData[key] = 0 end
                                    end
                                end
                            end
                            
                            if Config.NoSpread then
                                local spreadKeys = {"Spread", "MinSpread", "MaxSpread", "AimSpread", "HipSpread", "RecoveryTime", "Bloom"}
                                for _, key in ipairs(spreadKeys) do
                                    local val = rawget(v, key)
                                    if val ~= nil then
                                        if type(val) == "number" then v[key] = 0
                                        elseif typeof(val) == "Vector3" then v[key] = Vector3.zero
                                        end
                                    end
                                end
                            end
                        end
                    end)
                end
            end
        end
        task.wait(2.5)
    end
end)

-- OVERLAY SYSTEM
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
