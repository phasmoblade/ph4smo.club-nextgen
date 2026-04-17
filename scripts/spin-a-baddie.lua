wait(3)

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local windowSize = isMobile and UDim2.fromOffset(420, 380) or UDim2.fromOffset(620, 480)

local Window = Fluent:CreateWindow({
    Title = "🎲 > ph4smo.club (nextgen) - Spin a Baddie",
    SubTitle = "by phasmoblade",
    TabWidth = 160,
    Size = windowSize,
    Acrylic = false,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.Home
})

if isMobile then
    local MinimizeButton = Window:AddButton({
        Title = "Toggle GUI",
        Callback = function()
            Window:Minimize()
        end
    })
end

local Players = game:GetService("Players")
local Tabs = {
    Info = Window:AddTab({ Title = "Info", Icon = "info" }),
    Main = Window:AddTab({ Title = "Main", Icon = "dice-6" }),
    Auto = Window:AddTab({ Title = "Auto", Icon = "play" }),
    Shop = Window:AddTab({ Title = "Shop", Icon = "shopping-cart" }),
    Stats = Window:AddTab({ Title = "Stats", Icon = "bar-chart-2" }),
    Notifications = Window:AddTab({ Title = "Notifications", Icon = "bell" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local executor = "Unknown"
if identifyexecutor then
    executor = identifyexecutor()
elseif KRNL_LOADED then
    executor = "KRNL"
elseif syn then
    executor = "Synapse X"
elseif SENTINEL_LOADED then
    executor = "Sentinel"
elseif getexecutorname then
    executor = getexecutorname()
end

local platform = "Unknown"
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
    platform = "Android/Mobile"
elseif UserInputService.KeyboardEnabled then
    platform = "Windows/PC"
end

local placeName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
local placeId = tostring(game.PlaceId)
local jobId = game.JobId

Tabs.Info:AddParagraph({
    Title = "👤 Player Information",
    Content = "Username: " .. LocalPlayer.Name .. "\nDisplay Name: " .. LocalPlayer.DisplayName .. "\nUser ID: " .. tostring(LocalPlayer.UserId) .. "\nAccount Age: " .. tostring(LocalPlayer.AccountAge) .. " days"
})

Tabs.Info:AddParagraph({
    Title = "💻 System Information",
    Content = "Executor: " .. executor .. "\nPlatform: " .. platform .. "\nFPS: " .. tostring(math.floor(workspace:GetRealPhysicsFPS()))
})

Tabs.Info:AddParagraph({
    Title = "🎮 Place Information",
    Content = "Place Name: " .. placeName .. "\nPlace ID: " .. placeId .. "\nJob ID: " .. jobId
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")
if not game:IsLoaded() then 
    game.Loaded:Wait() 
end
local GameStatus = ReplicatedStorage:FindFirstChild("status")
local Events = ReplicatedStorage:FindFirstChild("Events")
if not Events then
    warn("[ph4smo.club] Events folder not found! Waiting...")
    Events = ReplicatedStorage:WaitForChild("Events", 30)
end
local UpdateRollingDiceRemote = Events:FindFirstChild("updateRollingDice")
local PlaceBestBaddiesRemote = Events:FindFirstChild("PlaceBestBaddies")
local SponRequestRemote = Events:FindFirstChild("spinrequest")
local QuestRemote = Events:FindFirstChild("QuestRemote")
local BuyItemRemote = Events:FindFirstChild("buy")
local MerchantBuyRemote = Events:FindFirstChild("MerchantBuy")
local MerchantRequestRemote = Events:FindFirstChild("MerchantRequest")
local IndexRemote = Events:FindFirstChild("IndexRemote") or Events:FindFirstChild("ClaimIndex") or Events:FindFirstChild("Index")
local RebirthRemote = Events:FindFirstChild("Rebirth") or Events:FindFirstChild("rebirth") or Events:FindFirstChild("RebirthRequest")
print("[ph4smo.club] Remotes loaded:", {
    UpdateRollingDice = UpdateRollingDiceRemote ~= nil,
    PlaceBestBaddies = PlaceBestBaddiesRemote ~= nil,
    SponRequest = SponRequestRemote ~= nil,
    Quest = QuestRemote ~= nil,
    BuyItem = BuyItemRemote ~= nil,
    MerchantBuy = MerchantBuyRemote ~= nil,
    MerchantRequest = MerchantRequestRemote ~= nil,
    Index = IndexRemote ~= nil,
    Rebirth = RebirthRemote ~= nil
})
local GameEnv = getsenv(LocalPlayer.PlayerScripts:FindFirstChildOfClass("LocalScript"))._G
while not (GameEnv.Profile and GameEnv.Profile.Data) do
    task.wait()
end
local PotionsData = require(ReplicatedStorage.Modules.PotionData)
local DicesData = require(ReplicatedStorage.Modules.DiceData)
print("[ph4smo.club] Game data loaded successfully!")
print("[ph4smo.club] Dice count:", #DicesData)
print("[ph4smo.club] Potion count:", #PotionsData)
local Settings = {
    AutoRoll = false,
    AutoRoulette = false,
    AutoClaimQuests = false,
    AutoClaimIndex = false,
    AutoEquipBest = false,
    AutoBuyDiceStock = false,
    AutoBuyPotionStock = false,
    AutoBuyMerchant = false,
    AutoRebirth = false,
    RollBestFirst = true,
    SkipAnimations = true,
    SkipRollAnimation = false,
    AntiAFK = false,
    ChatNotifications = true,
    EquipBestCooldown = 180,
    SelectedDiceToBuy = {},
    SelectedPotionsToBuy = {},
    NotifyCommon = false,
    NotifyUncommon = false,
    NotifyRare = false,
    NotifyEpic = true,
    NotifyLegendary = true,
    NotifyMythic = true,
    NotifyDivine = true,
    NotifyPrismatic = true,
    NotifySacred = true,
    NotifySecret = true,
    NotifyGodly = true,
    NotifyCosmic = true,
    NotifyApex = true
}
local SeenBaddies = {}
local SeenBaddieNames = {}
local EQUIP_BEST_COOLDOWN = 0
local MerchantStock = nil
local NULITTY_SPAWN_CFRAME = CFrame.new(-58, 8, -19)
local OriginalPosition = nil
local Stats = {
    TotalRolls = 0,
    CommonRolls = 0,
    UncommonRolls = 0,
    RareRolls = 0,
    EpicRolls = 0,
    LegendaryRolls = 0,
    MythicRolls = 0,
    DivineRolls = 0,
    PrismaticRolls = 0,
    SacredRolls = 0,
    SecretRolls = 0,
    GodlyRolls = 0,
    CosmicRolls = 0,
    ApexRolls = 0
}
local function FormatNumber(num)
    if num < 1000 then
        return tostring(num)
    end
    local suffixes = {"", "K", "M", "B", "T", "Qd", "Qn", "Sx", "Sp", "Oc", "No", "Dc", "Ud", "Dd", "Td", "Qad", "Qid", "Sxd", "Spd", "Ocd", "Nod", "Vg"}
    local exp = math.floor(math.log10(num) / 3)
    if exp > #suffixes - 1 then
        exp = #suffixes - 1
    end
    local value = num / (10 ^ (exp * 3))
    if value >= 100 then
        return string.format("%.0f%s", value, suffixes[exp + 1])
    elseif value >= 10 then
        return string.format("%.1f%s", value, suffixes[exp + 1])
    else
        return string.format("%.2f%s", value, suffixes[exp + 1])
    end
end
local function GetCoins()
    return GameEnv.Profile.Data.Coins or 0
end
local function GetRebirths()
    return GameEnv.Profile.Data.Rebirths or 0
end
local function GetSpins()
    return LocalPlayer.rewards.SpinCount.Value
end
local function GetDiceStock()
    return GameEnv.Profile.Data.dice_stock
end
local function GetPotionStock()
    return GameEnv.Profile.Data.potion_stock
end
local function GetQuests()
    return (GameEnv.Profile.Data.quests or {}).active_quests
end
local function IsNullityActive()
    return GameStatus:GetAttribute("nullity_active")
end
local function GetRootPart()
    local Character = LocalPlayer.Character
    if Character then
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if Humanoid and Humanoid.Health > 0 then
            return Character:FindFirstChild("HumanoidRootPart")
        end
    end
    return nil
end
local function CheckCanPurchase(Data)
    if not Data.Not_Restockable then
        return (Data.Cost or 0) <= GetCoins() and (Data.RebirthsRequired or 0) <= GetRebirths()
    end
    return false
end
local function PurchaseItem(Category, ItemName, Data, StockAmount)
    local Affordability = math.floor(GetCoins() / Data.Cost)
    local MaxPurchase = math.min(StockAmount, Affordability)
    return BuyItemRemote:InvokeServer(ItemName, MaxPurchase, Category)
end
local function GetBestDice()
    local diceInventory = GameEnv.Profile.Data.dice or {}
    local availableDice = {}
    for diceName, amount in pairs(diceInventory) do
        if amount > 0 and DicesData[diceName] then
            table.insert(availableDice, {
                name = diceName,
                amount = amount,
                cost = DicesData[diceName].Cost or 0,
                rebirths = DicesData[diceName].RebirthsRequired or 0
            })
        end
    end
    if Settings.RollBestFirst then
        table.sort(availableDice, function(a, b)
            if a.cost == b.cost then
                return a.rebirths > b.rebirths
            end
            return a.cost > b.cost
        end)
    else
        table.sort(availableDice, function(a, b)
            if a.cost == b.cost then
                return a.rebirths < b.rebirths
            end
            return a.cost < b.cost
        end)
    end
    return availableDice[1] and availableDice[1].name or nil
end
local CachedGlove = {name = nil, bonus = 0, lastCheck = 0}
local function GetGloveSpeedBonus()
    local currentTime = tick()
    if (currentTime - CachedGlove.lastCheck) < 5 then
        return CachedGlove.bonus, CachedGlove.name
    end
    local bonus = 0
    local gloveName = nil
    pcall(function()
        if GameEnv and GameEnv.Profile and GameEnv.Profile.Data then
            gloveName = GameEnv.Profile.Data.Glove 
                     or GameEnv.Profile.Data.glove 
                     or GameEnv.Profile.Data.EquippedGlove 
                     or GameEnv.Profile.Data.equippedGlove
                     or GameEnv.Profile.Data.equipped_glove
        end
        if not gloveName then
            local playerData = LocalPlayer:FindFirstChild("PlayerData") 
                            or LocalPlayer:FindFirstChild("Data")
                            or LocalPlayer:FindFirstChild("leaderstats")
            if playerData then
                local gloveValue = playerData:FindFirstChild("Glove") 
                                or playerData:FindFirstChild("EquippedGlove")
                                or playerData:FindFirstChild("glove")
                if gloveValue then
                    if typeof(gloveValue) == "Instance" and gloveValue:IsA("StringValue") then
                        gloveName = gloveValue.Value
                    else
                        gloveName = gloveValue
                    end
                end
            end
        end
        if not gloveName and LocalPlayer.Character then
            local gloveModel = LocalPlayer.Character:FindFirstChild("Glove") 
                            or LocalPlayer.Character:FindFirstChild("RightHand"):FindFirstChildOfClass("Accessory")
            if gloveModel then
                gloveName = gloveModel.Name
            end
        end
        if not gloveName then
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            if backpack then
                for _, tool in pairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") and (tool.Name:lower():find("glove") or tool.Name:lower():find("gauntlet")) then
                        gloveName = tool.Name
                        break
                    end
                end
            end
        end
        if gloveName then
            local lowerName = tostring(gloveName):lower()
            if lowerName:find("void") then
                bonus = 0.70
            elseif lowerName:find("angelic") then
                bonus = 0.60
            elseif lowerName:find("solar") then
                bonus = 0.50
            elseif lowerName:find("lunar") then
                bonus = 0.40
            elseif lowerName:find("chroma") then
                bonus = 0.35
            elseif lowerName:find("molten") then
                bonus = 0.30
            elseif lowerName:find("ancient") then
                bonus = 0.25
            elseif lowerName:find("protector") then
                bonus = 0.20
            elseif lowerName:find("gauntlet") then
                bonus = 0.15
            elseif lowerName:find("apprentice") then
                bonus = 0.10
            elseif lowerName:find("novice") then
                bonus = 0.05
            end
        end
    end)
    CachedGlove.name = gloveName
    CachedGlove.bonus = bonus
    CachedGlove.lastCheck = currentTime
    return bonus, gloveName
end
local function GetOptimalRollDelay()
    local baseDelay = 0.5
    local gloveBonus, gloveName = GetGloveSpeedBonus()
    local finalDelay = baseDelay * (1 - gloveBonus)
    return math.max(finalDelay, 0.1)
end
local function RollNextDice()
    pcall(function()
        local RollState = LocalPlayer.PlayerGui.Main:FindFirstChild("RollState", true)
        if RollState then
            if Settings.RollBestFirst then
                local bestDice = GetBestDice()
                if bestDice then
                    pcall(function()
                        local EquipDiceRemote = Events:FindFirstChild("EquipDice") or Events:FindFirstChild("SelectDice")
                        if EquipDiceRemote then
                            EquipDiceRemote:FireServer(bestDice)
                        end
                    end)
                end
            end
            RollState:InvokeServer()
            Stats.TotalRolls = Stats.TotalRolls + 1
        end
    end)
end
local function RollRoulette()
    pcall(function()
        if GetSpins() > 0 then
            SponRequestRemote:InvokeServer()
        end
    end)
end
local function ClaimQuests()
    pcall(function()
        local ActiveQuests = GetQuests()
        if not ActiveQuests then return end
        for ID, Quest in pairs(ActiveQuests) do
            if Quest.completed and not Quest.claimed then
                QuestRemote:InvokeServer("ClaimReward", ID)
            end
        end
    end)
end
local function ClaimIndexRewards()
    pcall(function()
        if not IndexRemote then
            warn("[ph4smo.club] IndexRemote not found, skipping index claim")
            return
        end
        IndexRemote:InvokeServer("ClaimAll")
    end)
end
local function DoRebirth()
    pcall(function()
        if not RebirthRemote then
            warn("[ph4smo.club] RebirthRemote not found")
            return
        end
        RebirthRemote:InvokeServer()
    end)
end
local function EquipBestBaddies()
    pcall(function()
        if (tick() - EQUIP_BEST_COOLDOWN) > 0 then
            PlaceBestBaddiesRemote:InvokeServer()
            EQUIP_BEST_COOLDOWN = tick() + Settings.EquipBestCooldown
            Fluent:Notify({
                Title = "⚡ Auto Equip",
                Content = "Equipped best baddies!",
                Duration = 3
            })
        end
    end)
end
local function PurchaseDiceStock()
    pcall(function()
        local DiceStock = GetDiceStock()
        if not DiceStock or not next(DiceStock) then return end
        for DiceName, DiceData in pairs(DicesData) do
            if Settings.SelectedDiceToBuy[DiceName] then
                local StockAmount = DiceStock[DiceName] or 0
                if StockAmount > 0 and CheckCanPurchase(DiceData) then
                    if PurchaseItem("dice", DiceName, DiceData, StockAmount) then
                        DiceStock[DiceName] = 0
                    end
                end
            end
        end
    end)
end
local function PurchasePotionStock()
    pcall(function()
        local PotionStock = GetPotionStock()
        if not PotionStock or not next(PotionStock) then return end
        for PotionName, PotionData in pairs(PotionsData) do
            if Settings.SelectedPotionsToBuy[PotionName] then
                local StockAmount = PotionStock[PotionName] or 0
                if StockAmount > 0 and CheckCanPurchase(PotionData) then
                    if PurchaseItem("potion", PotionName, PotionData, StockAmount) then
                        PotionStock[PotionName] = 0
                    end
                end
            end
        end
    end)
end
local function RequestMerchantStock()
    pcall(function()
        if not Settings.AutoBuyMerchant then return end
        local RootPart = GetRootPart()
        if not RootPart then return end
        local targetPos = NULITTY_SPAWN_CFRAME
        local currentPos = RootPart.CFrame
        local distance = (targetPos.Position - currentPos.Position).Magnitude
        if distance > 5 then
            local steps = math.ceil(distance / 10)
            for i = 1, steps do
                if not Settings.AutoBuyMerchant then return end
                local alpha = i / steps
                RootPart.CFrame = currentPos:Lerp(targetPos, alpha)
                task.wait(0.1)
            end
        else
            RootPart.CFrame = targetPos
        end
        task.wait(1)
        MerchantStock = MerchantRequestRemote:InvokeServer()
        if not (MerchantStock and MerchantStock.wares) and workspace:FindFirstChild("Nullity") then
            local ProximityPrompt = workspace.Nullity:FindFirstChild("ProximityPrompt", true)
            if ProximityPrompt then
                fireproximityprompt(ProximityPrompt)
                task.wait(2)
                MerchantStock = MerchantRequestRemote:InvokeServer()
            end
        end
    end)
end
local MerchantBuying = false
local MerchantStockCleared = false
local function PurchaseMerchantStock()
    if MerchantBuying then return end
    if not Settings.AutoBuyMerchant then 
        MerchantStockCleared = false
        return 
    end
    if not IsNullityActive() then 
        MerchantStock = nil
        MerchantStockCleared = false
        return 
    end
    if MerchantStockCleared then return end
    MerchantBuying = true
    task.spawn(function()
        local success = pcall(function()
            local RootPart = GetRootPart()
            if not RootPart then 
                MerchantBuying = false
                MerchantStock = nil
                return 
            end
            OriginalPosition = RootPart.CFrame
            local attempts = 0
            MerchantStock = nil
            while not (MerchantStock and MerchantStock.wares) and IsNullityActive() and Settings.AutoBuyMerchant and attempts < 3 do
                RequestMerchantStock()
                task.wait(2)
                attempts = attempts + 1
            end
            if not Settings.AutoBuyMerchant then
                MerchantBuying = false
                MerchantStock = nil
                if OriginalPosition then
                    RootPart = GetRootPart()
                    if RootPart then
                        RootPart.CFrame = OriginalPosition
                    end
                    OriginalPosition = nil
                end
                return
            end
            if not IsNullityActive() then 
                MerchantBuying = false
                MerchantStock = nil
                MerchantStockCleared = false
                if OriginalPosition then
                    RootPart = GetRootPart()
                    if RootPart then
                        RootPart.CFrame = OriginalPosition
                    end
                    OriginalPosition = nil
                end
                return 
            end
            if not (MerchantStock and MerchantStock.wares) then 
                MerchantBuying = false
                MerchantStock = nil
                if OriginalPosition then
                    RootPart = GetRootPart()
                    if RootPart then
                        RootPart.CFrame = OriginalPosition
                    end
                    OriginalPosition = nil
                end
                return 
            end
            local purchasedCount = 0
            local skippedCount = 0
            local totalItems = 0
            for ID, StockData in pairs(MerchantStock.wares) do
                totalItems = totalItems + StockData.Stock
            end
            if totalItems == 0 then
                MerchantBuying = false
                MerchantStock = nil
                MerchantStockCleared = true
                if OriginalPosition then
                    RootPart = GetRootPart()
                    if RootPart then
                        RootPart.CFrame = OriginalPosition
                    end
                    OriginalPosition = nil
                end
                return
            end
            for ID, StockData in pairs(MerchantStock.wares) do
                if not Settings.AutoBuyMerchant then break end
                local DiceName = StockData.Name
                local diceData = DicesData[DiceName]
                if StockData.Stock > 0 and diceData then
                    if CheckCanPurchase(diceData) then
                        for index = StockData.Stock, 1, -1 do
                            if not Settings.AutoBuyMerchant then break end
                            task.wait(0.3)
                            local buySuccess = MerchantBuyRemote:InvokeServer(ID)
                            if buySuccess then
                                purchasedCount = purchasedCount + 1
                            end
                        end
                    else
                        skippedCount = skippedCount + StockData.Stock
                    end
                end
            end
            MerchantStockCleared = true
            if purchasedCount > 0 or skippedCount > 0 then
                local message = ""
                if purchasedCount > 0 then
                    message = "Purchased " .. purchasedCount .. " items!"
                end
                if skippedCount > 0 then
                    if purchasedCount > 0 then
                        message = message .. " (Skipped " .. skippedCount .. ")"
                    else
                        message = "Skipped " .. skippedCount .. " items (not enough coins/rebirths)"
                    end
                end
                Fluent:Notify({
                    Title = "🏪 Merchant",
                    Content = message,
                    Duration = 3
                })
            end
            MerchantStock = nil
        end)
        task.wait(1)
        if OriginalPosition then
            local RootPart = GetRootPart()
            if RootPart then
                RootPart.Anchored = true
                task.wait(0.2)
                RootPart.CFrame = OriginalPosition
                task.wait(0.3)
                RootPart.Anchored = false
            end
            OriginalPosition = nil
        end
        MerchantBuying = false
    end)
end
local function CheckRarity(baddieName, baddieObj)
    if baddieObj and SeenBaddies[baddieObj] then return end
    local lowerName = baddieName:lower()
    local uniqueKey = lowerName .. "_" .. tostring(os.time())
    if SeenBaddieNames[lowerName] then
        local lastTime = SeenBaddieNames[lowerName]
        if (os.time() - lastTime) < 2 then
            return
        end
    end
    SeenBaddieNames[lowerName] = os.time()
    if baddieObj then
        SeenBaddies[baddieObj] = true
    end
    local name = lowerName
    local rarity = "Common"
    if name:find("apex") then
        rarity = "Apex"
        Stats.ApexRolls = Stats.ApexRolls + 1
        if Settings.NotifyApex then
            Fluent:Notify({
                Title = "🏆 APEX!",
                Content = "You rolled: " .. baddieName,
                Duration = 15
            })
        end
    elseif name:find("cosmic") then
        rarity = "Cosmic"
        Stats.CosmicRolls = Stats.CosmicRolls + 1
        if Settings.NotifyCosmic then
            Fluent:Notify({
                Title = "✨ COSMIC!",
                Content = "You rolled: " .. baddieName,
                Duration = 12
            })
        end
    elseif name:find("godly") then
        rarity = "Godly"
        Stats.GodlyRolls = Stats.GodlyRolls + 1
        if Settings.NotifyGodly then
            Fluent:Notify({
                Title = "⚡ GODLY!",
                Content = "You rolled: " .. baddieName,
                Duration = 12
            })
        end
    elseif name:find("secret") then
        rarity = "Secret"
        Stats.SecretRolls = Stats.SecretRolls + 1
        if Settings.NotifySecret then
            Fluent:Notify({
                Title = "🔮 SECRET!",
                Content = "You rolled: " .. baddieName,
                Duration = 10
            })
        end
    elseif name:find("sacred") then
        rarity = "Sacred"
        Stats.SacredRolls = Stats.SacredRolls + 1
        if Settings.NotifySacred then
            Fluent:Notify({
                Title = "🌟 SACRED!",
                Content = "You rolled: " .. baddieName,
                Duration = 10
            })
        end
    elseif name:find("prismatic") then
        rarity = "Prismatic"
        Stats.PrismaticRolls = Stats.PrismaticRolls + 1
        if Settings.NotifyPrismatic then
            Fluent:Notify({
                Title = "🌈 PRISMATIC!",
                Content = "You rolled: " .. baddieName,
                Duration = 10
            })
        end
    elseif name:find("divine") then
        rarity = "Divine"
        Stats.DivineRolls = Stats.DivineRolls + 1
        if Settings.NotifyDivine then
            Fluent:Notify({
                Title = "👑 DIVINE!",
                Content = "You rolled: " .. baddieName,
                Duration = 10
            })
        end
    elseif name:find("mythic") or name:find("mythical") then
        rarity = "Mythic"
        Stats.MythicRolls = Stats.MythicRolls + 1
        if Settings.NotifyMythic then
            Fluent:Notify({
                Title = "💎 MYTHIC!",
                Content = "You rolled: " .. baddieName,
                Duration = 8
            })
        end
    elseif name:find("legendary") or name:find("legend") then
        rarity = "Legendary"
        Stats.LegendaryRolls = Stats.LegendaryRolls + 1
        if Settings.NotifyLegendary then
            Fluent:Notify({
                Title = "🔥 LEGENDARY!",
                Content = "You rolled: " .. baddieName,
                Duration = 7
            })
        end
    elseif name:find("epic") then
        rarity = "Epic"
        Stats.EpicRolls = Stats.EpicRolls + 1
        if Settings.NotifyEpic then
            Fluent:Notify({
                Title = "💜 Epic!",
                Content = "You rolled: " .. baddieName,
                Duration = 5
            })
        end
    elseif name:find("rare") then
        rarity = "Rare"
        Stats.RareRolls = Stats.RareRolls + 1
        if Settings.NotifyRare then
            Fluent:Notify({
                Title = "💙 Rare",
                Content = "You rolled: " .. baddieName,
                Duration = 3
            })
        end
    elseif name:find("uncommon") then
        rarity = "Uncommon"
        Stats.UncommonRolls = Stats.UncommonRolls + 1
        if Settings.NotifyUncommon then
            Fluent:Notify({
                Title = "💚 Uncommon",
                Content = "You rolled: " .. baddieName,
                Duration = 2
            })
        end
    else
        rarity = "Common"
        Stats.CommonRolls = Stats.CommonRolls + 1
        if Settings.NotifyCommon then
            Fluent:Notify({
                Title = "⚪ Common",
                Content = "You rolled: " .. baddieName,
                Duration = 1
            })
        end
    end
    return rarity
end
Tabs.Main:AddParagraph({
    Title = "🎲 Auto Roll",
    Content = "Automatically roll dice to get baddies"
})
Tabs.Main:AddToggle("AutoRoll", {
    Title = "Auto Roll",
    Description = "Automatically roll dice",
    Default = false,
    Callback = function(Value)
        Settings.AutoRoll = Value
    end
})
Tabs.Main:AddToggle("SkipRollAnimation", {
    Title = "Skip Roll Animation",
    Description = "Instantly skip dice opening animation",
    Default = false,
    Callback = function(Value)
        Settings.SkipRollAnimation = Value
        if Value then
            SetupSkipRollAnimation()
        end
    end
})
Tabs.Main:AddToggle("AntiAFK", {
    Title = "Anti-AFK",
    Description = "Prevent being kicked for inactivity",
    Default = false,
    Callback = function(Value)
        Settings.AntiAFK = Value
        if Value then
            SetupAntiAFK()
        end
    end
})
Tabs.Main:AddToggle("ChatNotifications", {
    Title = "Chat Notifications",
    Description = "Get notified when you roll rare baddies (from chat)",
    Default = true,
    Callback = function(Value)
        Settings.ChatNotifications = Value
    end
})
Tabs.Main:AddToggle("RollBestFirst", {
    Title = "Roll Best Dice First",
    Description = "Automatically use most expensive dice first",
    Default = true,
    Callback = function(Value)
        Settings.RollBestFirst = Value
    end
})
Tabs.Main:AddButton({
    Title = "Roll Once",
    Description = "Roll dice one time",
    Callback = function()
        RollNextDice()
        Fluent:Notify({
            Title = "Roll",
            Content = "Rolled dice once!",
            Duration = 2
        })
    end
})
Tabs.Main:AddParagraph({
    Title = "🎰 Roulette",
    Content = "Auto spin fortune wheel"
})
Tabs.Main:AddToggle("AutoRoulette", {
    Title = "Roulette",
    Description = "Automatically spin fortune wheel",
    Default = false,
    Callback = function(Value)
        Settings.AutoRoulette = Value
    end
})
Tabs.Main:AddButton({
    Title = "Spin Once",
    Description = "Spin roulette one time",
    Callback = function()
        RollRoulette()
        Fluent:Notify({
            Title = "Roulette",
            Content = "Spun the wheel!",
            Duration = 2
        })
    end
})
Tabs.Auto:AddParagraph({
    Title = "⚡ Auto Features",
    Content = "Automation features for the game"
})
Tabs.Auto:AddToggle("AutoEquipBest", {
    Title = "Auto Equip Best",
    Description = "Automatically equip best baddies",
    Default = false,
    Callback = function(Value)
        Settings.AutoEquipBest = Value
    end
})
Tabs.Auto:AddSlider("EquipBestCooldown", {
    Title = "Equip Cooldown",
    Description = "Cooldown between auto equips (seconds)",
    Default = 180,
    Min = 30,
    Max = 600,
    Rounding = 0,
    Callback = function(Value)
        Settings.EquipBestCooldown = Value
    end
})
Tabs.Auto:AddButton({
    Title = "Equip Best Now",
    Description = "Equip best baddies right now",
    Callback = function()
        EQUIP_BEST_COOLDOWN = 0
        EquipBestBaddies()
    end
})
Tabs.Auto:AddParagraph({
    Title = "📚 Quests & Index",
    Content = "Automatically claim rewards"
})
Tabs.Auto:AddToggle("AutoClaimQuests", {
    Title = "Auto Claim Quests",
    Description = "Automatically claim completed quests",
    Default = false,
    Callback = function(Value)
        Settings.AutoClaimQuests = Value
    end
})
Tabs.Auto:AddButton({
    Title = "Claim Quests Now",
    Description = "Claim all completed quests",
    Callback = function()
        ClaimQuests()
        Fluent:Notify({
            Title = "Auto Claim Quests",
            Content = "Claimed all completed quests!",
            Duration = 2
        })
    end
})
Tabs.Auto:AddToggle("AutoClaimIndex", {
    Title = "Auto Claim Index",
    Description = "Automatically claim index rewards (gems)",
    Default = false,
    Callback = function(Value)
        Settings.AutoClaimIndex = Value
    end
})
Tabs.Auto:AddButton({
    Title = "Claim Index Now",
    Description = "Claim all index rewards",
    Callback = function()
        ClaimIndexRewards()
        Fluent:Notify({
            Title = "Index",
            Content = "Claimed all index rewards!",
            Duration = 2
        })
    end
})
Tabs.Auto:AddParagraph({
    Title = "🔄 Rebirth",
    Content = "Automatically rebirth when possible"
})
Tabs.Auto:AddToggle("AutoRebirth", {
    Title = "Rebirth",
    Description = "Automatically rebirth when you have enough coins",
    Default = false,
    Callback = function(Value)
        Settings.AutoRebirth = Value
    end
})
Tabs.Auto:AddButton({
    Title = "Rebirth Now",
    Description = "Rebirth right now",
    Callback = function()
        DoRebirth()
        Fluent:Notify({
            Title = "Rebirth",
            Content = "Rebirthed!",
            Duration = 2
        })
    end
})
Tabs.Shop:AddParagraph({
    Title = "🎲 Dice Auto-Buy",
    Content = "Configure automatic dice purchasing"
})
Tabs.Shop:AddToggle("AutoBuyDiceStock", {
    Title = "Auto Buy Dice Stock",
    Description = "Automatically purchase selected dice from stock",
    Default = false,
    Callback = function(Value)
        Settings.AutoBuyDiceStock = Value
    end
})
Tabs.Shop:AddParagraph({
    Title = "🎲 Dice Selection",
    Content = "Select which dice to auto-buy from stock"
})
local diceList = {}
local diceDataList = {}
for DiceName, DiceData in pairs(DicesData) do
    local cost = DiceData.Cost or 0
    local rebirths = DiceData.RebirthsRequired or 0
    table.insert(diceDataList, {
        name = DiceName,
        cost = cost,
        rebirths = rebirths
    })
end
table.sort(diceDataList, function(a, b)
    if a.cost == b.cost then
        return a.rebirths < b.rebirths
    end
    return a.cost < b.cost
end)
for _, data in ipairs(diceDataList) do
    table.insert(diceList, string.format("%s (%s | Rebirths: %d)", data.name, FormatNumber(data.cost), data.rebirths))
end
local DiceDropdown = Tabs.Shop:AddDropdown("DiceSelection", {
    Title = "Select Dice",
    Description = "Choose which dice to auto-buy",
    Values = diceList,
    Multi = true,
    Default = {}
})
DiceDropdown:OnChanged(function(Value)
    Settings.SelectedDiceToBuy = {}
    for displayName, isSelected in pairs(Value) do
        if isSelected then
            local diceName = displayName:match("^(.+)%s%(")
            if diceName then
                Settings.SelectedDiceToBuy[diceName] = true
            end
        end
    end
end)
Tabs.Shop:AddButton({
    Title = "Select All Dice",
    Description = "Enable auto-buy for all dice",
    Callback = function()
        local allDice = {}
        for _, displayName in ipairs(diceList) do
            allDice[displayName] = true
        end
        DiceDropdown:SetValue(allDice)
        Fluent:Notify({
            Title = "Dice Selection",
            Content = "All dice selected for auto-buy!",
            Duration = 2
        })
    end
})
Tabs.Shop:AddButton({
    Title = "Deselect All Dice",
    Description = "Disable auto-buy for all dice",
    Callback = function()
        DiceDropdown:SetValue({})
        Settings.SelectedDiceToBuy = {}
        Fluent:Notify({
            Title = "🎲 Dice Selection",
            Content = "All dice deselected!",
            Duration = 2
        })
    end
})
Tabs.Shop:AddParagraph({
    Title = "🧪 Potion Auto-Buy",
    Content = "Configure automatic potion purchasing"
})
Tabs.Shop:AddToggle("AutoBuyPotionStock", {
    Title = "Auto Buy Potion Stock",
    Description = "Automatically purchase selected potions from stock",
    Default = false,
    Callback = function(Value)
        Settings.AutoBuyPotionStock = Value
    end
})
Tabs.Shop:AddParagraph({
    Title = "🧪 Potion Selection",
    Content = "Select which potions to auto-buy from stock"
})
local potionList = {}
local potionDataList = {}
for PotionName, PotionData in pairs(PotionsData) do
    local cost = PotionData.Cost or 0
    local rebirths = PotionData.RebirthsRequired or 0
    table.insert(potionDataList, {
        name = PotionName,
        cost = cost,
        rebirths = rebirths
    })
end
table.sort(potionDataList, function(a, b)
    if a.cost == b.cost then
        return a.rebirths < b.rebirths
    end
    return a.cost < b.cost
end)
for _, data in ipairs(potionDataList) do
    table.insert(potionList, string.format("%s (%s | Rebirths: %d)", data.name, FormatNumber(data.cost), data.rebirths))
end
local PotionDropdown = Tabs.Shop:AddDropdown("PotionSelection", {
    Title = "Select Potions",
    Description = "Choose which potions to auto-buy",
    Values = potionList,
    Multi = true,
    Default = {}
})
PotionDropdown:OnChanged(function(Value)
    Settings.SelectedPotionsToBuy = {}
    for displayName, isSelected in pairs(Value) do
        if isSelected then
            local potionName = displayName:match("^(.+)%s%(")
            if potionName then
                Settings.SelectedPotionsToBuy[potionName] = true
            end
        end
    end
end)
Tabs.Shop:AddButton({
    Title = "Select All Potions",
    Description = "Enable auto-buy for all potions",
    Callback = function()
        local allPotions = {}
        for _, displayName in ipairs(potionList) do
            allPotions[displayName] = true
        end
        PotionDropdown:SetValue(allPotions)
        Fluent:Notify({
            Title = "Potion Selection",
            Content = "All potions selected for auto-buy!",
            Duration = 2
        })
    end
})
Tabs.Shop:AddButton({
    Title = "Deselect All Potions",
    Description = "Disable auto-buy for all potions",
    Callback = function()
        PotionDropdown:SetValue({})
        Settings.SelectedPotionsToBuy = {}
        Fluent:Notify({
            Title = "🧪 Potion Selection",
            Content = "All potions deselected!",
            Duration = 2
        })
    end
})
Tabs.Shop:AddParagraph({
    Title = "🏪 Merchant Auto-Buy",
    Content = "Automatically purchase from Nullity merchant"
})
Tabs.Shop:AddToggle("AutoBuyMerchant", {
    Title = "Auto Buy Merchant",
    Description = "Automatically purchase from merchant when available",
    Default = false,
    Callback = function(Value)
        Settings.AutoBuyMerchant = Value
    end
})
Tabs.Stats:AddParagraph({
    Title = "📊 Statistics",
    Content = "Your rolling statistics"
})
local GloveLabel = Tabs.Stats:AddParagraph({
    Title = "🧤 Current Glove",
    Content = "No glove equipped (0% speed bonus)"
})
local StatsLabel = Tabs.Stats:AddParagraph({
    Title = "Stats",
    Content = "Total Rolls: 0\nCommon: 0 | Uncommon: 0 | Rare: 0\nEpic: 0 | Legendary: 0 | Mythic: 0\nDivine: 0 | Prismatic: 0 | Sacred: 0\nSecret: 0 | Godly: 0 | Cosmic: 0 | Apex: 0"
})
Tabs.Stats:AddButton({
    Title = "Reset Stats",
    Description = "Reset all statistics",
    Callback = function()
        Stats.TotalRolls = 0
        Stats.CommonRolls = 0
        Stats.UncommonRolls = 0
        Stats.RareRolls = 0
        Stats.EpicRolls = 0
        Stats.LegendaryRolls = 0
        Stats.MythicRolls = 0
        Stats.DivineRolls = 0
        Stats.PrismaticRolls = 0
        Stats.SacredRolls = 0
        Stats.SecretRolls = 0
        Stats.GodlyRolls = 0
        Stats.CosmicRolls = 0
        Stats.ApexRolls = 0
        SeenBaddies = {}
        SeenBaddieNames = {}
        Fluent:Notify({
            Title = "Stats Reset",
            Content = "All statistics have been reset",
            Duration = 2
        })
    end
})
Tabs.Notifications:AddParagraph({
    Title = "🔔 Chat Notifications",
    Content = "Choose which rarities to notify"
})
local rarities = {
    {name = "Common", default = false},
    {name = "Uncommon", default = false},
    {name = "Rare", default = false},
    {name = "Epic", default = true},
    {name = "Legendary", default = true},
    {name = "Mythic", default = true},
    {name = "Divine", default = true},
    {name = "Prismatic", default = true},
    {name = "Sacred", default = true},
    {name = "Secret", default = true},
    {name = "Godly", default = true},
    {name = "Cosmic", default = true},
    {name = "Apex", default = true}
}
for _, rarity in ipairs(rarities) do
    Tabs.Notifications:AddToggle("Notify" .. rarity.name, {
        Title = "Notify " .. rarity.name,
        Description = "Show notification for " .. rarity.name:lower() .. " rolls",
        Default = rarity.default,
        Callback = function(Value)
            Settings["Notify" .. rarity.name] = Value
        end
    })
end
task.spawn(function()
    local lastRollTime = 0
    local lastRouletteTime = 0
    local lastQuestTime = 0
    local lastIndexTime = 0
    local lastEquipTime = 0
    local lastBuyTime = 0
    local lastRebirthTime = 0
    while true do
        local currentTime = tick()
        local rollDelay = GetOptimalRollDelay()
        pcall(function()
            if Settings.AutoRoll and (currentTime - lastRollTime) >= rollDelay then
                RollNextDice()
                lastRollTime = currentTime
            end
            if Settings.AutoRoulette and (currentTime - lastRouletteTime) >= 0.5 then
                RollRoulette()
                lastRouletteTime = currentTime
            end
            if Settings.AutoClaimQuests and (currentTime - lastQuestTime) >= 2 then
                ClaimQuests()
                lastQuestTime = currentTime
            end
            if Settings.AutoClaimIndex and (currentTime - lastIndexTime) >= 3 then
                ClaimIndexRewards()
                lastIndexTime = currentTime
            end
            if Settings.AutoEquipBest and (currentTime - lastEquipTime) >= 5 then
                EquipBestBaddies()
                lastEquipTime = currentTime
            end
            if Settings.AutoRebirth and (currentTime - lastRebirthTime) >= 1 then
                DoRebirth()
                lastRebirthTime = currentTime
            end
            if (Settings.AutoBuyDiceStock or Settings.AutoBuyPotionStock or Settings.AutoBuyMerchant) and (currentTime - lastBuyTime) >= 10 then
                if Settings.AutoBuyDiceStock then
                    PurchaseDiceStock()
                end
                if Settings.AutoBuyPotionStock then
                    PurchasePotionStock()
                end
                if Settings.AutoBuyMerchant then
                    PurchaseMerchantStock()
                end
                lastBuyTime = currentTime
            end
        end)
        task.wait(0.05)
    end
end)
task.spawn(function()
    while task.wait(3) do
        pcall(function()
            local gloveBonus, gloveName = GetGloveSpeedBonus()
            local displayName = gloveName or "No glove"
            local bonusPercent = math.floor(gloveBonus * 100)
            GloveLabel:SetDesc(
                displayName .. " equipped\n" ..
                "Speed Bonus: +" .. bonusPercent .. "%\n" ..
                "Roll Delay: " .. string.format("%.2f", GetOptimalRollDelay()) .. "s"
            )
            StatsLabel:SetDesc(
                "Total Rolls: " .. Stats.TotalRolls .. "\n" ..
                "Common: " .. Stats.CommonRolls .. " | Uncommon: " .. Stats.UncommonRolls .. " | Rare: " .. Stats.RareRolls .. "\n" ..
                "Epic: " .. Stats.EpicRolls .. " | Legendary: " .. Stats.LegendaryRolls .. " | Mythic: " .. Stats.MythicRolls .. "\n" ..
                "Divine: " .. Stats.DivineRolls .. " | Prismatic: " .. Stats.PrismaticRolls .. " | Sacred: " .. Stats.SacredRolls .. "\n" ..
                "Secret: " .. Stats.SecretRolls .. " | Godly: " .. Stats.GodlyRolls .. " | Cosmic: " .. Stats.CosmicRolls .. " | Apex: " .. Stats.ApexRolls
            )
        end)
    end
end)
local lastBaddieCheck = 0
workspace.DescendantAdded:Connect(function(obj)
    if not obj:IsA("Model") then return end
    local now = tick()
    if (now - lastBaddieCheck) < 0.1 then return end
    task.spawn(function()
        pcall(function()
            local name = obj.Name
            local nameLower = name:lower()
            local isBaddie = nameLower:find("common") or nameLower:find("uncommon") or 
                           nameLower:find("rare") or nameLower:find("epic") or 
                           nameLower:find("legendary") or nameLower:find("mythic") or
                           nameLower:find("divine") or nameLower:find("prismatic") or
                           nameLower:find("sacred") or nameLower:find("secret") or
                           nameLower:find("godly") or nameLower:find("cosmic") or
                           nameLower:find("apex") or nameLower:find("baddie")
            if isBaddie then
                lastBaddieCheck = now
                CheckRarity(name, obj)
            end
        end)
    end)
end)
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("ph4smo_SpinABaddie")
SaveManager:SetFolder("ph4smo_SpinABaddie/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
Tabs.Settings:AddButton({
    Title = "UnHook",
    Description = "Unload the script",
    Callback = function()
        Window:Dialog({
            Title = "UnHook Confirmation",
            Content = "Are you sure you want to unload the script?",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        Settings.AutoRoll = false
                        Settings.AutoRoulette = false
                        Settings.AutoClaimQuests = false
                        Settings.AutoClaimIndex = false
                        Settings.AutoEquipBest = false
                        Settings.AutoBuyDiceStock = false
                        Settings.AutoBuyPotionStock = false
                        Settings.AutoBuyMerchant = false
                        Fluent:Destroy()
                    end
                },
                {
                    Title = "Cancel",
                    Callback = function()
                        print("UnHook cancelled")
                    end
                }
            }
        })
    end
})
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()
local function SetupChatMonitoring()
    local seenMessages = {}
    local function ProcessChatMessage(message)
        if not Settings.ChatNotifications then return end
        if seenMessages[message] then return end
        seenMessages[message] = true
        local lowerMsg = message:lower()
        local playerName = LocalPlayer.Name:lower()
        if not lowerMsg:find(playerName) then return end
        if not lowerMsg:find("rolled") then return end
        local baddieName = message:match("rolled a (.+) in") or message:match("rolled a (.+)%(") or message:match("rolled a (.+)!")
        if not baddieName then return end
        CheckRarity(baddieName, nil)
    end
    pcall(function()
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local channels = TextChatService:WaitForChild("TextChannels", 5)
            if channels then
                local generalChannel = channels:FindFirstChild("RBXGeneral")
                if generalChannel then
                    generalChannel.MessageReceived:Connect(function(message)
                        ProcessChatMessage(message.Text)
                    end)
                end
            end
        else
            local Players = game:GetService("Players")
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local DefaultChatSystemChatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if DefaultChatSystemChatEvents then
                local OnMessageDoneFiltering = DefaultChatSystemChatEvents:FindFirstChild("OnMessageDoneFiltering")
                if OnMessageDoneFiltering then
                    OnMessageDoneFiltering.OnClientEvent:Connect(function(messageData)
                        if messageData and messageData.Message then
                            ProcessChatMessage(messageData.Message)
                        end
                    end)
                end
            end
        end
    end)
end
local AntiAFKActive = false
local function SetupAntiAFK()
    if AntiAFKActive then return end
    AntiAFKActive = true
    task.spawn(function()
        while Settings.AntiAFK do
            task.wait(math.random(120, 180))
            if Settings.AntiAFK and LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.Jump = true
                end
                local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(math.random(-15, 15)), 0)
                end
            end
        end
        AntiAFKActive = false
    end)
end
local SkipAnimationActive = false
local function SetupSkipRollAnimation()
    if SkipAnimationActive then return end
    SkipAnimationActive = true
    task.spawn(function()
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        while Settings.SkipRollAnimation do
            local success = pcall(function()
                for _, gui in pairs(playerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") and gui.Enabled then
                        local rollFrame = gui:FindFirstChild("Roll", true) 
                                       or gui:FindFirstChild("RollFrame", true)
                                       or gui:FindFirstChild("Rolling", true)
                                       or gui:FindFirstChild("DiceRoll", true)
                        if rollFrame and rollFrame.Visible then
                            local gloveBonus = GetGloveSpeedBonus()
                            local skipDelay = math.max(0.05, 0.1 * (1 - gloveBonus))
                            local skipButton = rollFrame:FindFirstChild("Skip", true) 
                                            or rollFrame:FindFirstChild("SkipButton", true)
                                            or rollFrame:FindFirstChild("SkipBtn", true)
                                            or rollFrame:FindFirstChild("skip", true)
                            if skipButton and (skipButton:IsA("TextButton") or skipButton:IsA("ImageButton")) and skipButton.Visible then
                                task.wait(skipDelay)
                                for _, connection in pairs(getconnections(skipButton.MouseButton1Click)) do
                                    connection:Fire()
                                end
                                task.wait(skipDelay)
                            end
                            local closeButton = rollFrame:FindFirstChild("Close", true) 
                                             or rollFrame:FindFirstChild("CloseButton", true) 
                                             or rollFrame:FindFirstChild("X", true)
                                             or rollFrame:FindFirstChild("Exit", true)
                                             or rollFrame:FindFirstChild("close", true)
                            if closeButton and (closeButton:IsA("TextButton") or closeButton:IsA("ImageButton")) and closeButton.Visible then
                                task.wait(skipDelay)
                                for _, connection in pairs(getconnections(closeButton.MouseButton1Click)) do
                                    connection:Fire()
                                end
                            end
                            if rollFrame.Visible then
                                rollFrame.Visible = false
                            end
                            if gui.Enabled then
                                gui.Enabled = false
                            end
                        end
                    end
                end
            end)
            if not success then
                task.wait(0.1)
            else
                task.wait(0.05)
            end
        end
        SkipAnimationActive = false
    end)
end
SetupChatMonitoring()
task.spawn(function()
    while task.wait(1) do
        if Settings.AntiAFK and not AntiAFKActive then
            SetupAntiAFK()
        end
        if Settings.SkipRollAnimation then
            SetupSkipRollAnimation()
        end
    end
end)
Window:SelectTab(1)
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
    task.wait(0.5)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ph4smo_MobileButton"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 999
    local Button = Instance.new("TextButton")
    Button.Name = "ToggleButton"
    Button.Size = UDim2.new(0, 60, 0, 60)
    Button.Position = UDim2.new(0, 10, 0.5, -30)
    Button.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
    Button.Text = "🎲"
    Button.TextSize = 32
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.Font = Enum.Font.GothamBold
    Button.BorderSizePixel = 0
    Button.Active = true
    Button.Parent = ScreenGui
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Button
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(150, 100, 200)
    Stroke.Thickness = 2
    Stroke.Parent = Button
    local dragging = false
    local dragInput, dragStart, startPos
    local dragThreshold = 10
    local hasMoved = false
    Button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Button.Position
            hasMoved = false
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if not hasMoved then
                        local success, err = pcall(function()
                            Window:Minimize()
                        end)
                        if not success then
                            print("[ph4smo.club] Toggle error:", err)
                        end
                    end
                end
            end)
        end
    end)
    Button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            if delta.Magnitude > dragThreshold then
                hasMoved = true
            end
            if hasMoved then
                Button.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end
    end)
    ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    print("[ph4smo.club] Mobile button created! Tap to toggle menu")
end

-- Store original tab names
local OriginalTabNames = {
    Info = "📊 Info",
}

Fluent:Notify({
    Title = "👋 Welcome!",
    Content = "Welcome, " .. LocalPlayer.Name .. "!",
    SubContent = "Spin a Baddie script loaded successfully!",
    Duration = 5
})

task.wait(0.1)
Window:SelectTab(1)
