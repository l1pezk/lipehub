local Library = {}

-- [[ SERVIÇOS ]] --
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- [[ TEMA ]] --
local Theme = {
    Background = Color3.fromRGB(18, 18, 18),
    Container  = Color3.fromRGB(24, 24, 24),
    Stroke     = Color3.fromRGB(45, 45, 45),
    Text       = Color3.fromRGB(240, 240, 240),
    TextDark   = Color3.fromRGB(160, 160, 160),
    Red        = Color3.fromRGB(255, 80, 80),
    Accent     = Color3.fromHex("EBF3E7") -- Seu Creme/Verde Claro
}

local GlobalFont = Enum.Font.Quicksand 
local MobileHeight = 42 

-- [[ FUNÇÕES VISUAIS ]] --
local function CreateCorner(parent, radius)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, radius); c.Parent = parent; return c
end

local function CreateStroke(parent, color, thickness)
    local s = Instance.new("UIStroke"); s.Color = color; s.Thickness = thickness; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = parent; return s
end

local function Ripple(btn)
    task.spawn(function()
        local c = Instance.new("Frame"); c.Name = "Ripple"; c.BackgroundColor3 = Theme.Accent; c.BackgroundTransparency = 0.8; c.Size = UDim2.new(0,0,0,0); c.Position = UDim2.new(0.5,0,0.5,0); c.AnchorPoint = Vector2.new(0.5,0.5); c.Parent = btn; CreateCorner(c, 100)
        TweenService:Create(c, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {Size = UDim2.new(1.5,0,2.5,0), BackgroundTransparency = 1}):Play()
        task.wait(0.4); c:Destroy()
    end)
end

local function MakeDraggable(topbarobject, object)
    local Dragging, DragInput, DragStart, StartPosition
    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true; DragStart = input.Position; StartPosition = object.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Dragging = false end end)
        end
    end)
    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then DragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            local TargetPos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
            TweenService:Create(object, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {Position = TargetPos}):Play()
        end
    end)
end

-- [[ INÍCIO DA LIBRARY ]] --
function Library:CreateWindow(TitleText)
    local Window = {}

    local Old = CoreGui:FindFirstChild("LipeHubUI_Final")
    if Old then Old:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LipeHubUI_Final"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- [[ ÍCONE MINIMIZADO (FLUTUANTE) ]] --
    local OpenBtn = Instance.new("ImageButton")
    OpenBtn.Name = "OpenIcon"
    OpenBtn.Size = UDim2.new(0, 50, 0, 50)
    OpenBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
    OpenBtn.BackgroundColor3 = Theme.Background
    OpenBtn.Image = "rbxassetid://16666299831" 
    OpenBtn.Visible = true  -- <--- COMEÇA VISÍVEL (MINIMIZADO)
    OpenBtn.Parent = ScreenGui
    CreateCorner(OpenBtn, 16) 
    CreateStroke(OpenBtn, Theme.Accent, 2)
    MakeDraggable(OpenBtn, OpenBtn)

    -- [[ FRAME PRINCIPAL ]] --
    local Main = Instance.new("Frame")
    Main.Name = "MainFrame"
    Main.Size = UDim2.new(0, 0, 0, 0) -- Tamanho 0 para animar ao abrir
    Main.Position = UDim2.new(0.5, -240, 0.5, -175)
    Main.BackgroundColor3 = Theme.Background
    Main.Visible = false -- <--- COMEÇA INVISÍVEL
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    CreateCorner(Main, 14)
    CreateStroke(Main, Theme.Stroke, 1.5)

    local MainSize = UDim2.new(0, 480, 0, 350)

    -- Topbar
    local Topbar = Instance.new("Frame"); Topbar.Size = UDim2.new(1, 0, 0, 40); Topbar.BackgroundColor3 = Theme.Container; Topbar.BorderSizePixel = 0; Topbar.Parent = Main
    local TopFix = Instance.new("Frame"); TopFix.Size = UDim2.new(1,0,0,10); TopFix.Position=UDim2.new(0,0,1,-5); TopFix.BackgroundColor3=Theme.Container; TopFix.BorderSizePixel=0; TopFix.Parent=Topbar
    CreateCorner(Topbar, 14)

    local Title = Instance.new("TextLabel"); Title.Text = TitleText; Title.Font = GlobalFont; Title.TextSize = 16; Title.TextColor3 = Theme.Accent; Title.Size = UDim2.new(1, -90, 1, 0); Title.Position = UDim2.new(0, 15, 0, 0); Title.BackgroundTransparency = 1; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Parent = Topbar
    MakeDraggable(Topbar, Main)

    -- Botões Janela
    local CloseBtn = Instance.new("TextButton"); CloseBtn.Size = UDim2.new(0, 40, 1, 0); CloseBtn.Position = UDim2.new(1, -40, 0, 0); CloseBtn.BackgroundTransparency = 1; CloseBtn.Text = "×"; CloseBtn.TextColor3 = Theme.Red; CloseBtn.Font = GlobalFont; CloseBtn.TextSize = 26; CloseBtn.Parent = Topbar
    CloseBtn.MouseButton1Click:Connect(function() 
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)}):Play()
        task.wait(0.4); ScreenGui:Destroy() 
    end)

    local MinBtn = Instance.new("TextButton"); MinBtn.Size = UDim2.new(0, 40, 1, 0); MinBtn.Position = UDim2.new(1, -80, 0, 0); MinBtn.BackgroundTransparency = 1; MinBtn.Text = "-"; MinBtn.TextColor3 = Theme.Text; MinBtn.Font = GlobalFont; MinBtn.TextSize = 30; MinBtn.Parent = Topbar
    MinBtn.MouseButton1Click:Connect(function()
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)}):Play()
        task.wait(0.3)
        Main.Visible = false; OpenBtn.Visible = true; OpenBtn.Size = UDim2.new(0,0,0,0)
        TweenService:Create(OpenBtn, TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Size = UDim2.new(0, 50, 0, 50)}):Play()
    end)

    OpenBtn.MouseButton1Click:Connect(function()
        OpenBtn.Visible = false
        Main.Visible = true
        Main.Size = UDim2.new(0,0,0,0)
        TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = MainSize}):Play()
    end)

    local TabContainer = Instance.new("ScrollingFrame"); TabContainer.Size = UDim2.new(0, 130, 1, -40); TabContainer.Position = UDim2.new(0, 0, 0, 40); TabContainer.BackgroundColor3 = Theme.Container; TabContainer.BorderSizePixel = 0; TabContainer.ScrollBarThickness = 0; TabContainer.Parent = Main
    local TabList = Instance.new("UIListLayout"); TabList.Parent = TabContainer; TabList.SortOrder = Enum.SortOrder.LayoutOrder; TabList.Padding = UDim.new(0, 8)
    local TabPad = Instance.new("UIPadding"); TabPad.Parent = TabContainer; TabPad.PaddingTop = UDim.new(0, 15); TabPad.PaddingLeft = UDim.new(0, 10)

    local Pages = Instance.new("Frame"); Pages.Size = UDim2.new(1, -145, 1, -50); Pages.Position = UDim2.new(0, 140, 0, 45); Pages.BackgroundTransparency = 1; Pages.Parent = Main; Pages.ClipsDescendants = true

    local FirstTab = true

    function Window:Tab(Name)
        local Tab = {}
        local TabBtn = Instance.new("TextButton"); TabBtn.Size = UDim2.new(1, -10, 0, 32); TabBtn.BackgroundColor3 = Theme.Background; TabBtn.Text = Name; TabBtn.TextColor3 = Theme.TextDark; TabBtn.Font = GlobalFont; TabBtn.TextSize = 14; TabBtn.Parent = TabContainer; CreateCorner(TabBtn, 8)
        local TabStroke = CreateStroke(TabBtn, Theme.Stroke, 1)

        local Page = Instance.new("ScrollingFrame"); Page.Name = Name.."Page"; Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false; Page.ScrollBarThickness = 2; Page.ScrollBarImageColor3 = Theme.Accent; Page.Parent = Pages
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y; Page.CanvasSize = UDim2.new(0,0,0,0)

        local PageList = Instance.new("UIListLayout"); PageList.Parent = Page; PageList.SortOrder = Enum.SortOrder.LayoutOrder; PageList.Padding = UDim.new(0, 10)
        local PagePad = Instance.new("UIPadding"); PagePad.Parent = Page; PagePad.PaddingTop = UDim.new(0, 5); PagePad.PaddingRight = UDim.new(0, 8); PagePad.PaddingBottom = UDim.new(0, 20)

        if FirstTab then
            FirstTab = false; TabBtn.TextColor3 = Theme.Accent; TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35); TabStroke.Color = Theme.Accent; Page.Visible = true
        end

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(TabContainer:GetChildren()) do 
                if v:IsA("TextButton") then 
                    TweenService:Create(v, TweenInfo.new(0.3), {TextColor3 = Theme.TextDark, BackgroundColor3 = Theme.Background}):Play()
                    TweenService:Create(v:FindFirstChild("UIStroke"), TweenInfo.new(0.3), {Color = Theme.Stroke}):Play()
                end 
            end
            for _, v in pairs(Pages:GetChildren()) do v.Visible = false end
            
            Ripple(TabBtn)
            TweenService:Create(TabBtn, TweenInfo.new(0.3), {TextColor3 = Theme.Accent, BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
            TweenService:Create(TabStroke, TweenInfo.new(0.3), {Color = Theme.Accent}):Play()
            Page.Visible = true
        end)

        function Tab:Label(Text)
            local L = Instance.new("TextLabel"); L.Size = UDim2.new(1, 0, 0, 20); L.BackgroundTransparency = 1; L.Text = Text; L.TextColor3 = Theme.Text; L.Font = GlobalFont; L.TextSize = 15; L.TextXAlignment = Enum.TextXAlignment.Center; L.Parent = Page
        end

        function Tab:Button(Text, Callback)
            local B = Instance.new("TextButton"); B.Size = UDim2.new(1, 0, 0, MobileHeight); B.BackgroundColor3 = Theme.Container; B.Text = Text; B.TextColor3 = Theme.Text; B.Font = GlobalFont; B.TextSize = 14; B.Parent = Page; CreateCorner(B, 8)
            local S = CreateStroke(B, Theme.Stroke, 1.2)
            
            B.MouseButton1Click:Connect(function()
                Ripple(B)
                TweenService:Create(B, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent, TextColor3 = Color3.new(0,0,0)}):Play()
                TweenService:Create(S, TweenInfo.new(0.1), {Color = Theme.Accent}):Play()
                task.wait(0.15)
                TweenService:Create(B, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Container, TextColor3 = Theme.Text}):Play()
                TweenService:Create(S, TweenInfo.new(0.3), {Color = Theme.Stroke}):Play()
                if Callback then Callback() end
            end)
        end

        function Tab:Toggle(Text, Default, Callback)
            local Tog = Default or false
            local C = Instance.new("TextButton"); C.Size = UDim2.new(1, 0, 0, MobileHeight + 4); C.BackgroundColor3 = Theme.Container; C.Text = ""; C.Parent = Page; CreateCorner(C, 8)
            local MainStroke = CreateStroke(C, Theme.Stroke, 1.2)

            local Check = Instance.new("Frame"); Check.Size = UDim2.new(0, 22, 0, 22); Check.Position = UDim2.new(1, -12, 0.5, 0); Check.AnchorPoint = Vector2.new(1, 0.5); Check.BackgroundColor3 = Color3.fromRGB(30,30,30); Check.Parent = C; CreateCorner(Check, 6)
            local CheckStroke = CreateStroke(Check, Theme.Stroke, 1.2)
            
            local Fill = Instance.new("Frame"); Fill.Size = UDim2.new(0,0,0,0); Fill.Position = UDim2.new(0.5,0,0.5,0); Fill.AnchorPoint = Vector2.new(0.5,0.5); Fill.BackgroundColor3 = Theme.Accent; Fill.Parent = Check; CreateCorner(Fill, 4)
            
            local T = Instance.new("TextLabel"); T.Size = UDim2.new(1, -50, 1, 0); T.Position = UDim2.new(0, 12, 0, 0); T.BackgroundTransparency = 1; T.Text = Text; T.TextColor3 = Theme.Text; T.Font = GlobalFont; T.TextSize = 14; T.TextXAlignment = Enum.TextXAlignment.Left; T.Parent = C

            local function Update()
                if Tog then
                    TweenService:Create(Fill, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, -4, 1, -4)}):Play()
                    TweenService:Create(CheckStroke, TweenInfo.new(0.3), {Color = Theme.Accent}):Play()
                    TweenService:Create(MainStroke, TweenInfo.new(0.3), {Color = Theme.Accent}):Play()
                    TweenService:Create(T, TweenInfo.new(0.3), {TextColor3 = Theme.Accent}):Play()
                else
                    TweenService:Create(Fill, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 0, 0, 0)}):Play()
                    TweenService:Create(CheckStroke, TweenInfo.new(0.3), {Color = Theme.Stroke}):Play()
                    TweenService:Create(MainStroke, TweenInfo.new(0.3), {Color = Theme.Stroke}):Play()
                    TweenService:Create(T, TweenInfo.new(0.3), {TextColor3 = Theme.Text}):Play()
                end
            end
            
            C.MouseButton1Click:Connect(function() Tog = not Tog; Update(); if Callback then Callback(Tog) end end)
            if Default then Update() end
        end

        function Tab:Slider(Text, Min, Max, Default, Callback)
            local Val = Default or Min; local Dragging = false
            local F = Instance.new("Frame"); F.Size = UDim2.new(1,0,0,56); F.BackgroundColor3 = Theme.Container; F.Parent = Page; CreateCorner(F, 8); CreateStroke(F, Theme.Stroke, 1.2)
            
            local T = Instance.new("TextLabel"); T.Size = UDim2.new(1,-20,0,20); T.Position = UDim2.new(0,10,0,4); T.BackgroundTransparency=1; T.Text=Text; T.TextColor3=Theme.Text; T.Font=GlobalFont; T.TextSize=14; T.TextXAlignment=Enum.TextXAlignment.Left; T.Parent=F
            local V = Instance.new("TextLabel"); V.Size = UDim2.new(0,50,0,20); V.Position = UDim2.new(1,-10,0,4); V.AnchorPoint=Vector2.new(1,0); V.BackgroundTransparency=1; V.Text=tostring(Val); V.TextColor3=Theme.Accent; V.Font=GlobalFont; V.TextSize=14; V.TextXAlignment=Enum.TextXAlignment.Right; V.Parent=F
            
            local Bar = Instance.new("TextButton"); Bar.Size = UDim2.new(1,-20,0,6); Bar.Position = UDim2.new(0,10,0,36); Bar.BackgroundColor3=Color3.fromRGB(40,40,40); Bar.Text=""; Bar.Parent=F; CreateCorner(Bar, 100)
            local Fill = Instance.new("Frame"); Fill.Size = UDim2.new((Val-Min)/(Max-Min),0,1,0); Fill.BackgroundColor3=Theme.Accent; Fill.Parent=Bar; CreateCorner(Fill, 100)

            local function Update(Input)
                local S = math.clamp((Input.Position.X - Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X, 0, 1)
                local New = math.floor(Min + ((Max-Min)*S))
                TweenService:Create(Fill, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {Size=UDim2.new(S,0,1,0)}):Play()
                V.Text = tostring(New)
                if Callback then Callback(New) end
            end

            Bar.InputBegan:Connect(function(I) if I.UserInputType==Enum.UserInputType.MouseButton1 or I.UserInputType==Enum.UserInputType.Touch then Dragging=true; Update(I) end end)
            UserInputService.InputChanged:Connect(function(I) if Dragging and (I.UserInputType==Enum.UserInputType.MouseMovement or I.UserInputType==Enum.UserInputType.Touch) then Update(I) end end)
            UserInputService.InputEnded:Connect(function(I) if I.UserInputType==Enum.UserInputType.MouseButton1 or I.UserInputType==Enum.UserInputType.Touch then Dragging=false end end)
        end

        function Tab:Dropdown(Text, Options, Default, Callback, Multi)
            local Open = false; local SelMap = {}; local SelectedList = {}; local Single = Default or "None"
            
            if Multi and type(Default)=="table" then 
                for _,v in pairs(Default) do table.insert(SelectedList, v); SelMap[v]=true end 
            end

            local F = Instance.new("Frame"); F.Size = UDim2.new(1,0,0,MobileHeight+4); F.BackgroundColor3 = Theme.Container; F.ClipsDescendants=true; F.Parent = Page; CreateCorner(F, 8)
            local Stroke = CreateStroke(F, Theme.Stroke, 1.2)

            local Header = Instance.new("TextButton"); Header.Size = UDim2.new(1,0,0,MobileHeight+4); Header.BackgroundTransparency=1; Header.Text=""; Header.Parent = F
            
            local function GetText()
                if Multi then
                    if #SelectedList == 0 then return "None" end
                    return table.concat(SelectedList, ", ")
                else
                    return Single or "None"
                end
            end

            local L = Instance.new("TextLabel"); L.Size = UDim2.new(1,-30,1,0); L.Position=UDim2.new(0,12,0,0); L.BackgroundTransparency=1; L.Text=Text..": "..GetText(); L.TextColor3=Theme.Text; L.Font=GlobalFont; L.TextSize=14; L.TextXAlignment=Enum.TextXAlignment.Left; L.Parent=Header
            local Arrow = Instance.new("TextLabel"); Arrow.Size=UDim2.new(0,30,0,MobileHeight+4); Arrow.Position=UDim2.new(1,-30,0,0); Arrow.BackgroundTransparency=1; Arrow.Text="▼"; Arrow.TextColor3=Theme.Text; Arrow.Font=GlobalFont; Arrow.TextSize=12; Arrow.Parent=Header

            local ListFrame = Instance.new("Frame"); ListFrame.Size=UDim2.new(1,0,0,0); ListFrame.Position=UDim2.new(0,0,0,MobileHeight+4); ListFrame.BackgroundTransparency=1; ListFrame.Parent=F
            local Layout = Instance.new("UIListLayout"); Layout.Parent=ListFrame; Layout.SortOrder=Enum.SortOrder.LayoutOrder; Layout.Padding=UDim.new(0,2)

            local function Refresh()
                for _,v in pairs(ListFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for _,o in pairs(Options) do
                    local Item = Instance.new("TextButton"); Item.Size=UDim2.new(1,-10,0,32); Item.Position=UDim2.new(0,5,0,0); Item.BackgroundColor3=Color3.fromRGB(35,35,35); Item.Text=o; Item.TextColor3=Theme.Text; Item.Font=GlobalFont; Item.TextSize=13; Item.Parent=ListFrame; CreateCorner(Item, 6)
                    
                    if (Multi and SelMap[o]) or (not Multi and o == Single) then 
                        Item.TextColor3 = Theme.Accent; Item.BackgroundColor3 = Color3.fromRGB(45,45,45)
                    end
                    
                    Item.MouseButton1Click:Connect(function()
                        if Multi then
                            if SelMap[o] then 
                                SelMap[o]=nil 
                                for i, v in ipairs(SelectedList) do if v == o then table.remove(SelectedList, i); break end end
                            else 
                                SelMap[o]=true; table.insert(SelectedList, o)
                            end
                            Refresh(); L.Text = Text..": "..GetText(); if Callback then Callback(SelectedList) end
                        else
                            Single=o; L.Text = Text..": "..GetText(); if Callback then Callback(o) end
                            Open = false
                            F:TweenSize(UDim2.new(1,0,0,MobileHeight+4), "Out", "Quint", 0.3, true)
                            TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
                            TweenService:Create(Stroke, TweenInfo.new(0.3), {Color=Theme.Stroke}):Play()
                        end
                    end)
                end
            end
            Refresh()

            Header.MouseButton1Click:Connect(function() 
                Open = not Open
                local Height = Open and (MobileHeight+4 + (#Options*34) + 6) or (MobileHeight+4)
                F:TweenSize(UDim2.new(1,0,0, Height), "Out", "Back", 0.35, true) 
                TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = Open and 180 or 0}):Play()
                TweenService:Create(Stroke, TweenInfo.new(0.3), {Color = Open and Theme.Accent or Theme.Stroke}):Play()
            end)
        end

        return Tab
    end
    return Window
end

return Library
