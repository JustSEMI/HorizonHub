--[[
    Gakuran v1.1.0
    Dev script by HorizonTeam
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local HorizonUnloaded = false

-- INIT CONFIGURATION
local Config = {
    -- Auto Play / Rhythm
    Enabled = false,
    AlwaysPerfect = true,
    TargetJudgment = "Perfect",
    AccuracyMode = "100% Perfect",
    CustomAccuracy = 95,
    HoldNoteSupport = true,
    TapDurationMs = 35,
    HitDelayMs = 0,
    HumanizeMs = 0,
    TriggerZoneTop = 83,
    TriggerZoneBottom = 92,
    ChartMode = "Auto (Smart Detect)",
    AutoRetry = false,
    
    -- Visuals / ESP
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
    ESPColor = Color3.fromRGB(255, 0, 0),
    
    KeyMap = {
        ["F"] = Enum.KeyCode.F, ["f"] = Enum.KeyCode.F,
        ["J"] = Enum.KeyCode.J, ["j"] = Enum.KeyCode.J,
        ["D"] = Enum.KeyCode.D, ["d"] = Enum.KeyCode.D,
        ["K"] = Enum.KeyCode.K, ["k"] = Enum.KeyCode.K,
        ["G"] = Enum.KeyCode.G, ["g"] = Enum.KeyCode.G,
        ["H"] = Enum.KeyCode.H, ["h"] = Enum.KeyCode.H,
        ["S"] = Enum.KeyCode.S, ["s"] = Enum.KeyCode.S,
        ["L"] = Enum.KeyCode.L, ["l"] = Enum.KeyCode.L,
        ["X"] = Enum.KeyCode.X, ["x"] = Enum.KeyCode.X,
        ["C"] = Enum.KeyCode.C, ["c"] = Enum.KeyCode.C,
        ["N"] = Enum.KeyCode.N, ["n"] = Enum.KeyCode.N,
        ["M"] = Enum.KeyCode.M, ["m"] = Enum.KeyCode.M,
        ["1"] = Enum.KeyCode.X,
        ["2"] = Enum.KeyCode.C,
        ["3"] = Enum.KeyCode.N,
        ["4"] = Enum.KeyCode.M,
        ["Enum.KeyCode.F"] = Enum.KeyCode.F,
        ["Enum.KeyCode.J"] = Enum.KeyCode.J,
        ["Enum.KeyCode.X"] = Enum.KeyCode.X,
        ["Enum.KeyCode.C"] = Enum.KeyCode.C,
        ["Enum.KeyCode.N"] = Enum.KeyCode.N,
        ["Enum.KeyCode.M"] = Enum.KeyCode.M,
        ["Enum.KeyCode.D"] = Enum.KeyCode.D,
        ["Enum.KeyCode.K"] = Enum.KeyCode.K
    }
}

-- MIDI PARSER UTILITIES
local midiFolder = "HorizonHub_MIDI"
if makefolder and not isfolder(midiFolder) then makefolder(midiFolder) end

local VPMapping = {
    [36]="1",[37]="!",[38]="2",[39]="@",[40]="3",[41]="4",[42]="$",[43]="5",[44]="%",[45]="6",[46]="^",[47]="7",
    [48]="8",[49]="*",[50]="9",[51]="(",[52]="0",[53]="q",[54]="Q",[55]="w",[56]="W",[57]="e",[58]="E",[59]="r",
    [60]="t",[61]="T",[62]="y",[63]="Y",[64]="u",[65]="i",[66]="I",[67]="o",[68]="O",[69]="p",[70]="P",[71]="a",
    [72]="s",[73]="S",[74]="d",[75]="D",[76]="f",[77]="g",[78]="G",[79]="h",[80]="H",[81]="j",[82]="J",[83]="k",
    [84]="l",[85]="L",[86]="z",[87]="Z",[88]="x",[89]="c",[90]="C",[91]="v",[92]="V",[93]="b",[94]="B",[95]="n",
    [96]="m"
}

local charToKeyName = {
    ["1"]="One", ["!"]="One", ["2"]="Two", ["@"]="Two", ["3"]="Three", ["#"]="Three",
    ["4"]="Four", ["$"]="Four", ["5"]="Five", ["%"]="Five", ["6"]="Six", ["^"]="Six",
    ["7"]="Seven", ["&"]="Seven", ["8"]="Eight", ["*"]="Eight", ["9"]="Nine", ["("]="Nine",
    ["0"]="Zero", [")"]="Zero"
}

local function readStr(data, pos, len) return string.sub(data, pos, pos + len - 1), pos + len end
local function readInt32(data, pos)
    local b1, b2, b3, b4 = string.byte(data, pos, pos + 3)
    return bit32.lshift(b1, 24) + bit32.lshift(b2, 16) + bit32.lshift(b3, 8) + b4, pos + 4
end
local function readInt16(data, pos)
    local b1, b2 = string.byte(data, pos, pos + 1)
    return bit32.lshift(b1, 8) + b2, pos + 2
end
local function readVLQ(data, pos)
    local val, b = 0, 0
    repeat b = string.byte(data, pos); pos = pos + 1; val = bit32.lshift(val, 7) + bit32.band(b, 0x7F) until bit32.band(b, 0x80) == 0
    return val, pos
end

local function parseMidi(binaryString, difficulty)
    local pos = 1
    local header, p2 = readStr(binaryString, pos, 4)
    if header ~= "MThd" then error("Invalid MIDI Header") end
    pos = p2
    local headerLen, p3 = readInt32(binaryString, pos); pos = p3
    local format, p4 = readInt16(binaryString, pos); pos = p4
    local tracks, p5 = readInt16(binaryString, pos); pos = p5
    local division, p6 = readInt16(binaryString, pos); pos = p6
    
    local allEvents, microsecondsPerBeat = {}, 500000
    for trk = 1, tracks do
        local trackHeader, p7 = readStr(binaryString, pos, 4); pos = p7
        if trackHeader ~= "MTrk" then break end
        local trackLen, p8 = readInt32(binaryString, pos); pos = p8
        local trackEnd, currentTicks, lastStatus = pos + trackLen, 0, 0
        while pos < trackEnd do
            local deltaTime, p9 = readVLQ(binaryString, pos); pos = p9
            currentTicks = currentTicks + deltaTime
            local status = string.byte(binaryString, pos)
            if status >= 0x80 then pos = pos + 1; lastStatus = status else status = lastStatus end
            local eventType = bit32.band(status, 0xF0)
            if status == 0xFF then
                local metaType = string.byte(binaryString, pos); pos = pos + 1
                local metaLen, p10 = readVLQ(binaryString, pos); pos = p10
                if metaType == 0x51 and metaLen == 3 then
                    local b1, b2, b3 = string.byte(binaryString, pos, pos + 2)
                    table.insert(allEvents, {type = "Tempo", ticks = currentTicks, tempo = bit32.lshift(b1, 16) + bit32.lshift(b2, 8) + b3})
                end
                pos = pos + metaLen
            elseif eventType == 0x90 or eventType == 0x80 then
                local key, velocity = string.byte(binaryString, pos), string.byte(binaryString, pos + 1); pos = pos + 2
                if eventType == 0x90 and velocity > 0 then table.insert(allEvents, {type = "NoteOn", ticks = currentTicks, key = key, velocity = velocity}) end
            elseif eventType == 0xC0 or eventType == 0xD0 then pos = pos + 1
            elseif eventType == 0xA0 or eventType == 0xB0 or eventType == 0xE0 then pos = pos + 2
            elseif status == 0xF0 or status == 0xF7 then
                local sysLen, p11 = readVLQ(binaryString, pos); pos = p11 + sysLen
            else break end
        end
    end
    table.sort(allEvents, function(a, b) return a.ticks < b.ticks end)
    local timeSeconds, lastTicks, currentTempo, parsedNotes = 0, 0, 500000, {}
    for _, ev in ipairs(allEvents) do
        timeSeconds = timeSeconds + (ev.ticks - lastTicks) * (currentTempo / division) / 1000000.0
        lastTicks = ev.ticks
        if ev.type == "Tempo" then currentTempo = ev.tempo
        elseif ev.type == "NoteOn" and VPMapping[ev.key] then table.insert(parsedNotes, {time = timeSeconds, char = VPMapping[ev.key], key = ev.key}) end
    end
    
    if difficulty and difficulty ~= "Advanced (Full Chords)" then
        local timeGroups = {}
        local groupTimes = {}
        for _, note in ipairs(parsedNotes) do
            local foundGroup = false
            for _, t in ipairs(groupTimes) do
                if math.abs(note.time - t) < 0.005 then
                    table.insert(timeGroups[t], note)
                    foundGroup = true
                    break
                end
            end
            if not foundGroup then
                table.insert(groupTimes, note.time)
                timeGroups[note.time] = {note}
            end
        end
        
        local filteredNotes = {}
        for _, t in ipairs(groupTimes) do
            local group = timeGroups[t]
            if #group <= 1 then
                table.insert(filteredNotes, group[1])
            else
                table.sort(group, function(a, b) return a.key < b.key end)
                if difficulty == "Beginner (Melody Only)" then
                    table.insert(filteredNotes, group[#group])
                elseif difficulty == "Intermediate (Melody + Bass)" then
                    table.insert(filteredNotes, group[1])
                    table.insert(filteredNotes, group[#group])
                end
            end
        end
        table.sort(filteredNotes, function(a, b) return a.time < b.time end)
        return filteredNotes
    end
    
    return parsedNotes
end

-- LOAD WINDUI LIB
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)
if not success or type(WindUI) ~= "table" then
    error("Gagal memuat WindUI! Pastikan koneksi internet stabil.")
end

-- WINDUI NOTIFICATION CUSTOMIZATION
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
            if padding then padding.PaddingBottom = UDim.new(0, 15) end
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
                    local r = lastChild:FindFirstChildOfClass("ImageLabel") or lastChild
                    if r then
                        if r:IsA("ImageLabel") then r.ImageTransparency = 0 end
                        r.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
                        
                        local p = r:FindFirstChildOfClass("Frame")
                        if p then
                            for _, txt in ipairs(p:GetChildren()) do
                                if txt:IsA("TextLabel") then
                                    if txt.TextSize == 18 or txt.TextSize == 12 or txt.TextSize == 13 then
                                        txt.TextSize = 13
                                        txt.Font = Enum.Font.GothamBold
                                        txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                                    elseif txt.TextSize == 15 or txt.TextSize == 9 or txt.TextSize == 11 then
                                        txt.TextSize = 11
                                        txt.Font = Enum.Font.Gotham
                                        txt.TextColor3 = Color3.fromRGB(210, 210, 210)
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

-- WINDOW INIT
local Window = WindUI:CreateWindow({
    Title = "Gakuran Hub X Gakuran",
    Icon = "headphones",
    Author = "@HorizonTeam",
    Folder = "GakuranDevConfig",
    Size = UDim2.fromOffset(750, 460),
    Transparent = false,
    Theme = "Dark",
    SideBarWidth = 200,
    HasOutline = true
})

-- FPS TAG
local FPSTag = Window:Tag({
    Title = "FPS: 0",
    Color = Color3.fromRGB(100, 150, 255),
})
 
local RunService = game:GetService("RunService")
local lastUpdate = tick()
local frameCount = 0
 
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    
    if now - lastUpdate >= 1 then
        local fps = math.floor(frameCount / (now - lastUpdate))
        FPSTag:SetTitle("FPS: " .. fps)
        
        if fps >= 50 then
            FPSTag:SetColor(Color3.fromRGB(0, 255, 0)) -- Green
        elseif fps >= 30 then
            FPSTag:SetColor(Color3.fromRGB(255, 200, 0)) -- Yellow
        else
            FPSTag:SetColor(Color3.fromRGB(255, 0, 0)) -- Red
        end
        
        
        frameCount = 0
        lastUpdate = now
    end
end)
-- PING TAG
local PingTag = Window:Tag({
    Title = "Ping: 0ms",
    Color = Color3.fromRGB(100, 200, 255),
})
 
task.spawn(function()
    while true do
        local success, ping = pcall(function()
            local Stats = game:GetService("Stats")
            local pingValue = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
            return math.floor(pingValue)
        end)
        
        if success and ping then
            PingTag:SetTitle("Ping: " .. ping .. "ms")
            
            if ping <= 50 then
                PingTag:SetColor(Color3.fromRGB(0, 255, 0)) -- Green
            elseif ping <= 100 then
                PingTag:SetColor(Color3.fromRGB(255, 200, 0)) -- Yellow
            elseif ping <= 200 then
                PingTag:SetColor(Color3.fromRGB(255, 150, 0)) -- Orange
            else
                PingTag:SetColor(Color3.fromRGB(255, 0, 0))
            end
        end
        
        task.wait(2)
    end
end)
-- VERSION TAG
local VersionTeg = Window:Tag({
    Title = "v1.2.0",
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
        "Executor: %s\nStandard UNC: %d%%\nStrict sUNC: %d%%\nStatus Injeksi: Sukses\nVersi Engine: 1.2.0 (release)",
        execName, uncScore, sUncScore
    )
})

SectionWelcome:Paragraph({
    Title = "Developer Information",
    Desc = "Creator: -\nTeam: Horizon Team\nLanguage: Luau (Roblox)\nUI Library: WindUI"
})



local TabRhythm = Window:Tab({Title = "Auto Play", Icon = "play"})

local SectionControls = TabRhythm:Section({Title = "Controls", Icon = "gamepad-2", Opened = true})

SectionControls:Toggle({
    Title = "Enable Auto Play",
    Desc = "Otomatis memainkan not",
    Value = Config.Enabled,
    Callback = function(val)
        Config.Enabled = val
    end
})

SectionControls:Dropdown({
    Title = "Chart Mode",
    Desc = "Pilih layout tombol",
    Values = {"Auto (Smart Detect)", "2-Key (F, J)", "4-Key (X, C, N, M)", "4-Key (D, F, J, K)"},
    Value = Config.ChartMode,
    Callback = function(val)
        Config.ChartMode = val
    end
})

local SectionAcc = TabRhythm:Section({Title = "Accuracy", Icon = "target"})

SectionAcc:Toggle({
    Title = "Override Judgment",
    Desc = "Memaksa engine game untuk menghasilkan penilaian spesifik",
    Value = Config.AlwaysPerfect,
    Callback = function(val) Config.AlwaysPerfect = val end
})

SectionAcc:Dropdown({
    Title = "Accuracy Mode",
    Desc = "Pilih mode akurasi saat Override menyala",
    Values = {"100% Perfect", "Random Legit (90-99%)", "Custom Hit Chance"},
    Value = Config.AccuracyMode or "100% Perfect",
    Callback = function(val)
        Config.AccuracyMode = val
    end
})

SectionAcc:Slider({
    Title = "Custom Hit Chance (%)",
    Desc = "Peluang mendapatkan Perfect (Hanya untuk mode Custom)",
    Step = 1,
    Value = {Min = 0, Max = 100, Default = Config.CustomAccuracy or 95},
    Callback = function(val)
        Config.CustomAccuracy = val
    end
})

local SectionTiming = TabRhythm:Section({Title = "Timing & Zones", Icon = "clock"})

SectionTiming:Slider({
    Title = "Hit Delay (ms)",
    Desc = "Offset timing (negatif = awal, positif = lambat)",
    Step = 1,
    Value = {Min = -50, Max = 50, Default = Config.HitDelayMs},
    Callback = function(val) Config.HitDelayMs = val end
})
SectionTiming:Slider({
    Title = "Upper Zone (%)",
    Desc = "Batas atas dimana not terbaca",
    Step = 1,
    Value = {Min = 50, Max = 95, Default = Config.TriggerZoneTop},
    Callback = function(val) Config.TriggerZoneTop = val end
})
SectionTiming:Slider({
    Title = "Lower Zone (%)",
    Desc = "Batas bawah dimana not keluar",
    Step = 1,
    Value = {Min = 60, Max = 98, Default = Config.TriggerZoneBottom},
    Callback = function(val) Config.TriggerZoneBottom = val end
})

-- TAB AUTO PIANO
local TabMidi = Window:Tab({Title = "Auto Piano", Icon = "music"})
local SectionMidi = TabMidi:Section({Title = "Midi Engine & Files", Icon = "play-circle", Opened = true})

local function getMidiFiles()
    local list = {}
    if listfiles and isfolder(midiFolder) then
        for _, file in ipairs(listfiles(midiFolder)) do
            if file:match("%.mid$") or file:match("%.midi$") then
                local name = file:match("([^/\\]+)%.mid[i]?$")
                if name then table.insert(list, name .. ".mid") end
            end
        end
    end
    if #list == 0 then table.insert(list, "No MIDI Files") end
    return list
end

local selectedMidi = ""
local isPlayingMidi = false
local currentPlaybackThread = nil

local MidiHStack1 = SectionMidi:HStack({Title = "File Selection"})
local MidiDropdown = MidiHStack1:Dropdown({
    Title = "Select MIDI File",
    Desc = "Pilih file lagu (.mid)",
    Values = getMidiFiles(),
    Value = "No MIDI Files",
    Callback = function(val)
        selectedMidi = val
    end
})

MidiHStack1:Button({
    Title = "Refresh Files",
    Callback = function()
        pcall(function() MidiDropdown:Refresh(getMidiFiles()) end)
    end
})

local midiDifficulty = "Advanced (Full Chords)"
local midiStartDelay = 0
local midiAutoPlayEnabled = false

SectionMidi:Dropdown({
    Title = "Difficulty",
    Desc = "Saring chord berdasar kerumitan",
    Values = {"Beginner (Melody Only)", "Intermediate (Melody + Bass)", "Advanced (Full Chords)"},
    Value = midiDifficulty,
    Callback = function(val)
        midiDifficulty = val
    end
})

SectionMidi:Slider({
    Title = "Start Delay (s)",
    Desc = "Jeda detik sebelum mulai saat duduk di piano",
    Step = 1,
    Value = {Min = 0, Max = 10, Default = midiStartDelay},
    Callback = function(val)
        midiStartDelay = val
    end
})

SectionMidi:Toggle({
    Title = "Enable Auto Play on Sit (.mid)",
    Desc = "Otomatis memainkan MIDI saat duduk",
    Value = midiAutoPlayEnabled,
    Callback = function(state)
        midiAutoPlayEnabled = state
    end
})

local function playMidi(filePath)
    local binaryData = readfile(filePath)
    local successParse, notes = pcall(parseMidi, binaryData, midiDifficulty)
    
    if not successParse or type(notes) ~= "table" then
        WindUI:Notify({Title = "Error", Content = "Gagal memparsing MIDI!"})
        getgenv().GakuranPlayingPiano = false
        return
    end
    
    local startTime = os.clock()
    for _, note in ipairs(notes) do
        if not getgenv().GakuranPlayingPiano then break end
        
        local targetTime = startTime + note.time
        while os.clock() < targetTime do
            if not getgenv().GakuranPlayingPiano then break end
            task.wait()
        end
        if not getgenv().GakuranPlayingPiano then break end
        
        local keyName = charToKeyName[note.char] or string.upper(note.char)
        local keycode = Enum.KeyCode[keyName] or Enum.KeyCode.Unknown
        
        if keycode ~= Enum.KeyCode.Unknown then
            local isUpper = string.match(note.char, "[A-Z!@#$%%^&*()_+{}|:\"<>?]")
            if isUpper then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
            end
            VirtualInputManager:SendKeyEvent(true, keycode, false, game)
            
            task.spawn(function()
                task.wait(0.015)
                VirtualInputManager:SendKeyEvent(false, keycode, false, game)
                if isUpper then
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
                end
            end)
        end
    end
    getgenv().GakuranPlayingPiano = false
    WindUI:Notify({Title = "Finished", Content = "Lagu MIDI selesai dimainkan!"})
end

-- OLD SHEET PLAYER (.TXT)
local pianoFolder = "HorizonHub_Gakuran/Sheets"
if makefolder and not isfolder(pianoFolder) then
    makefolder(pianoFolder)
end

local function getSheetFiles()
    local list = {}
    if listfiles and isfolder(pianoFolder) then
        for _, file in ipairs(listfiles(pianoFolder)) do
            if file:match("%.txt$") then
                local name = file:match("([^/\\]+)%.txt$")
                if name then table.insert(list, name) end
            end
        end
    end
    if #list == 0 then table.insert(list, "No Sheets Found") end
    return list
end

local selectedSheet = ""
if getgenv().GakuranPianoConnection then pcall(function() getgenv().GakuranPianoConnection:Disconnect() end) end
if getgenv().GakuranPianoThread then pcall(function() task.cancel(getgenv().GakuranPianoThread) end) end
getgenv().GakuranPlayingPiano = false
local pianoBPM = 300
local pianoStartDelay = 0

local SectionPiano = TabMidi:Section({Title = "Sheet Player (.txt)", Icon = "file-text", Opened = false})

local sheetDropdown
sheetDropdown = SectionPiano:Dropdown({
    Title = "Select Sheet (.txt)",
    Desc = "Pilih lagu dari workspace/HorizonHub_Gakuran/Sheets",
    Values = getSheetFiles(),
    Value = "",
    Callback = function(val)
        selectedSheet = val
    end
})

SectionPiano:Button({
    Title = "Refresh Sheets",
    Callback = function()
        pcall(function() sheetDropdown:Refresh(getSheetFiles()) end)
    end
})

SectionPiano:Input({
    Title = "Playback Speed (BPM)",
    Desc = "Kecepatan pemutaran sheet secara akurat (BPM).",
    Placeholder = "Default: 300",
    Callback = function(val)
        local num = tonumber(val)
        if num and num > 0 then
            pianoBPM = num
        else
            pianoBPM = 300
        end
    end
})

SectionPiano:Slider({
    Title = "Start Delay (s)",
    Desc = "Jeda detik sebelum mulai saat duduk di piano",
    Step = 1,
    Value = {Min = 0, Max = 10, Default = pianoStartDelay},
    Callback = function(val)
        pianoStartDelay = val
    end
})

local shiftChars = {
    ["!"]="1", ["@"]="2", ["#"]="3", ["$"]="4", ["%"]="5",
    ["^"]="6", ["&"]="7", ["*"]="8", ["("]="9", [")"]="0"
}
for i = 65, 90 do shiftChars[string.char(i)] = string.char(i + 32) end

local keyMap = {
    ["1"] = Enum.KeyCode.One, ["2"] = Enum.KeyCode.Two, ["3"] = Enum.KeyCode.Three,
    ["4"] = Enum.KeyCode.Four, ["5"] = Enum.KeyCode.Five, ["6"] = Enum.KeyCode.Six,
    ["7"] = Enum.KeyCode.Seven, ["8"] = Enum.KeyCode.Eight, ["9"] = Enum.KeyCode.Nine,
    ["0"] = Enum.KeyCode.Zero
}
for i = 97, 122 do keyMap[string.char(i)] = Enum.KeyCode[string.char(i - 32)] end

local function pressPianoKey(char)
    local requiresShift = false
    local baseChar = char
    if shiftChars[char] then
        requiresShift = true
        baseChar = shiftChars[char]
    end
    
    local keyCode = keyMap[baseChar]
    if keyCode then
        if requiresShift then VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game) end
        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
        task.wait(0.01)
        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
        if requiresShift then VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game) end
    end
end

local function playSheet(sheetText)
    local isChord = false
    local isFast = false
    local currentChord = {}
    local timeSeconds = 0
    local parsedNotes = {}
    
    -- Parsing Sheet Text ke Timeline
    for i = 1, #sheetText do
        local char = sheetText:sub(i, i)
        if char == "[" then
            isChord = true
            currentChord = {}
        elseif char == "]" then
            isChord = false
            for _, k in ipairs(currentChord) do
                table.insert(parsedNotes, {time = timeSeconds, char = k})
            end
            timeSeconds = timeSeconds + ((60000 / pianoBPM) / 1000)
        elseif char == "{" then
            isFast = true
        elseif char == "}" then
            isFast = false
        elseif char == " " or char == "-" then
            timeSeconds = timeSeconds + ((60000 / pianoBPM) / 1000)
        elseif char == "|" then
            timeSeconds = timeSeconds + (((60000 / pianoBPM) * 2) / 1000)
        elseif char:match("%S") then
            if isChord then
                table.insert(currentChord, char)
            else
                table.insert(parsedNotes, {time = timeSeconds, char = char})
                if isFast then
                    timeSeconds = timeSeconds + (((60000 / pianoBPM) / 2) / 1000)
                else
                    timeSeconds = timeSeconds + ((60000 / pianoBPM) / 1000)
                end
            end
        end
    end

    -- Eksekusi Timeline Presisi Tinggi
    local startTime = os.clock()
    for _, note in ipairs(parsedNotes) do
        if not getgenv().GakuranPlayingPiano then break end
        
        local targetTime = startTime + note.time
        while os.clock() < targetTime do
            if not getgenv().GakuranPlayingPiano then break end
            task.wait()
        end
        if not getgenv().GakuranPlayingPiano then break end
        
        task.spawn(pressPianoKey, note.char)
    end
    
    getgenv().GakuranPlayingPiano = false
    WindUI:Notify({Title = "Auto Piano", Content = "Lagu selesai diputar!", Duration = 3})
end

local autoPlayEnabled = false

SectionPiano:Toggle({
    Title = "Enable Auto Play on Sit",
    Desc = "Otomatis memainkan lagu saat duduk di piano",
    Value = autoPlayEnabled,
    Callback = function(state)
        autoPlayEnabled = state
    end
})

-- Hook OnClientEvent for Auto-Start and Auto-Stop
task.spawn(function()
    local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 5)
    if Remotes then
        local InstrumentPiano = Remotes:WaitForChild("InstrumentPiano", 5)
        if InstrumentPiano then
            getgenv().GakuranPianoConnection = InstrumentPiano.OnClientEvent:Connect(function(action)
                if action == "activate" then
                    if midiAutoPlayEnabled then
                        if selectedMidi == "" or selectedMidi == "No MIDI Files" then
                            WindUI:Notify({Title = "Auto Piano", Content = "Pilih MIDI dulu sebelum duduk!", Duration = 3})
                        elseif not getgenv().GakuranPlayingPiano then
                            local filePath = midiFolder .. "/" .. selectedMidi
                            if isfile and isfile(filePath) then
                                getgenv().GakuranPlayingPiano = true
                                if midiStartDelay > 0 then
                                    WindUI:Notify({Title = "Auto Piano", Content = "Menunggu " .. midiStartDelay .. " detik...", Duration = 3})
                                end
                                getgenv().GakuranPianoThread = task.spawn(function()
                                    if midiStartDelay > 0 then task.wait(midiStartDelay) end
                                    if getgenv().GakuranPlayingPiano then
                                        WindUI:Notify({Title = "Auto Piano", Content = "Auto-Start: " .. selectedMidi, Duration = 3})
                                        playMidi(filePath)
                                    end
                                end)
                            else
                                WindUI:Notify({Title = "Auto Piano Error", Content = "File tidak ditemukan: " .. filePath, Duration = 5})
                            end
                        end
                    elseif autoPlayEnabled then
                        if selectedSheet == "" or selectedSheet == "No Sheets Found" then
                            WindUI:Notify({Title = "Auto Piano", Content = "Pilih sheet dulu sebelum duduk!", Duration = 3})
                        elseif not getgenv().GakuranPlayingPiano then
                            local filePath = pianoFolder .. "/" .. selectedSheet .. ".txt"
                            if isfile and isfile(filePath) then
                                local sheetText = readfile(filePath)
                                
                                local lowerText = string.lower(sheetText)
                                local delayMatch = lowerText:match("delay[%s:=]+(%d+)")
                                local bpmMatch = lowerText:match("bpm[%s:=]+(%d+)")
                                local tempoMatch = lowerText:match("tempo[%s:=]+(%d+)")
                                
                                local detectedVal = nil
                                if delayMatch then
                                    detectedVal = tonumber(delayMatch)
                                elseif bpmMatch or tempoMatch then
                                    local bpm = tonumber(bpmMatch or tempoMatch)
                                    if bpm and bpm > 0 then
                                        detectedVal = math.floor((60 / bpm) * 1000)
                                    end
                                end
                                
                                if detectedVal and detectedVal > 0 then
                                    pianoBPM = detectedVal
                                    task.spawn(function() WindUI:Notify({Title = "Auto BPM", Content = "BPM terdeteksi! Delay diatur ke " .. detectedVal .. "ms", Duration = 5}) end)
                                end

                                getgenv().GakuranPlayingPiano = true
                                if pianoStartDelay > 0 then
                                    WindUI:Notify({Title = "Auto Piano", Content = "Menunggu " .. pianoStartDelay .. " detik...", Duration = 3})
                                end
                                getgenv().GakuranPianoThread = task.spawn(function()
                                    if pianoStartDelay > 0 then task.wait(pianoStartDelay) end
                                    if getgenv().GakuranPlayingPiano then
                                        WindUI:Notify({Title = "Auto Piano", Content = "Auto-Start: " .. selectedSheet, Duration = 3})
                                        playSheet(sheetText)
                                    end
                                end)
                            else
                                WindUI:Notify({Title = "Auto Piano Error", Content = "File tidak ditemukan: " .. filePath, Duration = 5})
                            end
                        end
                    end
                elseif action == "deactivate" then
                    if getgenv().GakuranPlayingPiano then
                        getgenv().GakuranPlayingPiano = false
                        if getgenv().GakuranPianoThread then
                            pcall(function() task.cancel(getgenv().GakuranPianoThread) end)
                            getgenv().GakuranPianoThread = nil
                        end
                        WindUI:Notify({Title = "Auto Piano", Content = "Auto-Stop.", Duration = 3})
                    end
                end
            end)
        end
    end
end)

-- TAB VISUALS
local TabVisual = Window:Tab({Title = "Visuals", Icon = "eye"})
local SectionMasterESP = TabVisual:Section({Title = "ESP", Icon = "power", Opened = true})

SectionMasterESP:Toggle({
    Title = "Enable Player ESP",
    Desc = "Saklar utama visual pemain",
    Value = Config.ESPEnabled,
    Callback = function(state) Config.ESPEnabled = state end
})
SectionMasterESP:Colorpicker({
    Title = "Global ESP Color",
    Desc = "Warna dasar fitur visual",
    Default = Config.ESPColor,
    Callback = function(val) Config.ESPColor = val end
})
SectionMasterESP:Slider({
    Title = "Max Render Distance",
    Desc = "Batas maksimum jarak render (mengurangi lag)",
    Step = 50,
    Value = {Min = 200, Max = 5000, Default = Config.ESPMaxDistance},
    Callback = function(val) Config.ESPMaxDistance = val end
})
local SectionInfoESP = TabVisual:Section({Title = "Information", Icon = "users"})

SectionInfoESP:Toggle({
    Title = "Show Name",
    Desc = "Display Name musuh",
    Value = Config.ESPName,
    Callback = function(state)
        Config.ESPName = state
    end
})
SectionInfoESP:Toggle({
    Title = "Show Distance",
    Desc = "Jarak (meter)",
    Value = Config.ESPDistance,
    Callback = function(state)
        Config.ESPDistance = state
    end
})
SectionInfoESP:Toggle({
    Title = "Show Health Bar",
    Desc = "Indikator nyawa dinamis",
    Value = Config.ESPHealthBar,
    Callback = function(state)
        Config.ESPHealthBar = state
    end
})
SectionInfoESP:Slider({Title = "Text Size", Desc = "Ukuran teks nama & jarak", Step = 1, Value = {Min = 10, Max = 25, Default = Config.ESPTextSize}, Callback = function(val) Config.ESPTextSize = val end})

local SectionDrawESP = TabVisual:Section({Title = "Rendering", Icon = "pen-tool"})

SectionDrawESP:Toggle({Title = "Character Highlight (Chams)", Desc = "Karakter tembus pandang", Value = Config.ESPHighlight, Callback = function(state) Config.ESPHighlight = state end})
SectionDrawESP:Slider({Title = "Highlight Fill Alpha (%)", Desc = "Transparansi warna isi tubuh", Step = 1, Value = {Min = 0, Max = 100, Default = Config.ESPHighlightFillAlpha}, Callback = function(val) Config.ESPHighlightFillAlpha = val end})
SectionDrawESP:Slider({Title = "Highlight Outline Alpha (%)", Desc = "Transparansi warna garis tepi", Step = 1, Value = {Min = 0, Max = 100, Default = Config.ESPHighlightOutlineAlpha}, Callback = function(val) Config.ESPHighlightOutlineAlpha = val end})

SectionDrawESP:Toggle({Title = "Target Box", Desc = "Mengelilingi karakter dengan kotak", Value = Config.ESPBox, Callback = function(state) Config.ESPBox = state end})
SectionDrawESP:Dropdown({Title = "Box Style", Desc = "Pilih bentuk kotak", Values = {"Corner Box", "Full Box"}, Value = Config.ESPBoxStyle, Callback = function(val) Config.ESPBoxStyle = val end})
SectionDrawESP:Slider({Title = "Box Outline Thickness", Desc = "Ketebalan kotak", Step = 1, Value = {Min = 1, Max = 5, Default = Config.ESPBoxThickness}, Callback = function(val) Config.ESPBoxThickness = val end})

SectionDrawESP:Toggle({Title = "Tracer Lines", Desc = "Garis pelacak arah musuh", Value = Config.ESPTracer, Callback = function(state) Config.ESPTracer = state end})
SectionDrawESP:Dropdown({Title = "Tracer Origin", Desc = "Titik awal garis", Values = {"Bottom Center", "Screen Center", "Top Center"}, Value = Config.ESPTracerOrigin, Callback = function(val) Config.ESPTracerOrigin = val end})
SectionDrawESP:Slider({Title = "Tracer Thickness", Desc = "Ketebalan garis pelacak", Step = 1, Value = {Min = 1, Max = 5, Default = Config.ESPTracerThickness}, Callback = function(val) Config.ESPTracerThickness = val end})

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
    Desc = "Memuat settingan. (Catatan: script otomatis jalan)",
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

-- CORE LOGIC : ESP
local espFolder = Instance.new("Folder")
espFolder.Name = "GakuranESPFolder"
espFolder.Parent = game:GetService("CoreGui")

local function createESP(player)
    local espObj = {}
    local hl = Instance.new("Highlight")
    hl.Name = player.Name .. "_Highlight"
    hl.Parent = espFolder
    espObj.Highlight = hl

    local bg = Instance.new("BillboardGui")
    bg.Name = player.Name .. "_Billboard"
    bg.AlwaysOnTop = true
    bg.Size = UDim2.new(0, 200, 0, 50)
    bg.StudsOffset = Vector3.new(0, 3, 0)
    bg.Parent = espFolder
    
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.GothamBold
    txt.TextStrokeTransparency = 0
    txt.Parent = bg
    espObj.Billboard = bg
    espObj.Text = txt
    
    local hpBG = Instance.new("Frame")
    hpBG.Size = UDim2.new(0, 4, 1, 0)
    hpBG.Position = UDim2.new(0.5, -30, 0, 0) -- Menempatkan HP bar di samping nama
    hpBG.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    hpBG.BorderSizePixel = 0
    hpBG.Parent = bg
    
    local hpFill = Instance.new("Frame")
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.Position = UDim2.new(0, 0, 0, 0)
    hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    hpFill.BorderSizePixel = 0
    hpFill.Parent = hpBG
    
    espObj.HealthBG = hpBG
    espObj.HealthFill = hpFill
    
    local tracer = Drawing.new("Line")
    espObj.Tracer = tracer
    
    local box = Drawing.new("Square")
    espObj.Box = box

    return espObj
end

local espObjects = {}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then espObjects[p] = createESP(p) end
end
Players.PlayerAdded:Connect(function(p) espObjects[p] = createESP(p) end)
Players.PlayerRemoving:Connect(function(p)
    if espObjects[p] then
        espObjects[p].Highlight:Destroy()
        espObjects[p].Billboard:Destroy()
        if espObjects[p].Tracer then espObjects[p].Tracer:Remove() end
        if espObjects[p].Box then espObjects[p].Box:Remove() end
        espObjects[p] = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if HorizonUnloaded then
        espFolder:Destroy()
        for _, obj in pairs(espObjects) do
            if obj.Tracer then obj.Tracer:Remove() end
            if obj.Box then obj.Box:Remove() end
        end
        return
    end
    
    for player, esp in pairs(espObjects) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        
        if Config.ESPEnabled and root and hum and hum.Health > 0 then
            local dist = (camera.CFrame.Position - root.Position).Magnitude
            if dist <= Config.ESPMaxDistance then
                -- Highlight
                esp.Highlight.Adornee = char
                esp.Highlight.Enabled = Config.ESPHighlight
                if typeof(Config.ESPColor) == "Color3" then
                    esp.Highlight.FillColor = Config.ESPColor
                    esp.Highlight.OutlineColor = Config.ESPColor
                end
                esp.Highlight.FillTransparency = Config.ESPHighlightFillAlpha / 100
                esp.Highlight.OutlineTransparency = Config.ESPHighlightOutlineAlpha / 100
                
                -- Billboard (Name / Distance)
                esp.Billboard.Adornee = root
                local showText = false
                local textStr = ""
                if Config.ESPName then
                    textStr = player.DisplayName
                    showText = true
                end
                if Config.ESPDistance then
                    textStr = textStr .. " [" .. math.floor(dist) .. "m]"
                    showText = true
                end
                esp.Billboard.Enabled = showText or Config.ESPHealthBar
                esp.Text.Text = textStr
                if typeof(Config.ESPColor) == "Color3" then
                    esp.Text.TextColor3 = Config.ESPColor
                end
                esp.Text.TextSize = Config.ESPTextSize
                
                -- Health Bar Update
                if Config.ESPHealthBar then
                    esp.HealthBG.Visible = true
                    local maxHp = (hum.MaxHealth > 0 and hum.MaxHealth) or 100
                    local hpPct = math.clamp(hum.Health / maxHp, 0, 1)
                    esp.HealthFill.Size = UDim2.new(1, 0, hpPct, 0)
                    esp.HealthFill.Position = UDim2.new(0, 0, 1 - hpPct, 0)
                    esp.HealthFill.BackgroundColor3 = Color3.fromRGB(255 - (hpPct * 255), hpPct * 255, 0)
                else
                    esp.HealthBG.Visible = false
                end
                
                -- Box & Tracer via Drawing
                local vector, onScreen = camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    if Config.ESPTracer and esp.Tracer then
                        esp.Tracer.Visible = true
                        if typeof(Config.ESPColor) == "Color3" then esp.Tracer.Color = Config.ESPColor end
                        esp.Tracer.Thickness = Config.ESPTracerThickness
                        esp.Tracer.To = Vector2.new(vector.X, vector.Y)
                        if Config.ESPTracerOrigin == "Bottom Center" then
                            esp.Tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                        elseif Config.ESPTracerOrigin == "Top Center" then
                            esp.Tracer.From = Vector2.new(camera.ViewportSize.X / 2, 0)
                        else
                            esp.Tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                        end
                    elseif esp.Tracer then
                        esp.Tracer.Visible = false
                    end
                    
                    if Config.ESPBox and esp.Box then
                        local size = Vector3.new(4, 6, 4)
                        local tl = camera:WorldToViewportPoint((root.CFrame * CFrame.new(-size.X/2, size.Y/2, 0)).Position)
                        local br = camera:WorldToViewportPoint((root.CFrame * CFrame.new(size.X/2, -size.Y/2, 0)).Position)
                        esp.Box.Visible = true
                        if typeof(Config.ESPColor) == "Color3" then esp.Box.Color = Config.ESPColor end
                        esp.Box.Thickness = Config.ESPBoxThickness
                        esp.Box.Size = Vector2.new(math.abs(br.X - tl.X), math.abs(br.Y - tl.Y))
                        esp.Box.Position = Vector2.new(math.min(tl.X, br.X), math.min(tl.Y, br.Y))
                    elseif esp.Box then
                        esp.Box.Visible = false
                    end
                else
                    if esp.Tracer then esp.Tracer.Visible = false end
                    if esp.Box then esp.Box.Visible = false end
                end
            else
                esp.Highlight.Enabled = false
                esp.Billboard.Enabled = false
                if esp.Tracer then esp.Tracer.Visible = false end
                if esp.Box then esp.Box.Visible = false end
            end
        else
            esp.Highlight.Enabled = false
            esp.Billboard.Enabled = false
            if esp.Tracer then esp.Tracer.Visible = false end
            if esp.Box then esp.Box.Visible = false end
        end
    end
end)

-- CORE LOGIC RHYTHM AUTOPLAY
local function getTargetJudgmentData()
    local mode = Config.AccuracyMode or "100% Perfect"
    local chance = 100
    
    if mode == "Random Legit (90-99%)" then
        chance = math.random(90, 99)
    elseif mode == "Custom Hit Chance" then
        chance = Config.CustomAccuracy or 95
    end
    
    -- Roblox math.random(1, 100)
    local roll = math.random(1, 100)
    
    if roll <= chance then
        return "Perfect", 4, 100, (math.random(-15, 15) / 1000)
    else
        local failRoll = math.random(1, 100)
        if failRoll <= 70 then
            return "Great", 3, 75, (math.random(16, 45) / 1000)
        elseif failRoll <= 95 then
            return "Good", 2, 50, (math.random(46, 80) / 1000)
        else
            return "Miss", 0, 0, (math.random(90, 150) / 1000)
        end
    end
end

local noteCachePool = setmetatable({}, {__mode = "k"})

local activeHeldKeys = {}
local keyHoldCounts = {}

local function handleSmartHit(desc, targetKey)
    task.spawn(function()
        local wasHolding = (keyHoldCounts[targetKey] or 0) > 0
        keyHoldCounts[targetKey] = (keyHoldCounts[targetKey] or 0) + 1
        
        if wasHolding then
            VirtualInputManager:SendKeyEvent(false, targetKey, false, game)
            task.wait()
        end
        
        local totalDelay = (Config.HitDelayMs or 0) / 1000
        if (Config.HumanizeMs or 0) > 0 then
            totalDelay = totalDelay + (math.random(-Config.HumanizeMs, Config.HumanizeMs) / 1000)
        end
        if totalDelay > 0.001 then task.wait(totalDelay) end
        
        VirtualInputManager:SendKeyEvent(true, targetKey, false, game)
        activeHeldKeys[targetKey] = true
        
        local noteSizeY = desc.AbsoluteSize.Y
        local noteSizeX = desc.AbsoluteSize.X
        local isHoldNote = Config.HoldNoteSupport and ((noteSizeY > 130 and noteSizeX > 0 and noteSizeY > (noteSizeX * 2.2)) or desc:GetAttribute("Hold") or desc:GetAttribute("IsLong") or desc:GetAttribute("Duration") or desc:FindFirstChild("Hold") or desc:FindFirstChild("Body") or desc:FindFirstChild("Tail"))
        
        if isHoldNote then
            local screenHeight = workspace.CurrentCamera.ViewportSize.Y
            local startTime = tick()
            
            while desc and desc.Parent and desc.Visible and Config.Enabled do
                local currentTopY = desc.AbsolutePosition.Y
                if currentTopY >= (screenHeight * (Config.TriggerZoneBottom / 100)) or (tick() - startTime > 6) then
                    break
                end
                task.wait()
            end
            task.wait(0.015)
        else
            task.wait(Config.TapDurationMs / 1000)
        end
        
        keyHoldCounts[targetKey] = math.max(0, (keyHoldCounts[targetKey] or 1) - 1)
        if keyHoldCounts[targetKey] == 0 then
            VirtualInputManager:SendKeyEvent(false, targetKey, false, game)
            activeHeldKeys[targetKey] = false
        else
            VirtualInputManager:SendKeyEvent(false, targetKey, false, game)
            task.wait()
            if keyHoldCounts[targetKey] > 0 and Config.Enabled then
                VirtualInputManager:SendKeyEvent(true, targetKey, false, game)
            end
        end
    end)
end

local function registerPotentialNote(desc)
    if desc:IsA("GuiObject") and not desc:IsA("TextLabel") then
        local nameLower = string.lower(desc.Name)
        if string.find(nameLower, "note") or desc:GetAttribute("Key") or desc:GetAttribute("Lane") or desc:GetAttribute("Track") then
            noteCachePool[desc] = true
        end
    end
end

task.spawn(function()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and not (gui.Name == "Chat" or gui.Name == "BubbleChat" or gui.Name == "Freecam" or string.find(gui.Name, "WindUI") or string.find(gui.Name, "Gakuran") or gui.Name == "TouchGui") then
            local descendants = gui:GetDescendants()
            for i, desc in ipairs(descendants) do
                if i % 1000 == 0 then task.wait() end
                registerPotentialNote(desc)
            end
        end
    end
end)

PlayerGui.DescendantAdded:Connect(function(desc)
    if HorizonUnloaded then return end
    registerPotentialNote(desc)
end)

local lastUIScanTime = 0
local cachedReceptors = {}
local cachedIs2Key = false
local cachedIsDFJK = false
local cachedTopOffset = nil

RunService.Heartbeat:Connect(function()
    if HorizonUnloaded or not Config.Enabled then return end
    
    local screenWidth = workspace.CurrentCamera.ViewportSize.X
    local screenHeight = workspace.CurrentCamera.ViewportSize.Y
    local topBound = screenHeight * (Config.TriggerZoneTop / 100)
    local bottomBound = screenHeight * (Config.TriggerZoneBottom / 100)
    local catchBound = screenHeight * 1.06
    
    if tick() - lastUIScanTime > 2 then
        lastUIScanTime = tick()
        task.spawn(function()
            local tempReceptors = {}
            local tempIs2Key = false
            local tempIsDFJK = false
            local tempTopOffset = nil
            
            pcall(function()
                local guis = PlayerGui:GetDescendants()
                for i, gui in ipairs(guis) do
                    if i % 1000 == 0 then task.wait() end
                    if (gui:IsA("TextLabel") or gui:IsA("TextButton") or gui:IsA("ImageLabel") or gui:IsA("Frame")) and gui.Visible then
                        local pos = gui.AbsolutePosition
                        local size = gui.AbsoluteSize
                        if pos.Y > (screenHeight * 0.60) and pos.Y < (screenHeight * 0.95) and size.Y >= 18 and size.Y <= 160 and size.X >= 18 and size.X <= 220 then
                            local txt = (gui:IsA("TextLabel") or gui:IsA("TextButton")) and gui.Text or ""
                            local name = gui.Name
                            
                            if txt == "F" or txt == "J" then tempIs2Key = true end
                            if txt == "D" or txt == "K" then tempIsDFJK = true end
                            
                            local keyEnum = nil
                            if txt == "X" or name == "X" then keyEnum = Enum.KeyCode.X
                            elseif txt == "C" or name == "C" then keyEnum = Enum.KeyCode.C
                            elseif txt == "N" or name == "N" then keyEnum = Enum.KeyCode.N
                            elseif txt == "M" or name == "M" then keyEnum = Enum.KeyCode.M
                            elseif txt == "D" or name == "D" then keyEnum = Enum.KeyCode.D
                            elseif txt == "F" or name == "F" then keyEnum = Enum.KeyCode.F
                            elseif txt == "J" or name == "J" then keyEnum = Enum.KeyCode.J
                            elseif txt == "K" or name == "K" then keyEnum = Enum.KeyCode.K
                            end
                            
                            if keyEnum then
                                tempTopOffset = pos.Y - (screenHeight * 0.006)
                                table.insert(tempReceptors, { Key = keyEnum, CenterX = pos.X + (size.X / 2) })
                            elseif txt == "Receptor" or string.find(name:lower(), "receptor") or string.find(name:lower(), "hitbox") then
                                tempTopOffset = pos.Y - (screenHeight * 0.006)
                            end
                        end
                    end
                end
            end)
            
            cachedReceptors = tempReceptors
            cachedIs2Key = tempIs2Key
            cachedIsDFJK = tempIsDFJK
            if tempTopOffset then cachedTopOffset = tempTopOffset end
        end)
    end
    
    if (Config.ChartMode == "Auto (Smart Detect)" or string.find(Config.ChartMode, "Key")) and cachedTopOffset then
        topBound = cachedTopOffset
        if bottomBound < topBound then bottomBound = cachedTopOffset + (screenHeight * 0.08) end
    end
    
    -- Optimization: Limit iterations per frame to prevent Lagg
    local processed = 0
    local maxProcessPerFrame = 150
    
    for desc, _ in pairs(noteCachePool) do
        if processed >= maxProcessPerFrame then break end
        
        if desc.Parent and desc:IsA("GuiObject") then
            if not desc.Visible then
                if desc:GetAttribute("AutoPlayed") then desc:SetAttribute("AutoPlayed", nil) end
                continue
            end
            
            local posY = desc.AbsolutePosition.Y
            if posY < (topBound - 35) then
                if desc:GetAttribute("AutoPlayed") then desc:SetAttribute("AutoPlayed", nil) end
            else
                if posY >= topBound and posY <= catchBound then
                    if not desc:GetAttribute("AutoPlayed") then
                        local keyAttr = desc:GetAttribute("Key") or desc:GetAttribute("Lane") or desc:GetAttribute("Track") or desc.Name
                        local targetKey = nil
                        if keyAttr then
                            local kStr = tostring(keyAttr)
                            local laneNum = tonumber(string.match(kStr, "%d+"))
                            if Config.ChartMode == "2-Key (F, J)" or cachedIs2Key then
                                if laneNum == 1 or kStr:lower() == "f" then targetKey = Enum.KeyCode.F end
                                if laneNum == 2 or kStr:lower() == "j" then targetKey = Enum.KeyCode.J end
                            elseif Config.ChartMode == "4-Key (D, F, J, K)" or cachedIsDFJK then
                                if laneNum == 1 or kStr:lower() == "d" then targetKey = Enum.KeyCode.D end
                                if laneNum == 2 or kStr:lower() == "f" then targetKey = Enum.KeyCode.F end
                                if laneNum == 3 or kStr:lower() == "j" then targetKey = Enum.KeyCode.J end
                                if laneNum == 4 or kStr:lower() == "k" then targetKey = Enum.KeyCode.K end
                            else
                                if laneNum == 1 or kStr:lower() == "x" then targetKey = Enum.KeyCode.X end
                                if laneNum == 2 or kStr:lower() == "c" then targetKey = Enum.KeyCode.C end
                                if laneNum == 3 or kStr:lower() == "n" then targetKey = Enum.KeyCode.N end
                                if laneNum == 4 or kStr:lower() == "m" then targetKey = Enum.KeyCode.M end
                            end
                            if not targetKey then targetKey = Config.KeyMap[kStr] end
                        end
                        
                        if not targetKey then
                            local posX = desc.AbsolutePosition.X + (desc.AbsoluteSize.X / 2)
                            if #cachedReceptors > 0 then
                                local bestDist = math.huge
                                for _, rec in ipairs(cachedReceptors) do
                                    local dist = math.abs(posX - rec.CenterX)
                                    if dist < bestDist then
                                        bestDist = dist
                                        targetKey = rec.Key
                                    end
                                end
                            else
                                local ratio = posX / screenWidth
                                if Config.ChartMode == "2-Key (F, J)" or cachedIs2Key then
                                    if ratio <= 0.50 then targetKey = Enum.KeyCode.F else targetKey = Enum.KeyCode.J end
                                elseif Config.ChartMode == "4-Key (D, F, J, K)" or cachedIsDFJK then
                                    if ratio <= 0.44 then targetKey = Enum.KeyCode.D
                                    elseif ratio <= 0.50 then targetKey = Enum.KeyCode.F
                                    elseif ratio <= 0.56 then targetKey = Enum.KeyCode.J
                                    else targetKey = Enum.KeyCode.K end
                                else
                                    if ratio <= 0.44 then targetKey = Enum.KeyCode.X
                                    elseif ratio <= 0.50 then targetKey = Enum.KeyCode.C
                                    elseif ratio <= 0.56 then targetKey = Enum.KeyCode.N
                                    else targetKey = Enum.KeyCode.M end
                                end
                            end
                        end
                        
                        if targetKey then
                            desc:SetAttribute("AutoPlayed", true)
                            handleSmartHit(desc, targetKey)
                        end
                    end
                end
            end
            processed = processed + 1
        else
            noteCachePool[desc] = nil
        end
    end
end)

task.spawn(function()
    while not HorizonUnloaded do
        if Config.Enabled and Config.AlwaysPerfect and getgc then
            if not next(noteCachePool) then
                pcall(function()
                local gcData = getgc(true)
                for i, obj in ipairs(gcData) do
                    if i % 1000 == 0 then task.wait() end
                    if typeof(obj) == "table" then
                        local hasHitFunc = rawget(obj, "Hit") or rawget(obj, "HitNote") or rawget(obj, "Judge") or rawget(obj, "OnHit") or rawget(obj, "RegisterHit") or rawget(obj, "CheckHit") or rawget(obj, "CalculateJudgment") or rawget(obj, "RateNote") or rawget(obj, "OnHitNote")
                        if hasHitFunc and typeof(hasHitFunc) == "function" and not rawget(obj, "__GakuranHooked") then
                            rawset(obj, "__GakuranHooked", true)
                            for _, methodName in ipairs({"Hit", "HitNote", "OnHit", "OnHitNote", "RegisterHit", "CheckHit", "PressNote", "PlayNote", "InputHit", "AddHit", "AddJudgment", "RegisterJudgment"}) do
                                if rawget(obj, methodName) and typeof(rawget(obj, methodName)) == "function" then
                                    local orig = rawget(obj, methodName)
                                    obj[methodName] = function(self, ...)
                                        if not Config.AlwaysPerfect then return orig(self, ...) end
                                        local strVal, numVal, accVal, offVal = getTargetJudgmentData()
                                        local args = {...}
                                        for i = 1, #args do
                                            if typeof(args[i]) == "string" then
                                                local lower = string.lower(args[i])
                                                if lower == "good" or lower == "ok" or lower == "okay" or lower == "bad" or lower == "miss" or lower == "late" or lower == "early" or lower == "great" or lower == "perfect" then
                                                    args[i] = strVal
                                                end
                                            elseif typeof(args[i]) == "number" then
                                                if args[i] == 0 or args[i] == 1 or args[i] == 2 or args[i] == 3 or args[i] == 4 then
                                                    args[i] = numVal
                                                elseif math.abs(args[i]) > 0.001 and math.abs(args[i]) < 0.35 then
                                                    args[i] = offVal
                                                end
                                            elseif typeof(args[i]) == "table" then
                                                if args[i].Judgment then args[i].Judgment = strVal end
                                                if args[i].Judgement then args[i].Judgement = strVal end
                                                if args[i].Acc and typeof(args[i].Acc) == "string" then args[i].Acc = strVal end
                                                if args[i].Accuracy and typeof(args[i].Accuracy) == "number" then args[i].Accuracy = accVal end
                                                if args[i].Offset and typeof(args[i].Offset) == "number" then args[i].Offset = offVal end
                                            end
                                        end
                                        return orig(self, unpack(args))
                                    end
                                end
                            end
                            for _, methodName in ipairs({"MissNote", "OnMiss", "AddMiss", "RegisterMiss"}) do
                                if rawget(obj, methodName) and typeof(rawget(obj, methodName)) == "function" then
                                    local orig = rawget(obj, methodName)
                                    obj[methodName] = function(self, ...)
                                        if not Config.AlwaysPerfect then return orig(self, ...) end
                                        local strVal = getTargetJudgmentData()
                                        if strVal == "Miss" then return orig(self, ...) end
                                        if rawget(self, "Hit") and typeof(rawget(self, "Hit")) == "function" then
                                            return rawget(self, "Hit")(self, ..., strVal)
                                        elseif rawget(self, "HitNote") and typeof(rawget(self, "HitNote")) == "function" then
                                            return rawget(self, "HitNote")(self, ..., strVal)
                                        end
                                        return nil
                                    end
                                end
                            end
                            for _, methodName in ipairs({"Judge", "JudgeNote", "GetJudgment", "CalculateJudgment", "RateNote"}) do
                                if rawget(obj, methodName) and typeof(rawget(obj, methodName)) == "function" then
                                    local orig = rawget(obj, methodName)
                                    obj[methodName] = function(self, ...)
                                        if not Config.AlwaysPerfect then return orig(self, ...) end
                                        local res = orig(self, ...)
                                        local strVal, numVal, accVal = getTargetJudgmentData()
                                        if typeof(res) == "string" then return strVal end
                                        if typeof(res) == "number" and (res == 0 or res == 1 or res == 2 or res == 3 or res == 4) then return numVal end
                                        if typeof(res) == "number" and res > 0 and res <= 100 then return accVal end
                                        if typeof(res) == "table" then
                                            if res.Judgment then res.Judgment = strVal end
                                            if res.Judgement then res.Judgement = strVal end
                                            if res.Acc and typeof(res.Acc) == "string" then res.Acc = strVal end
                                            if res.Accuracy and typeof(res.Accuracy) == "number" then res.Accuracy = accVal end
                                        end
                                        return res
                                    end
                                end
                            end
                        end
                    end
                end
                end)
            end
        end
        task.wait(3)
    end
end)

if hookmetamethod then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        if HorizonUnloaded then return oldNamecall(self, ...) end
        local method = getnamecallmethod()
        local args = {...}
        
        if Config.Enabled and Config.AlwaysPerfect and (method == "FireServer" or method == "InvokeServer") then
            local remoteName = string.lower(self.Name)
            if string.find(remoteName, "hit") or string.find(remoteName, "note") or string.find(remoteName, "rhythm") or string.find(remoteName, "instrument") or string.find(remoteName, "drum") or string.find(remoteName, "judge") or string.find(remoteName, "score") or string.find(remoteName, "tap") or string.find(remoteName, "play") or string.find(remoteName, "input") or string.find(remoteName, "event") then
                local strVal, numVal, accVal, offVal = getTargetJudgmentData()
                for i = 1, #args do
                    if typeof(args[i]) == "string" then
                        local lowerArg = string.lower(args[i])
                        if lowerArg == "good" or lowerArg == "ok" or lowerArg == "okay" or lowerArg == "bad" or lowerArg == "miss" or lowerArg == "late" or lowerArg == "early" or lowerArg == "great" or lowerArg == "perfect" then
                            args[i] = strVal
                        end
                    elseif typeof(args[i]) == "table" then
                        if args[i].Judgment then args[i].Judgment = strVal end
                        if args[i].Judgement then args[i].Judgement = strVal end
                    end
                end
            end
        end
        return oldNamecall(self, unpack(args))
    end)
end

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
    RunService.RenderStepped:Connect(function(deltaTime)
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