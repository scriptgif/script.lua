REDLINE-HUB/
│
├── Main.lua
│
├── Tabs/
│   ├── Home.lua
│   ├── Visual.lua
│   ├── Player.lua
│   ├── Settings.lua
│   └── About.lua
│
└── Modules/
    ├── ESP.lua
    └── Fly.lua


local SecurityCore = {}

SecurityCore.Version = "1.0.0"
SecurityCore.Initialized = false
SecurityCore.Errors = {}

function SecurityCore:Initialize()
    if self.Initialized then
        return false, "Security já inicializado"
    end

    self.Initialized = true

    return true, "Security iniciado"
end

function SecurityCore:LogError(message)
    table.insert(self.Errors, {
        Message = tostring(message),
        Time = os.time()
    })

    warn("[REDLINE SECURITY] " .. tostring(message))
end

function SecurityCore:GetStatus()
    return {
        Initialized = self.Initialized,
        Version = self.Version,
        ErrorCount = #self.Errors
    }
end

function SecurityCore:Shutdown()
    self.Initialized = false
end

return SecurityCore

local SecurityTab = {}

function SecurityTab.Create(parent, SecurityCore, COLORS)

    local function create(class, properties, target)
        local object = Instance.new(class)

        for key, value in pairs(properties) do
            object[key] = value
        end

        object.Parent = target
        return object
    end

    local container = create("Frame", {
        Name = "SecurityPage",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1
    }, parent)

    local title = create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 35),
        Position = UDim2.fromOffset(10, 8),
        BackgroundTransparency = 1,
        Text = "REDLINE SECURITY",
        TextColor3 = COLORS.White,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    }, container)

    local status = create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 35),
        Position = UDim2.fromOffset(10, 55),
        BackgroundColor3 = COLORS.Button,
        Text = "STATUS: VERIFICANDO",
        TextColor3 = COLORS.White,
        TextSize = 13,
        Font = Enum.Font.GothamBold
    }, container)

    local function updateStatus()
        local result = SecurityCore:GetStatus()

        status.Text = result.Initialized
            and "STATUS: ATIVO"
            or "STATUS: INATIVO"

        status.TextColor3 = result.Initialized
            and Color3.fromRGB(80, 220, 110)
            or COLORS.Red
    end

    local refresh = create("TextButton", {
        Size = UDim2.fromOffset(180, 38),
        Position = UDim2.fromOffset(10, 105),
        BackgroundColor3 = COLORS.RedDark,
        Text = "VERIFICAR STATUS",
        TextColor3 = COLORS.White,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = true
    }, container)

    refresh.MouseButton1Click:Connect(updateStatus)

    local errors = create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 35),
        Position = UDim2.fromOffset(10, 155),
        BackgroundTransparency = 1,
        Text = "Erros registrados: 0",
        TextColor3 = COLORS.Gray,
        TextSize = 12,
        Font = Enum.Font.Gotham
    }, container)

    local checkErrors = create("TextButton", {
        Size = UDim2.fromOffset(180, 38),
        Position = UDim2.fromOffset(10, 200),
        BackgroundColor3 = COLORS.Button,
        Text = "VER ERROS",
        TextColor3 = COLORS.White,
        TextSize = 12,
        Font = Enum.Font.GothamBold
    }, container)

    checkErrors.MouseButton1Click:Connect(function()
        local result = SecurityCore:GetStatus()
        errors.Text = "Erros registrados: " .. result.ErrorCount
    end)

    updateStatus()

    return container
end

return SecurityTab

function SecurityCore:CheckIntegrity()
    if type(self.Errors) ~= "table" then
        return false, "Registro de erros inválido"
    end

    if type(self.Initialized) ~= "boolean" then
        return false, "Estado inválido"
    end

    return true, "Verificação concluída"
end

local tabs = {
    {name = "Inicio", label = "INÍCIO"},
    {name = "Visual", label = "VISUAL"},
    {name = "Jogador", label = "JOGADOR"},
    {name = "Config", label = "CONFIGURAÇÕES"},
    {name = "Security", label = "SECURITY"},
    {name = "Sobre", label = "SOBRE"}
}

Security = {
    title = "REDLINE SECURITY",
    description = "Sistema de segurança interna.\n\nVerificação de integridade\nMonitoramento de erros\nControle de módulos"
},

local ESP = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local highlights = {}

ESP.Settings = {
    Enabled = true,
    ShowNames = true,
    ShowDistance = true,
    Color = Color3.fromRGB(220, 35, 45)
}

function ESP:Apply(player)
    if player == LocalPlayer then
        return
    end

    local character = player.Character
    if not character then
        return
    end

    local highlight = highlights[player]

    if not highlight or not highlight.Parent then
        highlight = Instance.new("Highlight")
        highlight.Name = "REDLINE_Highlight"
        highlight.Adornee = character
        highlight.FillColor = self.Settings.Color
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.75
        highlight.OutlineTransparency = 0
        highlight.Parent = character

        highlights[player] = highlight
    end

    highlight.Enabled = self.Settings.Enabled
end

function ESP:SetEnabled(enabled)
    self.Settings.Enabled = enabled

    for player, highlight in pairs(highlights) do
        if highlight then
            highlight.Enabled = enabled
        end
    end
end

function ESP:SetColor(color)
    self.Settings.Color = color

    for _, highlight in pairs(highlights) do
        if highlight then
            highlight.FillColor = color
        end
    end
end

function ESP:Clear()
    for player, highlight in pairs(highlights) do
        if highlight then
            highlight:Destroy()
        end

        highlights[player] = nil
    end
end

return ESP

local ESP = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local highlights = {}

ESP.Settings = {
    Enabled = true,
    ShowNames = true,
    ShowDistance = true,

    Color = Color3.fromRGB(220, 30, 40),

    FillTransparency = 1,
    OutlineTransparency = 0
}

function ESP:Apply(player)
    if player == LocalPlayer then
        return
    end

    local character = player.Character
    if not character then
        return
    end

    local highlight = highlights[player]

    if not highlight or not highlight.Parent then
        highlight = Instance.new("Highlight")

        highlight.Name = "REDLINE_Highlight"
        highlight.Adornee = character
        highlight.Parent = character

        highlights[player] = highlight
    end

    highlight.FillColor = self.Settings.Color
    highlight.OutlineColor = self.Settings.Color

    highlight.FillTransparency =
        self.Settings.FillTransparency

    highlight.OutlineTransparency =
        self.Settings.OutlineTransparency

    highlight.Enabled = self.Settings.Enabled
end

function ESP:SetEnabled(enabled)
    self.Settings.Enabled = enabled

    for _, highlight in pairs(highlights) do
        highlight.Enabled = enabled
    end
end

function ESP:SetColor(color)
    self.Settings.Color = color

    for _, highlight in pairs(highlights) do
        highlight.OutlineColor = color
            highlight.FillColor = color
    end
end

function ESP:SetStyle()
    self.Settings.FillTransparency = 1
    self.Settings.OutlineTransparency = 0

    for _, highlight in pairs(highlights) do
        highlight.FillTransparency = 1
        highlight.OutlineTransparency = 0
    end
end

function ESP:Clear()
    for player, highlight in pairs(highlights) do
        highlight:Destroy()
        highlights[player] = nil
    end
end

return ESP

local VisualTab = {}

function VisualTab.Create(parent, ESP, COLORS)

    local function create(class, properties, target)
        local object = Instance.new(class)

        for key, value in pairs(properties) do
            object[key] = value
        end

        object.Parent = target
        return object
    end

    local container = create("Frame", {
        Name = "VisualPage",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1
    }, parent)

    local layout = create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, container)

    create("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 14)
    }, container)

    local function createToggle(label, callback)
        local button = create("TextButton", {
            Size = UDim2.new(1, -28, 0, 40),
            BackgroundColor3 = COLORS.Button,
            Text = "",
            AutoButtonColor = false
        }, container)

        create("UICorner", {
            CornerRadius = UDim.new(0, 7)
        }, button)

        create("TextLabel", {
            Size = UDim2.new(0.7, 0, 1, 0),
            Position = UDim2.fromOffset(12, 0),
            BackgroundTransparency = 1,
            Text = label,
            TextColor3 = COLORS.White,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left
        }, button)

        local enabled = false

        local state = create("TextLabel", {
            Size = UDim2.fromOffset(55, 25),
            Position = UDim2.new(1, -65, 0.5, -12),
            BackgroundColor3 = COLORS.RedDark,
            Text = "OFF",
            TextColor3 = COLORS.White,
            TextSize = 11,
            Font = Enum.Font.GothamBold
        }, button)

        create("UICorner", {
            CornerRadius = UDim.new(0, 5)
        }, state)

        button.MouseButton1Click:Connect(function()
            enabled = not enabled

            state.Text = enabled and "ON" or "OFF"

            state.BackgroundColor3 = enabled
                and Color3.fromRGB(30, 145, 70)
                or COLORS.RedDark

            callback(enabled)
        end)

        return button
    end

    createToggle("ESP / Destaque", function(value)
        ESP:SetEnabled(value)
    end)

    createToggle("Nomes dos jogadores", function(value)
        ESP.Settings.ShowNames = value
    end)

    createToggle("Distância", function(value)
        ESP.Settings.ShowDistance = value
    end)

    local colorButton = create("TextButton", {
        Size = UDim2.new(1, -28, 0, 40),
        BackgroundColor3 = COLORS.RedDark,
        Text = "COR: VERMELHO",
        TextColor3 = COLORS.White,
        TextSize = 12,
        Font = Enum.Font.GothamBold
    }, container)

    create("UICorner", {
        CornerRadius = UDim.new(0, 7)
    }, colorButton)

    colorButton.MouseButton1Click:Connect(function()
        ESP:SetColor(Color3.fromRGB(220, 30, 40))
        ESP:SetStyle()
    end)

    return container
end

return VisualTab

local Pages = {}

local TabNames = {
    "Inicio",
    "Visual",
    "Jogador",
    "Config",
    "Security",
    "Sobre"
}

local function RegisterPage(name, frame)
    Pages[name] = frame
    frame.Visible = false
end

local function ShowPage(name)
    for pageName, frame in pairs(Pages) do
        frame.Visible = pageName == name
    end
end

-- Exemplo de navegação
-- RegisterPage("Visual", visualFrame)
-- ShowPage("Visual")

return {
    Pages = Pages,
    RegisterPage = RegisterPage,
    ShowPage = ShowPage,
    TabNames = TabNames
}

local PlayerTab = {}

function PlayerTab.Create(parent, COLORS)

    local function create(class, properties, target)
        local object = Instance.new(class)

        for key, value in pairs(properties) do
            object[key] = value
        end

        object.Parent = target
        return object
    end

    local container = create("Frame", {
        Name = "PlayerPage",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1
    }, parent)

    create("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14)
    }, container)

    create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, container)

    local function createButton(name, description)
        local frame = create("Frame", {
            Size = UDim2.new(1, 0, 0, 65),
            BackgroundColor3 = COLORS.Button
        }, container)

        create("UICorner", {
            CornerRadius = UDim.new(0, 7)
        }, frame)

        create("TextLabel", {
            Size = UDim2.new(1, -15, 0, 25),
            Position = UDim2.fromOffset(10, 7),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = COLORS.White,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left
        }, frame)

        create("TextLabel", {
            Size = UDim2.new(1, -15, 0, 22),
            Position = UDim2.fromOffset(10, 32),
            BackgroundTransparency = 1,
            Text = description,
            TextColor3 = COLORS.Gray,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left
        }, frame)

        return frame
    end

    createButton(
        "MOVIMENTO",
        "Preferências de movimento do personagem"
    )

    createButton(
        "CONTROLES",
        "Personalização dos controles de jogo"
    )

    createButton(
        "ACESSIBILIDADE",
        "Ajustes de conforto e acessibilidade"
    )

    createButton(
        "RESTAURAR",
        "Restaurar preferências padrão"
    )

    return container
end

return PlayerTab

local SettingsTab = {}

function SettingsTab.Create(parent, COLORS, main, scale)

    local function create(class, properties, target)
        local object = Instance.new(class)

        for key, value in pairs(properties) do
            object[key] = value
        end

        object.Parent = target
        return object
    end

    local container = create("ScrollingFrame", {
        Name = "SettingsPage",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = COLORS.Red,
        CanvasSize = UDim2.new(0, 0, 0, 400)
    }, parent)

    create("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14)
    }, container)

    create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, container)

    local function createLabel(text)
        return create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = COLORS.White,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left
        }, container)
    end

    local function createButton(text, callback)
        local button = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = COLORS.Button,
            Text = text,
            TextColor3 = COLORS.White,
            TextSize = 12,
            Font = Enum.Font.GothamBold
        }, container)

        create("UICorner", {
            CornerRadius = UDim.new(0, 6)
        }, button)

        button.MouseButton1Click:Connect(callback)

        return button
    end

    createLabel("APARÊNCIA")

    createButton("TEMA PRETO E VERMELHO", function()
        main.BackgroundColor3 = COLORS.Background
    end)

    createLabel("ESCALA DA INTERFACE")

    local scaleButton = createButton("ESCALA: NORMAL", function()
        if scale.Scale >= 1 then
            scale.Scale = 0.85
            scaleButton.Text = "ESCALA: PEQUENA"
        else
            scale.Scale = 1
            scaleButton.Text = "ESCALA: NORMAL"
        end
    end)

    createLabel("TRANSPARÊNCIA")

    local transparency = 0

    local transparencyButton = createButton(
        "TRANSPARÊNCIA: 0%",
        function()
            transparency = transparency == 0 and 0.15 or 0

            main.BackgroundTransparency = transparency

            transparencyButton.Text =
                "TRANSPARÊNCIA: " ..
                tostring(math.floor(transparency * 100)) .. "%"
        end
    )

    createLabel("RESTAURAR")

    createButton("RESTAURAR CONFIGURAÇÕES", function()
        scale.Scale = 1
        transparency = 0
        main.BackgroundTransparency = 0
        main.BackgroundColor3 = COLORS.Background

        scaleButton.Text = "ESCALA: NORMAL"
        transparencyButton.Text = "TRANSPARÊNCIA: 0%"
    end)

    return container
end

return SettingsTab
