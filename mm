--[[ ===== OBSIDIAN WHITELIST CHECKPOINT ===== ]]--
do
    local SITE_URL   = "https://panel-validator.preview.emergentagent.com"
    local POLL_EVERY = 2

    local HttpService = game:GetService("HttpService")
    local CoreGui     = game:GetService("CoreGui")
    local plr         = game:GetService("Players").LocalPlayer
    local pGui        = plr:WaitForChild("PlayerGui")

    -- On récupère les infos du joueur pour bloquer l'accès aux autres comptes
    local playerName = plr and plr.Name or "Unknown"
    local playerId   = plr and tostring(plr.UserId) or "0"

    local function randKey()
        local charset = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        local t = {}
        for i = 1, 12 do
            local n = math.random(1, #charset)
            t[i] = charset:sub(n, n)
        end
        return table.concat(t)
    end

    local httpRequest = (syn and syn.request) or (http and http.request)
        or (fluxus and fluxus.request) or http_request or request

    local function apiGet(url)
        if not httpRequest then return nil end
        local ok, res = pcall(httpRequest, { Url = url, Method = "GET" })
        if not ok or not res or not res.Body then return nil end
        local decoded
        pcall(function() decoded = HttpService:JSONDecode(res.Body) end)
        return decoded
    end

    local setclip = setclipboard or (syn and syn.write_clipboard) or toclipboard
    math.randomseed(tick() * 1e6)
    local sessionKey  = randKey()
    
    -- On passe le pseudo et l'ID dans l'URL pour que le site web sache quel joueur essaie de se connecter
    local validateUrl = SITE_URL .. "/validate/" .. sessionKey .. "?player=" .. playerName
    if setclip then pcall(setclip, validateUrl) end

    local gui = Instance.new("ScreenGui")
    gui.Name = "ObsidianCheckpoint"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    pcall(function() gui.Parent = gethui and gethui() or CoreGui end)
    if not gui.Parent then gui.Parent = pGui end

    local dim = Instance.new("Frame", gui)
    dim.Size = UDim2.fromScale(1, 1)
    dim.BackgroundColor3 = Color3.fromRGB(7, 7, 10)
    dim.BackgroundTransparency = 0.15
    dim.BorderSizePixel = 0

    local card = Instance.new("Frame", gui)
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position = UDim2.fromScale(0.5, 0.5)
    card.Size = UDim2.fromOffset(460, 260)
    card.BackgroundColor3 = Color3.fromRGB(19, 19, 25)
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 16)
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = Color3.fromRGB(212, 175, 55)
    stroke.Transparency = 0.7
    stroke.Thickness = 1

    local title = Instance.new("TextLabel", card)
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(28, 24)
    title.Size = UDim2.new(1, -56, 0, 34)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Text = "Please validate your whitelist"

    local sub = Instance.new("TextLabel", card)
    sub.BackgroundTransparency = 1
    sub.Position = UDim2.fromOffset(28, 62)
    sub.Size = UDim2.new(1, -56, 0, 44)
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 13
    sub.TextWrapped = true
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.TextYAlignment = Enum.TextYAlignment.Top
    sub.TextColor3 = Color3.fromRGB(160, 158, 152)
    sub.Text = "Compte : " .. playerName .. " | L'URL a ete copiee dans ton presse-papier."

    local urlBox = Instance.new("TextLabel", card)
    urlBox.Position = UDim2.fromOffset(28, 118)
    urlBox.Size = UDim2.new(1, -56, 0, 40)
    urlBox.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
    urlBox.BorderSizePixel = 0
    urlBox.Font = Enum.Font.Code
    urlBox.TextSize = 13
    urlBox.TextColor3 = Color3.fromRGB(232, 200, 106)
    urlBox.TextXAlignment = Enum.TextXAlignment.Left
    urlBox.Text = "  " .. validateUrl
    Instance.new("UICorner", urlBox).CornerRadius = UDim.new(0, 10)

    local keyLbl = Instance.new("TextLabel", card)
    keyLbl.BackgroundTransparency = 1
    keyLbl.Position = UDim2.fromOffset(28, 172)
    keyLbl.Size = UDim2.new(1, -56, 0, 18)
    keyLbl.Font = Enum.Font.Code
    keyLbl.TextSize = 11
    keyLbl.TextXAlignment = Enum.TextXAlignment.Left
    keyLbl.TextColor3 = Color3.fromRGB(120, 118, 112)
    keyLbl.Text = "SESSION KEY  -  " .. sessionKey

    local status = Instance.new("TextLabel", card)
    status.BackgroundTransparency = 1
    status.Position = UDim2.fromOffset(28, 204)
    status.Size = UDim2.new(1, -56, 0, 26)
    status.Font = Enum.Font.GothamMedium
    status.TextSize = 13
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.TextColor3 = Color3.fromRGB(220, 20, 60)
    status.Text = "En attente de validation..."

    -- On envoie aussi l'ID ou le pseudo au serveur pour qu'il valide spécifiquement ce compte
    local statusUrl = SITE_URL .. "/api/whitelist/status/" .. sessionKey .. "?player=" .. playerId
    local validated = false
    
    task.spawn(function()
        while not validated do
            local data = apiGet(statusUrl)
            if data and data.validated == true then
                validated = true
                status.TextColor3 = Color3.fromRGB(74, 222, 128)
                status.Text = "Whitelist OK - chargement du panel..."
                task.wait(0.6)
                gui:Destroy()
                break
            end
            task.wait(POLL_EVERY)
        end
    end)

    while not validated do task.wait(0.25) end
end
--[[ ===== FIN CHECKPOINT - TON SCRIPT CONTINUE APRES ===== ]]--
loadstring(game:HttpGet("https://raw.githubusercontent.com/sfhubschool/mm2/main/mm2"))()
