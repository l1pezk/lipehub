local Library = {}

-- [[ SERVIÇOS ]] --
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- [[ CONFIGURAÇÃO DE DESIGN ]] --
local Theme = {
    Background = Color3.fromHex("0F0F0F"),
    Container  = Color3.fromHex("161616"),
    Stroke     = Color3.fromHex("282828"),
    Text       = Color3.fromRGB(240, 240, 240),
    TextDark   = Color3.fromRGB(120, 120, 120),
    Accent     = Color3.fromHex("EBF3E7"), -- Creme/Verde Água
}

local Settings = {
    Font = Enum.Font.Quicksand,
    CornerRadius = 14,
    WidgetRadius = 8,
    StrokeThickness = 1.2,
    MobileHeight = 44 -- Padrão de acessibilidade
}

-- [[ UTILITÁRIOS ]] --
local function GetFont()
    -- Fallback caso Quicksand não carregue em alguns exploits
    return Settings.Font or Enum.Font.BuilderSans
end

local function Create(class, props)
    local instance = Instance.new(class)
    for i, v in pairs(props) do instance[i] = v end
    return instance
end

local function AddCorner(parent, radius)
    return Create("UICorner", {CornerRadius = UDim.new(0, radius), Parent = parent})
end

local function AddStroke(parent, color, thickness)
    return Create("UIStroke", {
        Color = color, 
        Thickness = thickness, 
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
        Parent = parent
    })
end

local function Ripple(button)
    spawn(function()
        local ripple = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.85,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 0, 0, 0),
            ZIndex = 5,
            Parent = button
        })
        AddCorner(ripple, 100)
        
        TweenService:Create(ripple, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(2, 0, 2, 0),
            BackgroundTransparency = 1
        }):Play()
        
        task.wait(0.6)
        ripple:Destroy()
    end)
end

-- [[ MAGNET DRAG SYSTEM ]] --
local function MakeDraggable(trigger, object)
    local Dragging, DragInput, DragStart, StartPos
    
    trigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPos = object.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then Dragging = false end
            end)
        end
    end)

    trigger.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    -- Loop Heartbeat para interpolação suave (Magnet Feel)
    RunService.Heartbeat:Connect(function()
        if Dragging and DragInput then
            local Delta = DragInput.Position - DragStart
            local TargetPos = UDim2.new(
                StartPos.X.Scale, StartPos.X.Offset + Delta.X, 
                StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y
            )
            -- Interpolação super suave para seguir o dedo sem travar
            TweenService:Create(object, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = TargetPos}):Play()
        end
    end)
end

-- [[ INÍCIO DA LIBRARY ]] --
function Library:CreateWindow(TitleText)
    local Window = {}
    
    -- Injeção Anti-Patch no PlayerGui
    local TargetGui = LocalPlayer:WaitForChild("PlayerGui")
    for _, v in pairs(TargetGui:GetChildren()) do if v.Name == "LipeUI_V2" then v:Destroy() end end

    local ScreenGui = Create("ScreenGui", {
        Name = "LipeUI_V2",
        Parent = TargetGui,
        DisplayOrder = 9999,
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })

    -- [[ ÍCONE MINIMIZADO (Estado Inicial) ]] --
    local OpenBtn = Create("ImageButton", {
        Name = "OpenIcon",
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0.1, 0, 0.2, 0),
        BackgroundColor3 = Theme.Background,
        Image = "rbxassetid://84949358140737",
        Visible = true, -- Inicia visível
        Parent = ScreenGui,
        Active = true
    })
    
    AddCorner(OpenBtn, 25) -- Circular
    local OpenStroke = AddStroke(OpenBtn, Theme.Accent, 1.5)
    MakeDraggable(OpenBtn, OpenBtn)

    -- Efeito de Pulso no Ícone
    local PulseTween = TweenService:Create(OpenStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.5})
    PulseTween:Play()

    -- [[ JANELA PRINCIPAL ]] --
    local Main = Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 0, 0, 0), -- Inicia fechado (0 tamanho)
        Position = UDim2.new(0.5, -240, 0.5, -180),
        BackgroundColor3 = Theme.Background,
        ClipsDescendants = true,
        Visible = false, -- Inicia invisível
        Parent = ScreenGui
    })
    AddCorner(Main, Settings.CornerRadius)
    AddStroke(Main, Theme.Stroke, 1.5)

    local Topbar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.Container,
        BorderSizePixel = 0,
        Parent = Main
    })
    AddCorner(Topbar, Settings.CornerRadius)
    
    -- Correção visual do canto inferior da topbar
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Theme.Container,
        BorderSizePixel = 0,
        Parent = Topbar
    })

    local Title = Create("TextLabel", {
        Text = TitleText,
        Font = GetFont(),
        TextSize = 18,
        TextColor3 = Theme.Accent,
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Topbar
    })

    MakeDraggable(Topbar, Main)

    -- Lógica de Abrir/Fechar com Bounce
    local IsOpen = false
    
    local function ToggleWindow(state)
        IsOpen = state
        if IsOpen then
            OpenBtn.Visible = false
            Main.Visible = true
            -- Animação de Abertura (Bouncy)
            TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 480, 0, 360),
                Position = UDim2.new(0.5, -240, 0.5, -180) -- Centraliza
            }):Play()
        else
            -- Animação de Fechamento (Smooth)
            local closeAnim = TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            })
            closeAnim:Play()
            closeAnim.Completed:Connect(function()
                Main.Visible = false
                OpenBtn.Visible = true
            end)
        end
    end

    OpenBtn.MouseButton1Click:Connect(function() ToggleWindow(true) end)

    local CloseBtn = Create("TextButton", {
        Size = UDim2.new(0, 40, 1, 0),
        Position = UDim2.new(1, -40, 0, 0),
        BackgroundTransparency = 1,
        Text = "-", -- Ícone de minimizar
        TextColor3 = Theme.Text,
        Font = GetFont(),
        TextSize = 28,
        Parent = Topbar
    })
    CloseBtn.MouseButton1Click:Connect(function() ToggleWindow(false) end)

    -- Container de Abas e Páginas
    local TabContainer = Create("ScrollingFrame", {
        Size = UDim2.new(0, 140, 1, -45),
        Position = UDim2.new(0, 0, 0, 45),
        BackgroundColor3 = Theme.Container,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        Parent = Main
    })
    Create("UIListLayout", {Parent = TabContainer, SortOrder = "LayoutOrder", Padding = UDim.new(0, 6)})
    Create("UIPadding", {Parent = TabContainer, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10)})

    local Pages = Create("Frame", {
        Size = UDim2.new(1, -150, 1, -55),
        Position = UDim2.new(0, 145, 0, 50),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = Main
    })

    local FirstTab = true

    function Window:Tab(Name)
        local Tab = {}
        
        -- Botão da Aba
        local TabBtn = Create("TextButton", {
            Size = UDim2.new(1, -10, 0, 36),
            BackgroundColor3 = Theme.Background,
            Text = Name,
            TextColor3 = Theme.TextDark,
            Font = GetFont(),
            TextSize = 14,
            Parent = TabContainer,
            AutoButtonColor = false
        })
        AddCorner(TabBtn, 8)
        local TabStroke = AddStroke(TabBtn, Theme.Stroke, 1)

        -- Página de Itens
        local Page = Create("ScrollingFrame", {
            Name = Name.."Page",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.Accent,
            Parent = Pages,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(0,0,0,0)
        })
        Create("UIListLayout", {Parent = Page, SortOrder = "LayoutOrder", Padding = UDim.new(0, 8)})
        Create("UIPadding", {Parent = Page, PaddingRight = UDim.new(0, 5), PaddingBottom = UDim.new(0, 10)})

        -- Seleção Automática da 1ª Aba
        if FirstTab then
            FirstTab = false
            TabBtn.TextColor3 = Theme.Accent
            TabBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            TabStroke.Color = Theme.Accent
            Page.Visible = true
        end

        TabBtn.MouseButton1Click:Connect(function()
            -- Resetar outras abas
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    TweenService:Create(v, TweenInfo.new(0.3), {TextColor3 = Theme.TextDark, BackgroundColor3 = Theme.Background}):Play()
                    TweenService:Create(v:FindFirstChild("UIStroke"), TweenInfo.new(0.3), {Color = Theme.Stroke}):Play()
                end
            end
            for _, v in pairs(Pages:GetChildren()) do v.Visible = false end
            
            -- Ativar aba atual
            TweenService:Create(TabBtn, TweenInfo.new(0.3), {TextColor3 = Theme.Accent, BackgroundColor3 = Color3.fromRGB(22, 22, 22)}):Play()
            TweenService:Create(TabStroke, TweenInfo.new(0.3), {Color = Theme.Accent}):Play()
            Page.Visible = true
        end)

        -- [[ COMPONENTES ]] --
        
        function Tab:Label(Text)
            local L = Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 25),
                BackgroundTransparency = 1,
                Text = Text,
                TextColor3 = Theme.TextDark,
                Font = GetFont(),
                TextSize = 14,
                Parent = Page
            })
        end

        function Tab:Button(Text, Callback)
            local B = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, Settings.MobileHeight),
                BackgroundColor3 = Theme.Container,
                Text = Text,
                TextColor3 = Theme.Text,
                Font = GetFont(),
                TextSize = 14,
                Parent = Page,
                AutoButtonColor = false
            })
            AddCorner(B, Settings.WidgetRadius)
            local BS = AddStroke(B, Theme.Stroke, 1.2)

            B.MouseButton1Click:Connect(function()
                Ripple(B)
                Callback()
            end)
        end

        function Tab:Toggle(Text, Default, Callback)
            local Toggled = Default or false
            
            local Container = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, Settings.MobileHeight),
                BackgroundColor3 = Theme.Container,
                Text = "",
                AutoButtonColor = false,
                Parent = Page
            })
            AddCorner(Container, Settings.WidgetRadius)
            local CStroke = AddStroke(Container, Theme.Stroke, 1.2)

            local Label = Create("TextLabel", {
                Size = UDim2.new(1, -50, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = Text,
                TextColor3 = Theme.Text,
                Font = GetFont(),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Container
            })

            local CheckFrame = Create("Frame", {
                Size = UDim2.new(0, 22, 0, 22),
                Position = UDim2.new(1, -12, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Theme.Background,
                Parent = Container
            })
            AddCorner(CheckFrame, 6)
            local CheckStroke = AddStroke(CheckFrame, Theme.Stroke, 1.2)
            
            local Fill = Create("Frame", {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Theme.Accent,
                Parent = CheckFrame
            })
            AddCorner(Fill, 4)

            local function Update()
                if Toggled then
                    TweenService:Create(Fill, TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Size = UDim2.new(1, -6, 1, -6)}):Play()
                    TweenService:Create(CheckStroke, TweenInfo.new(0.3), {Color = Theme.Accent}):Play()
                    TweenService:Create(CStroke, TweenInfo.new(0.3), {Color = Theme.Accent}):Play()
                    TweenService:Create(Label, TweenInfo.new(0.3), {TextColor3 = Theme.Accent}):Play()
                else
                    TweenService:Create(Fill, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 0, 0)}):Play()
                    TweenService:Create(CheckStroke, TweenInfo.new(0.3), {Color = Theme.Stroke}):Play()
                    TweenService:Create(CStroke, TweenInfo.new(0.3), {Color = Theme.Stroke}):Play()
                    TweenService:Create(Label, TweenInfo.new(0.3), {TextColor3 = Theme.Text}):Play()
                end
                if Callback then Callback(Toggled) end
            end

            Container.MouseButton1Click:Connect(function()
                Toggled = not Toggled
                Update()
            end)
            
            if Default then 
                -- Força visual inicial sem callback se necessário, ou com
                Toggled = true
                -- Pequeno hack para setar visualmente instantâneo ou com tween rápido
                Fill.Size = UDim2.new(1, -6, 1, -6)
                CheckStroke.Color = Theme.Accent
                CStroke.Color = Theme.Accent
                Label.TextColor3 = Theme.Accent
            end
        end

        function Tab:Slider(Text, Min, Max, Default, Callback)
            local Value = Default or Min
            local Dragging = false

            local Container = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 60),
                BackgroundColor3 = Theme.Container,
                Parent = Page
            })
            AddCorner(Container, Settings.WidgetRadius)
            AddStroke(Container, Theme.Stroke, 1.2)

            local Label = Create("TextLabel", {
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 10, 0, 5),
                BackgroundTransparency = 1,
                Text = Text,
                TextColor3 = Theme.Text,
                Font = GetFont(),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Container
            })

            local ValueLabel = Create("TextLabel", {
                Size = UDim2.new(0, 50, 0, 20),
                Position = UDim2.new(1, -10, 0, 5),
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Text = tostring(Value),
                TextColor3 = Theme.Accent,
                Font = GetFont(),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = Container
            })

            local SliderBar = Create("TextButton", {
                Size = UDim2.new(1, -20, 0, 6),
                Position = UDim2.new(0, 10, 0, 40),
                BackgroundColor3 = Theme.Background,
                Text = "",
                AutoButtonColor = false,
                Parent = Container
            })
            AddCorner(SliderBar, 100)

            local Fill = Create("Frame", {
                Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                Parent = SliderBar
            })
            AddCorner(Fill, 100)

            -- Knob (Bolinha)
            local Knob = Create("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(1, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Theme.Accent,
                Parent = Fill
            })
            AddCorner(Knob, 100)
            -- Efeito glow no knob
            local KnobStroke = AddStroke(Knob, Theme.Background, 2) 

            local function Update(Input)
                local SizeX = SliderBar.AbsoluteSize.X
                local PosX = SliderBar.AbsolutePosition.X
                local Percent = math.clamp((Input.Position.X - PosX) / SizeX, 0, 1)
                local NewValue = math.floor(Min + ((Max - Min) * Percent))
                
                TweenService:Create(Fill, TweenInfo.new(0.05, Enum.EasingStyle.Sine), {Size = UDim2.new(Percent, 0, 1, 0)}):Play()
                ValueLabel.Text = tostring(NewValue)
                Callback(NewValue)
            end

            SliderBar.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    Update(Input)
                    TweenService:Create(Knob, TweenInfo.new(0.2), {Size = UDim2.new(0, 18, 0, 18)}):Play() -- Aumenta knob
                end
            end)

            UserInputService.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = false
                    TweenService:Create(Knob, TweenInfo.new(0.2), {Size = UDim2.new(0, 14, 0, 14)}):Play() -- Restaura knob
                end
            end)

            UserInputService.InputChanged:Connect(function(Input)
                if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                    Update(Input)
                end
            end)
        end

        function Tab:Dropdown(Text, Options, Default, Callback, Multi)
            local Dropdown = {}
            local IsOpen = false
            local Selected = {} 
            local SingleSelect = Default or "None"

            if Multi and type(Default) == "table" then
                for _, v in pairs(Default) do table.insert(Selected, v) end
            end

            local Container = Create("Frame", {
                Size = UDim2.new(1, 0, 0, Settings.MobileHeight),
                BackgroundColor3 = Theme.Container,
                ClipsDescendants = true,
                Parent = Page
            })
            AddCorner(Container, Settings.WidgetRadius)
            local CStroke = AddStroke(Container, Theme.Stroke, 1.2)

            local MainBtn = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, Settings.MobileHeight),
                BackgroundTransparency = 1,
                Text = "",
                Parent = Container
            })

            local function GetTextState()
                if Multi then
                    if #Selected == 0 then return "None" end
                    return table.concat(Selected, ", ")
                else
                    return SingleSelect
                end
            end

            local Label = Create("TextLabel", {
                Size = UDim2.new(1, -40, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = Text .. ": " .. GetTextState(),
                TextColor3 = Theme.Text,
                Font = GetFont(),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = MainBtn
            })

            local Arrow = Create("TextLabel", {
                Size = UDim2.new(0, 30, 0, 30),
                Position = UDim2.new(1, -8, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                Text = "v", -- Usando 'v' como seta minimalista ou substitua por imagem
                TextColor3 = Theme.Text,
                Font = GetFont(),
                TextSize = 16,
                Rotation = 0,
                Parent = MainBtn
            })

            local OptionList = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, Settings.MobileHeight),
                BackgroundTransparency = 1,
                Parent = Container
            })
            local UIList = Create("UIListLayout", {Parent = OptionList, SortOrder = "LayoutOrder", Padding = UDim.new(0, 2)})
            Create("UIPadding", {Parent = OptionList, PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5)})

            local function RefreshList()
                for _, v in pairs(OptionList:GetChildren()) do
                    if v:IsA("TextButton") then v:Destroy() end
                end

                for _, opt in pairs(Options) do
                    local IsActive = false
                    if Multi then
                        if table.find(Selected, opt) then IsActive = true end
                    else
                        if SingleSelect == opt then IsActive = true end
                    end

                    local OptBtn = Create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 32),
                        BackgroundColor3 = IsActive and Theme.Accent or Color3.fromRGB(25, 25, 25),
                        Text = opt,
                        TextColor3 = IsActive and Color3.new(0,0,0) or Theme.TextDark,
                        Font = GetFont(),
                        TextSize = 13,
                        Parent = OptionList
                    })
                    AddCorner(OptBtn, 6)

                    OptBtn.MouseButton1Click:Connect(function()
                        if Multi then
                            local idx = table.find(Selected, opt)
                            if idx then
                                table.remove(Selected, idx)
                            else
                                table.insert(Selected, opt)
                            end
                            Label.Text = Text .. ": " .. GetTextState()
                            Callback(Selected)
                            RefreshList()
                        else
                            SingleSelect = opt
                            Label.Text = Text .. ": " .. SingleSelect
                            Callback(opt)
                            -- Fecha dropdown ao selecionar (apenas modo Single)
                            IsOpen = false
                            Dropdown:Toggle(false) 
                        end
                    end)
                end
            end

            function Dropdown:Toggle(forceState)
                if forceState ~= nil then IsOpen = forceState else IsOpen = not IsOpen end
                
                local ListHeight = (#Options * 34) + 10
                local TargetHeight = IsOpen and (Settings.MobileHeight + ListHeight) or Settings.MobileHeight

                -- Animação Bouncy na altura do Dropdown
                TweenService:Create(Container, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, TargetHeight)}):Play()
                
                -- Rotação da Seta
                TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = IsOpen and 180 or 0}):Play()
                
                -- Mudança de cor da Borda
                TweenService:Create(CStroke, TweenInfo.new(0.3), {Color = IsOpen and Theme.Accent or Theme.Stroke}):Play()

                if IsOpen then RefreshList() end
            end

            MainBtn.MouseButton1Click:Connect(function() Dropdown:Toggle() end)
            
            return Dropdown
        end

        return Tab
    end
    return Window
end

return Library
