-- Import Fluent Library
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Window Settings
local Window = Fluent:CreateWindow({
    Title = "VortexHub",
    SubTitle = "Optimized GUI with Features",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Main Features", Icon = "rbxassetid://4483345998" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "rbxassetid://4483345998" })
}

local LocalPlayer = game.Players.LocalPlayer
local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Humanoid = Char:WaitForChild("Humanoid")

-- ฟังก์ชัน FreezeCharacter (แยกออกมา)
local function freezeCharacter()
    local oldPos = Char.HumanoidRootPart.CFrame
    while _G.FreezeCharacter do
        task.wait(0.1)
        if Char and Char:FindFirstChild("HumanoidRootPart") then
            Char.HumanoidRootPart.CFrame = oldPos  -- Freeze at original position
        else
            break
        end
    end
end

-- Toggle สำหรับ FreezeCharacter
Tabs.Main:AddToggle("FreezeCharacter", { Title = "Freeze Character", Default = false }):OnChanged(function(v)
    _G.FreezeCharacter = v  -- Store the state of the toggle
    if v then
        -- เริ่มการแช่แข็งตัวละครเมื่อเปิดใช้งาน
        spawn(freezeCharacter)
    end
end)

-- ฟังก์ชัน AutoCast (Fishing Rod Auto-Cast)
local function autoCast()
    while _G.AutoCast do
        task.wait(0.1)
        local Rod = Char:FindFirstChildOfClass("Tool")
        if Rod and Rod:FindFirstChild("events") and Rod.events:FindFirstChild("cast") then
            Rod.events.cast:FireServer(100, 1)  -- Trigger cast event
        end
    end
end

-- Toggle สำหรับ AutoCast
Tabs.Main:AddToggle("AutoCast", { Title = "Enable AutoCast", Default = false }):OnChanged(function(v)
    _G.AutoCast = v
    if v then
        -- เริ่มฟังก์ชัน autoCast เมื่อเปิดใช้งาน
        spawn(autoCast)
    end
end)

-- ฟังก์ชัน AutoShake (Auto-Shake Mechanism)
local function autoShake()
    while _G.AutoShake do
        task.wait(0.01)
        local PlayerGUI = LocalPlayer:WaitForChild("PlayerGui")
        local shakeUI = PlayerGUI:FindFirstChild("shakeui")
        if shakeUI and shakeUI.Enabled then
            local safezone = shakeUI:FindFirstChild("safezone")
            if safezone then
                local button = safezone:FindFirstChild("button")
                if button and button:IsA("ImageButton") and button.Visible then
                    GuiService.SelectedObject = button
                    -- Simulate pressing the Enter key to shake
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                end
            end
        end
    end
end

-- Toggle สำหรับ AutoShake
Tabs.Main:AddToggle("AutoShake", { Title = "Enable AutoShake", Default = false }):OnChanged(function(v)
    _G.AutoShake = v
    if v then
        -- เริ่มฟังก์ชัน autoShake เมื่อเปิดใช้งาน
        spawn(autoShake)
    end
end)

-- ฟังก์ชัน AutoReel (Auto Reel When Fishing Finished)
local function autoReel()
    while _G.AutoReel do
        task.wait(0.1)  -- ลดการใช้ทรัพยากร
        for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
            if v:IsA("ScreenGui") and v.Name == "reel" then
                if v:FindFirstChild("bar") then
                    task.wait(0.15)
                    if ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("reelfinished") then
                        ReplicatedStorage.events.reelfinished:FireServer(100, true)  -- Trigger reel finish
                    end
                end
            end
        end
    end
end

-- Toggle สำหรับ AutoReel
Tabs.Main:AddToggle("AutoReel", { Title = "Enable AutoReel", Default = false }):OnChanged(function(v)
    _G.AutoReel = v
    if v then
        -- เริ่มฟังก์ชัน autoReel เมื่อเปิดใช้งาน
        spawn(autoReel)
    end
end)

-- ฟังก์ชัน Equip Item (Auto Equip Rod)
local function equipItem(itemName)
    local tool = LocalPlayer.Backpack:FindFirstChild(itemName)
    if tool then
        Humanoid:EquipTool(tool)
    else
        warn("Tool not found: " .. itemName)  -- แจ้งเตือนหากไม่พบอุปกรณ์
    end
end

-- ฟังก์ชัน Auto Equip Rod เมื่อหาเจอ
local function autoEquipRod()
    while _G.AutoEquipRod do
        task.wait(0.5)  -- ลดความถี่ในการตรวจสอบ
        for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find("rod") then
                equipItem(tool.Name)  -- Equip rod หากพบ
            end
        end
    end
end

-- Toggle สำหรับ AutoEquipRod
Tabs.Main:AddToggle("AutoEquipRod", { Title = "Auto Equip Rod", Default = false }):OnChanged(function(v)
    _G.AutoEquipRod = v
    if v then
        -- เริ่มฟังก์ชัน autoEquipRod เมื่อเปิดใช้งาน
        spawn(autoEquipRod)
    end
end)

-- SaveManager และ InterfaceManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("VortexHub")
SaveManager:SetFolder("VortexHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- โหลดการตั้งค่า
Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
