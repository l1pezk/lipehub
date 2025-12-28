local Lib = (function()
    --[[ 
        Lipe Ui Library - Fluent Version (Internal Syntax Modified)
        Visual: Original Lipe UI
        Syntax: Fluent Compatible
    ]]

    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local TextService = game:GetService("TextService")
    local CoreGui = game:GetService("CoreGui")
    local Players = game:GetService("Players")

    local BouncyLib = {}
    BouncyLib.Options = {} -- Tabela global de opções estilo Fluent

    -- [[ CONFIGURAÇÕES VISUAIS ]] --
    local Colors = {
        Background = Color3.fromRGB(10, 10, 12),
        Header     = Color3.fromRGB(15, 15, 20),
        Element    = Color3.fromRGB(20, 20, 25),
        Tab        = Color3.fromRGB(25, 25, 30),
        Text       = Color3.fromRGB(240, 240, 240),
        Accent     = Color3.fromHex("2CFF05"), -- Verde Neon
        ToggleOff  = Color3.fromRGB(35, 35, 40),
        Close      = Color3.fromRGB(255, 60, 60),
        Minimize   = Color3.fromRGB(255, 200, 50),
        DropdownBg = Color3.fromRGB(15, 15, 20)
    }

    local function Tween(obj, info, props)
        local anim = TweenService:Create(obj, info, props)
        anim:Play()
        return anim
    end

    -- Sistema de Arrastar
    local function MakeDraggable(topbarobject, object)
        local Dragging, DragInput, DragStart, StartPosition

        topbarobject.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = input.Position
                StartPosition = object.Position
                local connection
                connection = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        Dragging = false
                        if connection then connection:Disconnect() end
                    end
                end)
            end
        end)

        topbarobject.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                DragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == DragInput and Dragging then
                local Delta = input.Position - DragStart
                local TargetPos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
                TweenService:Create(object, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {Position = TargetPos}):Play()
            end
        end)
    end

    -- [[ CRIAÇÃO DA JANELA ESTILO FLUENT ]] --
    function BouncyLib:CreateWindow(Config)
        -- Fluent passa uma tabela {Title = "X", SubTitle = "Y", ...}
        -- Se passar string direta, adaptamos
        local TitleText = (type(Config) == "table" and Config.Title) or Config or "Lipe Hub"
        
        local GuiName = "LipeHub_Library_Fluent"
        
        pcall(function()
            if CoreGui:FindFirstChild(GuiName) then CoreGui[GuiName]:Destroy() end
            if getgenv and getgenv().gethui and getgenv().gethui():FindFirstChild(GuiName) then 
                getgenv().gethui()[GuiName]:Destroy() 
            end
        end)

        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = GuiName
        
        local parentSuccess = pcall(function()
            if syn and syn.protect_gui then syn.protect_gui(ScreenGui); ScreenGui.Parent = CoreGui 
            elseif getgenv and getgenv().gethui then ScreenGui.Parent = getgenv().gethui()
            else ScreenGui.Parent = CoreGui end
        end)
        if not parentSuccess then ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

        -- [[ BOTÃO DE ABRIR ]] --
        local OpenFrame = Instance.new("TextButton"); OpenFrame.Name = "OpenFrame"; OpenFrame.Size = UDim2.new(0, 0, 0, 0); OpenFrame.Position = UDim2.new(0.5, -60, 0, 10); OpenFrame.BackgroundColor3 = Colors.Header; OpenFrame.Text = ""; OpenFrame.AutoButtonColor = false; OpenFrame.Parent = ScreenGui
        local OpenCorner = Instance.new("UICorner"); OpenCorner.CornerRadius = UDim.new(0, 16); OpenCorner.Parent = OpenFrame
        local OpenStroke = Instance.new("UIStroke"); OpenStroke.Color = Colors.Accent; OpenStroke.Thickness = 2; OpenStroke.Parent = OpenFrame
        local OpenText = Instance.new("TextLabel"); OpenText.Text = "Abrir"; OpenText.Size = UDim2.new(1,0,1,0); OpenText.BackgroundTransparency = 1; OpenText.TextColor3 = Colors.Accent; OpenText.Font = Enum.Font.GothamBold; OpenText.TextSize = 14; OpenText.Parent = OpenFrame
        MakeDraggable(OpenFrame, OpenFrame)

        -- [[ MAIN FRAME ]] --
        local MainFrame = Instance.new("Frame"); MainFrame.Name = "MainFrame"; MainFrame.Size = UDim2.new(0, 0, 0, 0); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0); MainFrame.AnchorPoint = Vector2.new(0.5, 0.5); MainFrame.BackgroundColor3 = Colors.Background; MainFrame.ClipsDescendants = true; MainFrame.Visible = false; MainFrame.Parent = ScreenGui
        local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 12); MainCorner.Parent = MainFrame
        local MainStroke = Instance.new("UIStroke"); MainStroke.Color = Colors.Accent; MainStroke.Thickness = 1.5; MainStroke.Transparency = 0.5; MainStroke.Parent = MainFrame

        -- Header
        local Header = Instance.new("Frame"); Header.Name = "Header"; Header.Size = UDim2.new(1,0,0,35); Header.BackgroundColor3 = Colors.Header; Header.Parent = MainFrame
        local HeaderCorner = Instance.new("UICorner"); HeaderCorner.CornerRadius = UDim.new(0,12); HeaderCorner.Parent = Header
        local Title = Instance.new("TextLabel"); Title.Text = TitleText; Title.Size = UDim2.new(1,-70,1,0); Title.Position = UDim2.new(0,15,0,0); Title.BackgroundTransparency = 1; Title.TextColor3 = Colors.Accent; Title.TextSize = 16; Title.Font = Enum.Font.GothamBlack; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Parent = Header
        MakeDraggable(Header, MainFrame)

        -- Botões Janela
        local CloseBtn = Instance.new("TextButton"); CloseBtn.Size = UDim2.new(0,25,0,25); CloseBtn.Position = UDim2.new(1,-30,0.5,-12.5); CloseBtn.BackgroundColor3 = Colors.Background; CloseBtn.Text = "X"; CloseBtn.TextColor3 = Colors.Close; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.Parent = Header
        Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,6)
        CloseBtn.MouseButton1Click:Connect(function() Tween(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)}).Completed:Wait(); ScreenGui:Destroy() end)

        local MinBtn = Instance.new("TextButton"); MinBtn.Size = UDim2.new(0,25,0,25); MinBtn.Position = UDim2.new(1,-60,0.5,-12.5); MinBtn.BackgroundColor3 = Colors.Background; MinBtn.Text = "-"; MinBtn.TextColor3 = Colors.Minimize; MinBtn.Font = Enum.Font.GothamBold; MinBtn.Parent = Header
        Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0,6)
        MinBtn.MouseButton1Click:Connect(function() Tween(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)}).Completed:Wait(); MainFrame.Visible = false; OpenFrame.Visible = true; Tween(OpenFrame, TweenInfo.new(0.5, Enum.EasingStyle.Elastic), {Size = UDim2.new(0, 120, 0, 35)}) end)
        OpenFrame.MouseButton1Click:Connect(function() Tween(OpenFrame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)}).Completed:Wait(); OpenFrame.Visible = false; MainFrame.Visible = true; Tween(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 360, 0, 300)}) end)

        -- [[ TABS & PAGES ]] --
        local TabHolder = Instance.new("ScrollingFrame"); TabHolder.Size = UDim2.new(1,-10,0,30); TabHolder.Position = UDim2.new(0,5,0,40); TabHolder.BackgroundTransparency = 1; TabHolder.ScrollBarThickness = 0; TabHolder.AutomaticCanvasSize = Enum.AutomaticSize.X; TabHolder.CanvasSize = UDim2.new(0,0,0,0); TabHolder.Parent = MainFrame
        local TabLayout = Instance.new("UIListLayout"); TabLayout.FillDirection = Enum.FillDirection.Horizontal; TabLayout.SortOrder = Enum.SortOrder.LayoutOrder; TabLayout.Padding = UDim.new(0,5); TabLayout.Parent = TabHolder
        local PagesHolder = Instance.new("Frame"); PagesHolder.Size = UDim2.new(1,-10,1,-80); PagesHolder.Position = UDim2.new(0,5,0,75); PagesHolder.BackgroundTransparency = 1; PagesHolder.ClipsDescendants = true; PagesHolder.Parent = MainFrame

        Tween(OpenFrame, TweenInfo.new(0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Size = UDim2.new(0, 120, 0, 35)})

        local WindowFuncs = {}
        local Tabs = {}
        local FirstTab = true

        -- [[ ADDTAB (Fluent Style) ]] --
        function WindowFuncs:AddTab(TabConfig)
            -- Suporte para passar string ou tabela
            local TabName = (type(TabConfig) == "table" and TabConfig.Title) or TabConfig
            
            local TextWidth = TextService:GetTextSize(TabName, 13, Enum.Font.GothamBold, Vector2.new(999, 35)).X
            local ButtonWidth = TextWidth + 24
            local TabBtn = Instance.new("TextButton"); TabBtn.Name = TabName; TabBtn.Size = UDim2.new(0, ButtonWidth, 1, 0); TabBtn.BackgroundColor3 = FirstTab and Colors.Accent or Colors.Tab; TabBtn.Text = TabName; TabBtn.TextColor3 = FirstTab and Color3.new(0,0,0) or Colors.Text; TabBtn.Font = Enum.Font.GothamBold; TabBtn.TextSize = 13; TabBtn.AutoButtonColor = false; TabBtn.Parent = TabHolder
            Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0,6)
            
            local Page = Instance.new("ScrollingFrame"); Page.Name = TabName.."_Page"; Page.Size = UDim2.new(1,0,1,0); Page.BackgroundTransparency = 1; Page.ScrollBarThickness = 2; Page.ScrollBarImageColor3 = Colors.Accent; Page.Visible = FirstTab; Page.Parent = PagesHolder
            local PageLayout = Instance.new("UIListLayout"); PageLayout.SortOrder = Enum.SortOrder.LayoutOrder; PageLayout.Padding = UDim.new(0,6); PageLayout.Parent = Page
            Instance.new("UIPadding", Page).PaddingTop = UDim.new(0,5); Page.UIPadding.PaddingLeft = UDim.new(0,2); Page.UIPadding.PaddingRight = UDim.new(0,2)
            PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10) end)
            
            table.insert(Tabs, {Btn = TabBtn, Page = Page})
            TabBtn.MouseButton1Click:Connect(function()
                for _, t in pairs(Tabs) do Tween(t.Btn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Tab, TextColor3 = Colors.Text}); t.Page.Visible = false end
                Tween(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Accent, TextColor3 = Color3.new(0,0,0)}); Page.Visible = true
            end)
            FirstTab = false

            local TabFuncs = {}

            -- [[ ADDBUTTON (Fluent Style) ]] --
            function TabFuncs:AddButton(BtnConfig)
                local Text = BtnConfig.Title or "Button"
                local Callback = BtnConfig.Callback or function() end
                
                local ButtonFrame = Instance.new("TextButton"); ButtonFrame.Size = UDim2.new(1,0,0,32); ButtonFrame.BackgroundColor3 = Colors.Element; ButtonFrame.Text = ""; ButtonFrame.AutoButtonColor = false; ButtonFrame.Parent = Page
                Instance.new("UICorner", ButtonFrame).CornerRadius = UDim.new(0,6)
                local BText = Instance.new("TextLabel"); BText.Text = Text; BText.Size = UDim2.new(1,0,1,0); BText.BackgroundTransparency = 1; BText.TextColor3 = Colors.Text; BText.Font = Enum.Font.GothamMedium; BText.TextSize = 13; BText.Parent = ButtonFrame
                ButtonFrame.MouseButton1Down:Connect(function() Tween(ButtonFrame, TweenInfo.new(0.1), {Size = UDim2.new(0.96,0,0,32)}) end)
                ButtonFrame.MouseButton1Up:Connect(function() Tween(ButtonFrame, TweenInfo.new(0.4, Enum.EasingStyle.Elastic), {Size = UDim2.new(1,0,0,32)}); Callback() end)
            end

            -- [[ ADDTOGGLE (Fluent Style) ]] --
            function TabFuncs:AddToggle(Key, ToggleConfig)
                local Text = ToggleConfig.Title or "Toggle"
                local Default = ToggleConfig.Default or false
                local Func = ToggleConfig.Callback -- Callback inicial

                local ToggleObj = { Value = Default }
                BouncyLib.Options[Key] = ToggleObj -- Salva na tabela global Options

                local TogFrame = Instance.new("TextButton"); TogFrame.Size = UDim2.new(1,0,0,32); TogFrame.BackgroundColor3 = Colors.Element; TogFrame.Text = ""; TogFrame.AutoButtonColor = false; TogFrame.Parent = Page
                Instance.new("UICorner", TogFrame).CornerRadius = UDim.new(0,6)
                local TText = Instance.new("TextLabel"); TText.Text = Text; TText.Size = UDim2.new(1,-50,1,0); TText.Position = UDim2.new(0,10,0,0); TText.BackgroundTransparency = 1; TText.TextColor3 = Colors.Text; TText.Font = Enum.Font.GothamMedium; TText.TextSize = 13; TText.TextXAlignment = Enum.TextXAlignment.Left; TText.Parent = TogFrame
                local SwBg = Instance.new("Frame"); SwBg.Size = UDim2.new(0,36,0,18); SwBg.Position = UDim2.new(1,-45,0.5,-9); SwBg.BackgroundColor3 = Default and Colors.Accent or Colors.ToggleOff; SwBg.Parent = TogFrame
                Instance.new("UICorner", SwBg).CornerRadius = UDim.new(0,9)
                local SwCir = Instance.new("Frame"); SwCir.Size = UDim2.new(0,14,0,14); SwCir.Position = Default and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7); SwCir.BackgroundColor3 = Colors.Text; SwCir.Parent = SwBg
                Instance.new("UICorner", SwCir).CornerRadius = UDim.new(0,9)

                -- Lógica Interna
                local function UpdateState(Val)
                    ToggleObj.Value = Val
                    Tween(SwBg, TweenInfo.new(0.2), {BackgroundColor3 = Val and Colors.Accent or Colors.ToggleOff})
                    Tween(SwCir, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Position = Val and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)})
                    if ToggleObj.Callback then ToggleObj.Callback(Val) end -- Chama Callback conectada via OnChanged
                    if Func then Func(Val) end -- Chama callback passada na criação
                end

                TogFrame.MouseButton1Click:Connect(function() UpdateState(not ToggleObj.Value) end)
                if Default then UpdateState(true) end

                -- Métodos Fluent (Retorno)
                function ToggleObj:OnChanged(newFunc) ToggleObj.Callback = newFunc end
                function ToggleObj:SetValue(Val) UpdateState(Val) end
                
                return ToggleObj
            end

            -- [[ ADDSLIDER (Fluent Style) ]] --
            function TabFuncs:AddSlider(Key, SldConfig)
                local Text = SldConfig.Title or "Slider"
                local Min = SldConfig.Min or 0
                local Max = SldConfig.Max or 100
                local Default = SldConfig.Default or Min
                local Rounding = SldConfig.Rounding or 1
                local Func = SldConfig.Callback

                local SliderObj = { Value = Default }
                BouncyLib.Options[Key] = SliderObj

                local SFrame = Instance.new("Frame"); SFrame.Size = UDim2.new(1,0,0,45); SFrame.BackgroundColor3 = Colors.Element; SFrame.Parent = Page
                Instance.new("UICorner", SFrame).CornerRadius = UDim.new(0,6)
                local SText = Instance.new("TextLabel"); SText.Text = Text; SText.Size = UDim2.new(1,-20,0,20); SText.Position = UDim2.new(0,10,0,2); SText.BackgroundTransparency = 1; SText.TextColor3 = Colors.Text; SText.Font = Enum.Font.GothamMedium; SText.TextSize = 13; SText.TextXAlignment = Enum.TextXAlignment.Left; SText.Parent = SFrame
                local VText = Instance.new("TextLabel"); VText.Text = tostring(Default); VText.Size = UDim2.new(0,50,0,20); VText.Position = UDim2.new(1,-60,0,2); VText.BackgroundTransparency = 1; VText.TextColor3 = Colors.Accent; VText.Font = Enum.Font.GothamBold; VText.TextSize = 13; VText.TextXAlignment = Enum.TextXAlignment.Right; VText.Parent = SFrame
                local BarBg = Instance.new("TextButton"); BarBg.Text = ""; BarBg.AutoButtonColor = false; BarBg.Size = UDim2.new(1,-20,0,6); BarBg.Position = UDim2.new(0,10,0,28); BarBg.BackgroundColor3 = Colors.ToggleOff; BarBg.Parent = SFrame
                Instance.new("UICorner", BarBg).CornerRadius = UDim.new(0,3)
                local Fill = Instance.new("Frame"); Fill.Size = UDim2.new((Default-Min)/(Max-Min),0,1,0); Fill.BackgroundColor3 = Colors.Accent; Fill.BorderSizePixel = 0; Fill.Parent = BarBg
                Instance.new("UICorner", Fill).CornerRadius = UDim.new(0,3)
                
                -- Lógica
                local function UpdateVisual(Val)
                     SliderObj.Value = Val
                     VText.Text = tostring(Val)
                     local Percent = (Val - Min) / (Max - Min)
                     Tween(Fill, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {Size = UDim2.new(Percent, 0, 1, 0)})
                     if SliderObj.Callback then SliderObj.Callback(Val) end
                     if Func then Func(Val) end
                end

                local Dragging = false
                local function InputUpdate(Input)
                    local SizeX = math.clamp((Input.Position.X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)
                    local NewValue = math.floor(Min + ((Max - Min) * SizeX))
                    if Rounding then NewValue = math.floor(NewValue / Rounding + 0.5) * Rounding end
                    UpdateVisual(NewValue)
                end

                BarBg.InputBegan:Connect(function(I) if I.UserInputType == Enum.UserInputType.MouseButton1 or I.UserInputType == Enum.UserInputType.Touch then Dragging = true; InputUpdate(I) end end)
                UserInputService.InputChanged:Connect(function(I) if Dragging and (I.UserInputType == Enum.UserInputType.MouseMovement or I.UserInputType == Enum.UserInputType.Touch) then InputUpdate(I) end end)
                UserInputService.InputEnded:Connect(function(I) if I.UserInputType == Enum.UserInputType.MouseButton1 or I.UserInputType == Enum.UserInputType.Touch then Dragging = false end end)

                function SliderObj:OnChanged(newFunc) SliderObj.Callback = newFunc end
                function SliderObj:SetValue(Val) UpdateVisual(Val) end

                return SliderObj
            end

            -- [[ ADDDROPDOWN (Fluent Style) ]] --
            function TabFuncs:AddDropdown(Key, DropConfig)
                local Text = DropConfig.Title or "Dropdown"
                local Options = DropConfig.Values or {}
                local Default = DropConfig.Default or Options[1] or "None"
                local Func = DropConfig.Callback

                local DropObj = { Value = Default }
                BouncyLib.Options[Key] = DropObj

                local IsOpen = false
                local BaseHeight = 34
                local OptionHeight = 30
                
                local DropFrame = Instance.new("Frame"); DropFrame.Name = "DropdownFrame"; DropFrame.Size = UDim2.new(1, 0, 0, BaseHeight); DropFrame.BackgroundColor3 = Colors.Element; DropFrame.ClipsDescendants = true; DropFrame.Parent = Page
                Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 6)
                
                local DropBtn = Instance.new("TextButton"); DropBtn.Name = "MainButton"; DropBtn.Size = UDim2.new(1, 0, 0, BaseHeight); DropBtn.BackgroundTransparency = 1; DropBtn.Text = ""; DropBtn.AutoButtonColor = false; DropBtn.Parent = DropFrame
                local Label = Instance.new("TextLabel"); Label.Text = Text; Label.Size = UDim2.new(1, -30, 1, 0); Label.Position = UDim2.new(0, 10, 0, 0); Label.BackgroundTransparency = 1; Label.TextColor3 = Colors.Text; Label.Font = Enum.Font.GothamMedium; Label.TextSize = 13; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = DropBtn
                local Status = Instance.new("TextLabel"); Status.Text = Default; Status.Size = UDim2.new(1, -40, 1, 0); Status.Position = UDim2.new(0, 0, 0, 0); Status.BackgroundTransparency = 1; Status.TextColor3 = Colors.Accent; Status.Font = Enum.Font.GothamBold; Status.TextSize = 13; Status.TextXAlignment = Enum.TextXAlignment.Right; Status.Parent = DropBtn
                local Arrow = Instance.new("TextLabel"); Arrow.Text = ">"; Arrow.Size = UDim2.new(0, 30, 0, 34); Arrow.Position = UDim2.new(1, -30, 0, 0); Arrow.BackgroundTransparency = 1; Arrow.TextColor3 = Colors.Text; Arrow.Font = Enum.Font.GothamBold; Arrow.TextSize = 14; Arrow.Parent = DropBtn
                
                local OptionContainer = Instance.new("Frame"); OptionContainer.Position = UDim2.new(0, 5, 0, 34); OptionContainer.BackgroundColor3 = Colors.DropdownBg; OptionContainer.BackgroundTransparency = 1; OptionContainer.Parent = DropFrame
                local ListLayout = Instance.new("UIListLayout"); ListLayout.SortOrder = Enum.SortOrder.LayoutOrder; ListLayout.Padding = UDim.new(0, 2); ListLayout.Parent = OptionContainer

                local function UpdateVisual(Val)
                     DropObj.Value = Val
                     Status.Text = tostring(Val)
                     if DropObj.Callback then DropObj.Callback(Val) end
                     if Func then Func(Val) end
                     -- Fecha o menu
                     IsOpen = false
                     Tween(DropFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, BaseHeight)})
                     Tween(Arrow, TweenInfo.new(0.3), {Rotation = 0})
                end

                local function RefreshOptions()
                    for _, v in pairs(OptionContainer:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                    
                    for _, opt in pairs(Options) do
                        local OptBtn = Instance.new("TextButton"); OptBtn.Size = UDim2.new(1, 0, 0, OptionHeight); OptBtn.BackgroundColor3 = Colors.DropdownBg; OptBtn.BackgroundTransparency = 0.5; OptBtn.Text = opt; OptBtn.TextColor3 = (opt == DropObj.Value) and Colors.Accent or Colors.Text; OptBtn.Font = Enum.Font.GothamMedium; OptBtn.TextSize = 13; OptBtn.AutoButtonColor = false; OptBtn.Parent = OptionContainer
                        Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0,4)
                        OptBtn.MouseButton1Click:Connect(function() UpdateVisual(opt); RefreshOptions() end)
                    end
                    OptionContainer.Size = UDim2.new(1, -10, 0, #Options * (OptionHeight + 2))
                end
                
                RefreshOptions()
                DropBtn.MouseButton1Click:Connect(function()
                    IsOpen = not IsOpen
                    local TargetHeight = IsOpen and (BaseHeight + (#Options * (OptionHeight + 2)) + 5) or BaseHeight
                    Tween(DropFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, TargetHeight)})
                    Tween(Arrow, TweenInfo.new(0.3), {Rotation = IsOpen and 90 or 0})
                end)

                function DropObj:OnChanged(newFunc) DropObj.Callback = newFunc end
                function DropObj:SetValue(Val) UpdateVisual(Val) end
                
                return DropObj
            end

            -- [[ ADDPARAGRAPH (Fluent Style) ]] --
            function TabFuncs:AddParagraph(ParaConfig)
                local Title = ParaConfig.Title or ""
                local Content = ParaConfig.Content or ""
                local FullText = Title .. ": " .. Content
                
                local LFrame = Instance.new("Frame"); LFrame.Size = UDim2.new(1,0,0,22); LFrame.BackgroundTransparency = 1; LFrame.Parent = Page
                local LText = Instance.new("TextLabel"); LText.Text = FullText; LText.Size = UDim2.new(1,0,1,0); LText.BackgroundTransparency = 1; LText.TextColor3 = Colors.Accent; LText.Font = Enum.Font.GothamBold; LText.TextSize = 13; LText.Parent = LFrame

                local ParaObj = {}
                function ParaObj:SetDesc(NewContent)
                    LText.Text = Title .. ": " .. NewContent
                end
                return ParaObj
            end

            return TabFuncs
        end
        return WindowFuncs
    end
    return BouncyLib
end)()

return Lib
