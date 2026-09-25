-- Delta Android: Atrator de Desastres TOTAL + Arremesso
-- Server-side via NetworkOwnership (todos veem e sentem)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- ==================== CONFIGURAÇÕES ====================
local CONFIG = {
    Ativado = false,
    Distancia = 100,
    Velocidade = 50,
    MinValor = 10,
    MaxValor = 200,
    Passo = 10,
    ForcaArremesso = 200,
    DanoArremesso = 25,
    TamanhoMaximoBloco = 500 -- Agora aceita blocos grandes (construções)
}

local partesControladas = {}
local conexoes = {}

-- ==================== TENTAR PEGAR NETWORK OWNERSHIP ====================
-- Isso faz o Roblox sincronizar o movimento das partes com TODOS os jogadores
local function pegarOwnership(parte)
    pcall(function()
        local networkOwner = parte:GetNetworkOwner()
        if networkOwner ~= player then
            parte:SetNetworkOwner(player)
        end
    end)
end

-- ==================== GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AtratorTotal"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local Janela = Instance.new("Frame")
Janela.Name = "Janela"
Janela.Parent = ScreenGui
Janela.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Janela.BorderSizePixel = 0
Janela.Position = UDim2.new(0.1, 0, 0.2, 0)
Janela.Size = UDim2.new(0, 280, 0, 380)
Janela.Active = true
Janela.Draggable = true
Janela.ClipsDescendants = true

local Canto = Instance.new("UICorner")
Canto.CornerRadius = UDim.new(0, 8)
Canto.Parent = Janela

-- Barra de título
local BarraTitulo = Instance.new("Frame")
BarraTitulo.Name = "BarraTitulo"
BarraTitulo.Parent = Janela
BarraTitulo.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
BarraTitulo.BorderSizePixel = 0
BarraTitulo.Size = UDim2.new(1, 0, 0, 35)

local Titulo = Instance.new("TextLabel")
Titulo.Parent = BarraTitulo
Titulo.BackgroundTransparency = 1
Titulo.Position = UDim2.new(0, 10, 0, 0)
Titulo.Size = UDim2.new(1, -80, 1, 0)
Titulo.Font = Enum.Font.GothamBold
Titulo.Text = "Ímã Total [DESLIGADO]"
Titulo.TextColor3 = Color3.fromRGB(255, 100, 100)
Titulo.TextSize = 14
Titulo.TextXAlignment = Enum.TextXAlignment.Left

local BotaoMin = Instance.new("TextButton")
BotaoMin.Parent = BarraTitulo
BotaoMin.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
BotaoMin.BorderSizePixel = 0
BotaoMin.Position = UDim2.new(1, -70, 0, 5)
BotaoMin.Size = UDim2.new(0, 28, 0, 25)
BotaoMin.Font = Enum.Font.GothamBold
BotaoMin.Text = "—"
BotaoMin.TextColor3 = Color3.fromRGB(255, 255, 255)
BotaoMin.TextSize = 16

local CantoMin = Instance.new("UICorner")
CantoMin.CornerRadius = UDim.new(0, 4)
CantoMin.Parent = BotaoMin

local BotaoFechar = Instance.new("TextButton")
BotaoFechar.Parent = BarraTitulo
BotaoFechar.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
BotaoFechar.BorderSizePixel = 0
BotaoFechar.Position = UDim2.new(1, -35, 0, 5)
BotaoFechar.Size = UDim2.new(0, 28, 0, 25)
BotaoFechar.Font = Enum.Font.GothamBold
BotaoFechar.Text = "×"
BotaoFechar.TextColor3 = Color3.fromRGB(255, 255, 255)
BotaoFechar.TextSize = 18

local CantoFechar = Instance.new("UICorner")
CantoFechar.CornerRadius = UDim.new(0, 4)
CantoFechar.Parent = BotaoFechar

-- Área de conteúdo (rolagem)
local Area = Instance.new("ScrollingFrame")
Area.Parent = Janela
Area.BackgroundTransparency = 1
Area.Position = UDim2.new(0, 8, 0, 42)
Area.Size = UDim2.new(1, -16, 1, -50)
Area.CanvasSize = UDim2.new(0, 0, 0, 400)
Area.ScrollBarThickness = 6
Area.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 120)
Area.BorderSizePixel = 0

-- Botão principal
local BotaoPrincipal = Instance.new("TextButton")
BotaoPrincipal.Parent = Area
BotaoPrincipal.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
BotaoPrincipal.BorderSizePixel = 0
BotaoPrincipal.Position = UDim2.new(0, 0, 0, 0)
BotaoPrincipal.Size = UDim2.new(1, 0, 0, 40)
BotaoPrincipal.Font = Enum.Font.GothamBold
BotaoPrincipal.Text = "Ímã Total: DESLIGADO"
BotaoPrincipal.TextColor3 = Color3.fromRGB(255, 255, 255)
BotaoPrincipal.TextSize = 14

local CantoP = Instance.new("UICorner")
CantoP.CornerRadius = UDim.new(0, 6)
CantoP.Parent = BotaoPrincipal

-- Slider distância
local LabelDist = Instance.new("TextLabel")
LabelDist.Parent = Area
LabelDist.BackgroundTransparency = 1
LabelDist.Position = UDim2.new(0, 0, 0, 55)
LabelDist.Size = UDim2.new(1, 0, 0, 20)
LabelDist.Font = Enum.Font.Gotham
LabelDist.Text = "Distância: 100"
LabelDist.TextColor3 = Color3.fromRGB(200, 200, 255)
LabelDist.TextSize = 13
LabelDist.TextXAlignment = Enum.TextXAlignment.Left

local SliderDist = Instance.new("Frame")
SliderDist.Parent = Area
SliderDist.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
SliderDist.BorderSizePixel = 0
SliderDist.Position = UDim2.new(0, 0, 0, 78)
SliderDist.Size = UDim2.new(1, 0, 0, 8)

local FillDist = Instance.new("Frame")
FillDist.Parent = SliderDist
FillDist.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
FillDist.BorderSizePixel = 0
FillDist.Size = UDim2.new(0.5, 0, 1, 0)

local KnobDist = Instance.new("Frame")
KnobDist.Parent = SliderDist
KnobDist.BackgroundColor3 = Color3.fromRGB(180, 180, 255)
KnobDist.BorderSizePixel = 0
KnobDist.Size = UDim2.new(0, 16, 0, 16)
KnobDist.Position = UDim2.new(0.5, -8, 0, -4)

local CantoKnob1 = Instance.new("UICorner")
CantoKnob1.CornerRadius = UDim.new(1, 0)
CantoKnob1.Parent = KnobDist

-- Slider velocidade
local LabelVel = Instance.new("TextLabel")
LabelVel.Parent = Area
LabelVel.BackgroundTransparency = 1
LabelVel.Position = UDim2.new(0, 0, 0, 105)
LabelVel.Size = UDim2.new(1, 0, 0, 20)
LabelVel.Font = Enum.Font.Gotham
LabelVel.Text = "Velocidade: 50"
LabelVel.TextColor3 = Color3.fromRGB(200, 255, 200)
LabelVel.TextSize = 13
LabelVel.TextXAlignment = Enum.TextXAlignment.Left

local SliderVel = Instance.new("Frame")
SliderVel.Parent = Area
SliderVel.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
SliderVel.BorderSizePixel = 0
SliderVel.Position = UDim2.new(0, 0, 0, 128)
SliderVel.Size = UDim2.new(1, 0, 0, 8)

local FillVel = Instance.new("Frame")
FillVel.Parent = SliderVel
FillVel.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
FillVel.BorderSizePixel = 0
FillVel.Size = UDim2.new(0.25, 0, 1, 0)

local KnobVel = Instance.new("Frame")
KnobVel.Parent = SliderVel
KnobVel.BackgroundColor3 = Color3.fromRGB(180, 255, 180)
KnobVel.BorderSizePixel = 0
KnobVel.Size = UDim2.new(0, 16, 0, 16)
KnobVel.Position = UDim2.new(0.25, -8, 0, -4)

local CantoKnob2 = Instance.new("UICorner")
CantoKnob2.CornerRadius = UDim.new(1, 0)
CantoKnob2.Parent = KnobVel

-- Botão arremessar
local BotaoArremessar = Instance.new("TextButton")
BotaoArremessar.Parent = Area
BotaoArremessar.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
BotaoArremessar.BorderSizePixel = 0
BotaoArremessar.Position = UDim2.new(0, 0, 0, 155)
BotaoArremessar.Size = UDim2.new(1, 0, 0, 40)
BotaoArremessar.Font = Enum.Font.GothamBold
BotaoArremessar.Text = "💥 ARREMESSAR NAS PESSOAS"
BotaoArremessar.TextColor3 = Color3.fromRGB(255, 255, 255)
BotaoArremessar.TextSize = 14

local CantoArrem = Instance.new("UICorner")
CantoArrem.CornerRadius = UDim.new(0, 6)
CantoArrem.Parent = BotaoArremessar

-- Força do arremesso
local LabelForca = Instance.new("TextLabel")
LabelForca.Parent = Area
LabelForca.BackgroundTransparency = 1
LabelForca.Position = UDim2.new(0, 0, 0, 205)
LabelForca.Size = UDim2.new(1, 0, 0, 20)
LabelForca.Font = Enum.Font.Gotham
LabelForca.Text = "Força do Arremesso: 200"
LabelForca.TextColor3 = Color3.fromRGB(255, 200, 200)
LabelForca.TextSize = 13
LabelForca.TextXAlignment = Enum.TextXAlignment.Left

local SliderForca = Instance.new("Frame")
SliderForca.Parent = Area
SliderForca.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
SliderForca.BorderSizePixel = 0
SliderForca.Position = UDim2.new(0, 0, 0, 228)
SliderForca.Size = UDim2.new(1, 0, 0, 8)

local FillForca = Instance.new("Frame")
FillForca.Parent = SliderForca
FillForca.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
FillForca.BorderSizePixel = 0
FillForca.Size = UDim2.new(0.5, 0, 1, 0)

local KnobForca = Instance.new("Frame")
KnobForca.Parent = SliderForca
KnobForca.BackgroundColor3 = Color3.fromRGB(255, 180, 180)
KnobForca.BorderSizePixel = 0
KnobForca.Size = UDim2.new(0, 16, 0, 16)
KnobForca.Position = UDim2.new(0.5, -8, 0, -4)

local CantoKnob3 = Instance.new("UICorner")
CantoKnob3.CornerRadius = UDim.new(1, 0)
CantoKnob3.Parent = KnobForca

-- Status
local LabelStatus = Instance.new("TextLabel")
LabelStatus.Parent = Area
LabelStatus.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
LabelStatus.BorderSizePixel = 0
LabelStatus.Position = UDim2.new(0, 0, 0, 255)
LabelStatus.Size = UDim2.new(1, 0, 0, 40)
LabelStatus.Font = Enum.Font.Gotham
LabelStatus.Text = "Status: Parado | Blocos: 0"
LabelStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
LabelStatus.TextSize = 12

local CantoStatus = Instance.new("UICorner")
CantoStatus.CornerRadius = UDim.new(0, 4)
CantoStatus.Parent = LabelStatus

-- ==================== ARRASTAR ====================
local arrastando = false
local inicioArraste, posInicial

BarraTitulo.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        arrastando = true
        inicioArraste = input.Position
        posInicial = Janela.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if arrastando and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - inicioArraste
        Janela.Position = UDim2.new(posInicial.X.Scale, posInicial.X.Offset + delta.X, posInicial.Y.Scale, posInicial.Y.Offset + delta.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        arrastando = false
    end
end)

-- ==================== MINIMIZAR ====================
local minimizado = false
local tamOriginal = UDim2.new(0, 280, 0, 380)
local tamMin = UDim2.new(0, 280, 0, 40)

BotaoMin.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    local alvo = minimizado and tamMin or tamOriginal
    TweenService:Create(Janela, TweenInfo.new(0.25), {Size = alvo}):Play()
    Area.Visible = not minimizado
    BotaoMin.Text = minimizado and "+" or "—"
end)

BotaoFechar.MouseButton1Click:Connect(function()
    CONFIG.Ativado = false
    limparTudo()
    ScreenGui:Destroy()
end)

-- ==================== SLIDERS ====================
local function configurarSlider(slider, fill, knob, minV, maxV, passo, callback)
    local arrastandoS = false
    local function atualizar(inputX)
        local relX = inputX - slider.AbsolutePosition.X
        local pct = math.clamp(relX / slider.AbsoluteSize.X, 0, 1)
        local valor = minV + (maxV - minV) * pct
        valor = math.floor(valor / passo) * passo
        valor = math.clamp(valor, minV, maxV)
        local novoPct = (valor - minV) / (maxV - minV)
        fill.Size = UDim2.new(novoPct, 0, 1, 0)
        knob.Position = UDim2.new(novoPct, -8, 0, -4)
        callback(valor)
    end
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            arrastandoS = true
            atualizar(input.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if arrastandoS and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            atualizar(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            arrastandoS = false
        end
    end)
end

configurarSlider(SliderDist, FillDist, KnobDist, CONFIG.MinValor, CONFIG.MaxValor, CONFIG.Passo, function(v)
    CONFIG.Distancia = v
    LabelDist.Text = "Distância: " .. v
end)

configurarSlider(SliderVel, FillVel, KnobVel, CONFIG.MinValor, CONFIG.MaxValor, CONFIG.Passo, function(v)
    CONFIG.Velocidade = v
    LabelVel.Text = "Velocidade: " .. v
end)

configurarSlider(SliderForca, FillForca, KnobForca, 50, 500, 10, function(v)
    CONFIG.ForcaArremesso = v
    LabelForca.Text = "Força do Arremesso: " .. v
end)

-- ==================== LÓGICA ====================
local function obterPersonagem()
    local c = player.Character
    if c then return c:FindFirstChild("HumanoidRootPart") end
    return nil
end

local function ehPersonagem(obj)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and obj:IsDescendantOf(p.Character) then
            return true
        end
    end
    return false
end

-- Verifica se é bloco válido (AGORA aceita blocos grandes, mas ignora chão base)
local function ehBlocoValido(obj)
    if not obj or not obj.Parent then return false end
    if not obj:IsA("BasePart") then return false end
    if obj:IsA("Terrain") then return false end
    if ehPersonagem(obj) then return false end
    if obj:FindFirstAncestorOfClass("Tool") then return false end
    if obj:FindFirstAncestorOfClass("Accessory") then return false end
    
    -- ⚠️ Só ignora partes MUITO ancoradas (chão base do jogo)
    -- Mas aceita construções ancoradas (paredes de casa, torres)
    -- Isso é detectado pelo tamanho: chão base é geralmente gigante
    local tam = obj.Size
    local maior = math.max(tam.X, tam.Y, tam.Z)
    
    if maior > CONFIG.TamanhoMaximoBloco then
        return false -- Ignora chão gigante
    end
    
    return true
end

function limparTudo()
    for parte, dados in pairs(partesControladas) do
        if parte and parte.Parent then
            if dados.giro then pcall(function() dados.giro:Destroy() end) end
            if dados.velocidade then pcall(function() dados.velocidade:Destroy() end) end
            -- Devolve o ownership para o servidor
            pcall(function() parte:SetNetworkOwner(nil) end)
        end
    end
    partesControladas = {}
    for _, c in pairs(conexoes) do
        pcall(function() c:Disconnect() end)
    end
    conexoes = {}
end

local function controlarParte(parte)
    if not parte or not parte.Parent or partesControladas[parte] then return end
    if not parte:IsA("BasePart") then return end
    
    local raiz = obterPersonagem()
    if not raiz then return end
    
    -- ⚠️ PEGA OWNERSHIP (isso faz TODOS verem o movimento)
    pegarOwnership(parte)
    
    local ancoradoOrig = parte.Anchored
    local cframeOrig = parte.CFrame
    
    parte.Anchored = false
    parte.CanCollide = false
    
    local giro = Instance.new("BodyGyro")
    giro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    giro.P = 50000
    giro.D = 500
    giro.CFrame = parte.CFrame
    giro.Parent = parte
    
    local velocidade = Instance.new("BodyVelocity")
    velocidade.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    velocidade.Velocity = Vector3.new(0, 0, 0)
    velocidade.Parent = parte
    
    partesControladas[parte] = {
        ancoradoOriginal = ancoradoOrig,
        cframeOriginal = cframeOrig,
        giro = giro,
        velocidade = velocidade
    }
    
    local conn = RunService.Heartbeat:Connect(function()
        if not CONFIG.Ativado then return end
        if not parte or not parte.Parent then return end
        
        local raizAtual = obterPersonagem()
        if not raizAtual then return end
        
        local minhaPos = raizAtual.Position
        local posParte = parte.Position
        local distancia = (minhaPos - posParte).Magnitude
        
        if distancia <= CONFIG.Distancia and distancia > 5 then
            local direcao = (minhaPos - posParte).Unit
            velocidade.Velocity = direcao * CONFIG.Velocidade
        elseif distancia <= 5 then
            velocidade.Velocity = Vector3.new(0, 0, 0)
        else
            velocidade.Velocity = Vector3.new(0, 0, 0)
        end
        
        giro.CFrame = giro.CFrame * CFrame.Angles(0, math.rad(CONFIG.Velocidade), 0)
    end)
    
    conexoes[parte] = conn
end

local function escanear()
    local raiz = obterPersonagem()
    if not raiz then return end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if ehBlocoValido(obj) and not partesControladas[obj] then
            local distancia = (obj.Position - raiz.Position).Magnitude
            if distancia <= CONFIG.Distancia then
                controlarParte(obj)
            end
        end
    end
end

-- ==================== ARREMESSAR NAS PESSOAS ====================
local function arremessarNasPessoas()
    local raiz = obterPersonagem()
    if not raiz then return end
    
    local alvos = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 then
                table.insert(alvos, {hrp = hrp, hum = hum, pos = hrp.Position})
            end
        end
    end
    
    if #alvos == 0 then
        LabelStatus.Text = "⚠️ Nenhum jogador no servidor!"
        LabelStatus.TextColor3 = Color3.fromRGB(255, 180, 100)
        return
    end
    
    local contador = 0
    for parte, dados in pairs(partesControladas) do
        if parte and parte.Parent then
            -- Escolhe o alvo mais próximo dessa parte
            local alvoMaisProximo = nil
            local menorDist = math.huge
            for _, a in ipairs(alvos) do
                local d = (parte.Position - a.pos).Magnitude
                if d < menorDist then
                    menorDist = d
                    alvoMaisProximo = a
                end
            end
            
            if alvoMaisProximo then
                -- ⚠️ Reforça o ownership
                pegarOwnership(parte)
                
                local direcao = (alvoMaisProximo.pos - parte.Position).Unit
                
                -- Cria uma velocidade de arremesso temporária (substitui a de atração)
                if dados.velocidade then
                    dados.velocidade:Destroy()
                end
                
                local velArremesso = Instance.new("BodyVelocity")
                velArremesso.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                velArremesso.Velocity = direcao * CONFIG.ForcaArremesso
                velArremesso.Parent = parte
                dados.velocidade = velArremesso
                
                -- ⚠️ Adiciona dano por contato com o alvo
                local toqueConn
                toqueConn = parte.Touched:Connect(function(hit)
                    local hum = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Parent ~= player.Character then
                        hum:TakeDamage(CONFIG.DanoArremesso)
                    end
                end)
                
                -- Remove a conexão depois de 3 segundos
                task.delay(3, function()
                    if toqueConn then toqueConn:Disconnect() end
                end)
                
                contador = contador + 1
            end
        end
    end
    
    LabelStatus.Text = string.format("💥 Arremessados: %d blocos!", contador)
    LabelStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
    
    task.delay(3, function()
        if not CONFIG.Ativado then
            LabelStatus.Text = "Status: Parado | Blocos: 0"
            LabelStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end)
end

BotaoArremessar.MouseButton1Click:Connect(arremessarNasPessoas)

-- ==================== ATUALIZAR STATUS ====================
local function atualizarStatus()
    local c = 0
    for p in pairs(partesControladas) do
        if p and p.Parent then c = c + 1 end
    end
    if CONFIG.Ativado then
        LabelStatus.Text = string.format("Status: ATIVO | Blocos: %d | Alcance: %d", c, CONFIG.Distancia)
        LabelStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        LabelStatus.Text = "Status: Parado | Blocos: 0"
        LabelStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
end

-- Botão principal
BotaoPrincipal.MouseButton1Click:Connect(function()
    CONFIG.Ativado = not CONFIG.Ativado
    if CONFIG.Ativado then
        BotaoPrincipal.Text = "Ímã Total: LIGADO"
        BotaoPrincipal.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
        Titulo.Text = "Ímã Total [LIGADO]"
        Titulo.TextColor3 = Color3.fromRGB(100, 255, 100)
        escanear()
    else
        BotaoPrincipal.Text = "Ímã Total: DESLIGADO"
        BotaoPrincipal.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        Titulo.Text = "Ímã Total [DESLIGADO]"
        Titulo.TextColor3 = Color3.fromRGB(255, 100, 100)
        limparTudo()
    end
    atualizarStatus()
end)

task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        task.wait(1)
        if CONFIG.Ativado then escanear() end
        atualizarStatus()
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(1)
    if CONFIG.Ativado then
        limparTudo()
        escanear()
    end
end)

print("[Ímã Total] GUI carregada!")
