--[[
    Soda.Fun — UI Library & Client
    Original base by Linemaster — rebranded, restyled, refactored
    Font: Montserrat Bold | Accent: Red → Blue gradient
    Touch + Mouse support
]]

--====================================================================
-- SAFE DRAWING LOADER
--====================================================================
local Drawing
do
    local ok, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/linemaster2/storage/main/Drawing.lua"))()
    end)
    if ok and result then Drawing = result
    else Drawing = {new = function() return setmetatable({}, {__index=function() return nil end, __newindex=function() end}) end} end
end

--====================================================================
-- LIBRARY
--====================================================================
local Library = {}
do
    local FONT_FACE
    do
        local ok, f = pcall(function() return Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Bold) end)
        FONT_FACE = ok and f or Enum.Font.GothamBold
    end

    Library = {
        Name = "Soda.Fun";
        Open = true;
        Accent = Color3.fromRGB(255, 20, 80);
        AccentGradient = {Color3.fromRGB(255, 20, 80), Color3.fromRGB(60, 120, 255)};
        FontFace = FONT_FACE;
        Pages = {}; Sections = {}; Flags = {}; UnNamedFlags = 0;
        ThemeObjects = {}; Instances = {};
        Holder = nil; OldSize = nil; ScreenGUI = nil;
        DropdownOpen = false; OptionListOpen = false;
        Keys = {
            [Enum.KeyCode.Space]="Space",[Enum.KeyCode.Return]="Return",
            [Enum.KeyCode.LeftShift]="LShift",[Enum.KeyCode.RightShift]="RShift",
            [Enum.KeyCode.LeftControl]="LCtrl",[Enum.KeyCode.RightControl]="RCtrl",
            [Enum.KeyCode.LeftAlt]="LAlt",[Enum.KeyCode.RightAlt]="RAlt",
            [Enum.KeyCode.CapsLock]="CAPS",
            [Enum.KeyCode.One]="1",[Enum.KeyCode.Two]="2",[Enum.KeyCode.Three]="3",
            [Enum.KeyCode.Four]="4",[Enum.KeyCode.Five]="5",[Enum.KeyCode.Six]="6",
            [Enum.KeyCode.Seven]="7",[Enum.KeyCode.Eight]="8",[Enum.KeyCode.Nine]="9",
            [Enum.KeyCode.Zero]="0",
            [Enum.KeyCode.KeypadOne]="Num1",[Enum.KeyCode.KeypadTwo]="Num2",
            [Enum.KeyCode.KeypadThree]="Num3",[Enum.KeyCode.KeypadFour]="Num4",
            [Enum.KeyCode.KeypadFive]="Num5",[Enum.KeyCode.KeypadSix]="Num6",
            [Enum.KeyCode.KeypadSeven]="Num7",[Enum.KeyCode.KeypadEight]="Num8",
            [Enum.KeyCode.KeypadNine]="Num9",[Enum.KeyCode.KeypadZero]="Num0",
            [Enum.KeyCode.Minus]="-",[Enum.KeyCode.Equals]="=",
            [Enum.KeyCode.Tilde]="~",[Enum.KeyCode.LeftBracket]="[",
            [Enum.KeyCode.RightBracket]="]",[Enum.KeyCode.RightParenthesis]=")",
            [Enum.KeyCode.LeftParenthesis]="(",[Enum.KeyCode.Semicolon]=",",
            [Enum.KeyCode.Quote]="'",[Enum.KeyCode.BackSlash]="\\",
            [Enum.KeyCode.Comma]=",",[Enum.KeyCode.Period]=".",
            [Enum.KeyCode.Slash]="/",[Enum.KeyCode.Asterisk]="*",
            [Enum.KeyCode.Plus]="+",[Enum.KeyCode.Backquote]="`",
            [Enum.UserInputType.MouseButton1]="MB1",
            [Enum.UserInputType.MouseButton2]="MB2",
            [Enum.UserInputType.MouseButton3]="MB3"
        };
        Connections = {}; FontSize = 12; VisValues = {};
        UIKey = Enum.KeyCode.Insert; Notifs = {};
    }

    local Flags = {}
    Library.__index = Library
    Library.Pages.__index = Library.Pages
    Library.Sections.__index = Library.Sections
    local LocalPlayer = game:GetService('Players').LocalPlayer
    local Mouse = LocalPlayer:GetMouse()
    local UIS = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")

    -- Input helpers (mouse + touch)
    local function isPressInput(input)
        local t = input.UserInputType
        return t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch
    end
    local function isMoveInput(input)
        local t = input.UserInputType
        return t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch
    end

    do
        function Library:Connection(signal, Callback) return signal:Connect(Callback) end
        function Library:Disconnect(Connection) Connection:Disconnect() end
        -- FIXED NAN ERROR HERE (Division by zero when Decimals = 0)
        function Library:Round(Number, Float) 
            if not Float or Float <= 0 then return math.floor(Number + 0.5) end
            return Float * math.floor((Number / Float) + 0.5) 
        end
        function Library.NextFlag()
            Library.UnNamedFlags = Library.UnNamedFlags + 1
            return string.format("%.14g", Library.UnNamedFlags)
        end

        function Library:ApplyTheme(instance, rotation)
            rotation = rotation or 0
            instance.BackgroundColor3 = Library.AccentGradient[1]
            local gradient = Instance.new("UIGradient")
            gradient.Color = ColorSequence.new(Library.AccentGradient[1], Library.AccentGradient[2])
            gradient.Rotation = rotation
            gradient.Enabled = true
            gradient.Parent = instance
            table.insert(Library.ThemeObjects, gradient)
            return gradient
        end

        function Library:ApplyTextTheme(instance, rotation)
            rotation = rotation or 0
            instance.TextColor3 = Library.AccentGradient[1]
            local gradient = Instance.new("UIGradient")
            gradient.Color = ColorSequence.new(Library.AccentGradient[1], Library.AccentGradient[2])
            gradient.Rotation = rotation
            gradient.Enabled = true
            gradient.Parent = instance
            table.insert(Library.ThemeObjects, gradient)
            return gradient
        end

        function Library:SetOpen(bool)
            if typeof(bool) == 'boolean' then
                Library.Open = bool
                if Library.Open then
                    Library.Holder.Visible = true
                    TweenService:Create(Library.Holder, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, Library.OldSize.X.Offset, 0, Library.OldSize.Y.Offset)}):Play()
                else
                    TweenService:Create(Library.Holder, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 0, 0, 20)}):Play()
                    task.wait(0.25)
                    Library.Holder.Visible = false
                end
            end
        end

        function Library:ChangeAccent(Color1, Color2)
            if typeof(Color1) == "table" then Library.AccentGradient = {Color1[1], Color1[2] or Color1[1]}
            elseif typeof(Color1) == "Color3" and typeof(Color2) == "Color3" then Library.AccentGradient = {Color1, Color2}
            elseif typeof(Color1) == "Color3" then Library.AccentGradient = {Color1, Color1}
            else return end
            Library.Accent = Library.AccentGradient[1]
            for _, item in next, Library.ThemeObjects do
                if typeof(item) == "Instance" then
                    if item:IsA("UIGradient") then
                        item.Color = ColorSequence.new(Library.AccentGradient[1], Library.AccentGradient[2])
                    elseif item:IsA("Frame") or item:IsA("TextButton") then
                        item.BackgroundColor3 = Library.Accent
                    elseif item:IsA("TextLabel") then
                        item.TextColor3 = Library.Accent
                    elseif item:IsA("ScrollingFrame") then
                        item.ScrollBarImageColor3 = Library.Accent
                    end
                end
            end
        end

        function Library:IsMouseOverFrame(Frame)
            local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize
            if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then return true end
            return false
        end
    end

    -- Notifications
    function Library:updateNotifsPositions()
        for i, v in pairs(Library.Notifs) do
            TweenService:Create(v.Container, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Position = UDim2.new(0, 20, 0, 20 + (i * 25))}):Play()
        end
    end

    function Library:Notification(message, duration)
        local notification = {Container = nil}
        local NewInd = Instance.new("Frame")
        NewInd.AutomaticSize = Enum.AutomaticSize.X
        NewInd.Position = UDim2.new(0, 20, 0, 20)
        NewInd.BackgroundTransparency = 1
        NewInd.Size = UDim2.fromOffset(0, 20)
        NewInd.Parent = Library.ScreenGUI
        notification.Container = NewInd

        local Outline = Instance.new("Frame")
        Outline.AnchorPoint = Vector2.new(0, 0)
        Outline.AutomaticSize = Enum.AutomaticSize.X
        Outline.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Outline.BorderSizePixel = 1
        Outline.BorderColor3 = Color3.new(0, 0, 0)
        Outline.Size = UDim2.fromOffset(0, 20)
        Outline.ZIndex = 50
        Outline.BackgroundTransparency = 1
        Outline.Parent = NewInd
        local UICorner = Instance.new("UICorner", Outline); UICorner.CornerRadius = UDim.new(0, 4)
        local UIStroke = Instance.new("UIStroke", Outline); UIStroke.Transparency = 1

        local Inline = Instance.new("Frame")
        Inline.BackgroundColor3 = Color3.fromRGB(13, 13, 13)
        Inline.BorderSizePixel = 0
        Inline.Position = UDim2.fromOffset(1, 1)
        Inline.Size = UDim2.new(1, -2, 1, -2)
        Inline.ZIndex = 51
        Inline.BackgroundTransparency = 1
        Inline.Parent = Outline
        local UICorner2 = Instance.new("UICorner", Inline); UICorner2.CornerRadius = UDim.new(0, 4)

        local Title = Instance.new("TextLabel")
        Title.FontFace = Library.FontFace; Title.RichText = true; Title.Text = message
        Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.TextSize = 13
        Title.TextXAlignment = Enum.TextXAlignment.Left; Title.AutomaticSize = Enum.AutomaticSize.X
        Title.BackgroundTransparency = 1; Title.Position = UDim2.fromOffset(5, 0); Title.Size = UDim2.fromScale(0, 1)
        Title.Parent = Inline; Title.TextTransparency = 1
        local UIPadding = Instance.new("UIPadding", Inline); UIPadding.PaddingRight = UDim.new(0, 6)

        function notification:remove()
            table.remove(Library.Notifs, table.find(Library.Notifs, notification))
            Library:updateNotifsPositions(); task.wait(0.5); NewInd:Destroy()
        end

        task.spawn(function()
            Outline.AnchorPoint = Vector2.new(1, 0)
            for _, v in next, NewInd:GetDescendants() do
                if v:IsA("Frame") then TweenService:Create(v, TweenInfo.new(1, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
                elseif v:IsA("UIStroke") then TweenService:Create(v, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Transparency = 0}):Play() end
            end
            TweenService:Create(Outline, TweenInfo.new(1, Enum.EasingStyle.Exponential), {AnchorPoint = Vector2.new(0, 0)}):Play()
            TweenService:Create(Title, TweenInfo.new(1, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
            task.wait(duration)
            for _, v in next, NewInd:GetDescendants() do
                if v:IsA("Frame") then TweenService:Create(v, TweenInfo.new(1, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
                elseif v:IsA("UIStroke") then TweenService:Create(v, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Transparency = 1}):Play() end
            end
            TweenService:Create(Title, TweenInfo.new(1, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
        end)
        task.delay(duration + 0.1, function() notification:remove() end)
        table.insert(Library.Notifs, notification); Library:updateNotifsPositions()
        return notification
    end

    -- Main Window / Pages / Sections
    do
        local Pages = Library.Pages
        local Sections = Library.Sections

        function Library:New(Properties)
            if not Properties then Properties = {} end
            local Window = {Size = Properties.Size or UDim2.new(0, 600, 0, 450), Pages = {}, Dragging = {false, UDim2.new(0, 0, 0, 0)}, Elements = {}}

            local ScreenGui = Instance.new('ScreenGui', game:GetService("RunService"):IsStudio() and game.Players.LocalPlayer.PlayerGui or game.CoreGui)
            local Outline = Instance.new('Frame', ScreenGui)
            local UICorner = Instance.new('UICorner', Outline)
            local UIStroke = Instance.new('UIStroke', Outline)
            local Inline = Instance.new('Frame', Outline)
            local UICorner_2 = Instance.new('UICorner', Inline)
            local Holder = Instance.new('Frame', Inline)
            local UICorner_3 = Instance.new('UICorner', Holder)
            local Frame = Instance.new('Frame', Holder)
            local Tabs = Instance.new('Frame', Inline)
            local UIListLayout = Instance.new('UIListLayout', Tabs)
            local TextButton = Instance.new('TextButton', Inline)

            ScreenGui.DisplayOrder = 100; ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            Library.ScreenGUI = ScreenGui

            Outline.Name = "SodaOutline"; Outline.Position = UDim2.new(0.5, 0, 0.5, 0)
            Outline.Size = UDim2.new(0, 0, 0, 40); Outline.BackgroundColor3 = Color3.new(0.1961, 0.1961, 0.1961)
            Outline.AnchorPoint = Vector2.new(0.5, 0.5); Outline.ZIndex = 50; Outline.ClipsDescendants = false
            Library.Holder = Outline; Library.OldSize = Window.Size

            local Brand = Instance.new("TextLabel")
            Brand.Name = "SodaBrand"; Brand.FontFace = Library.FontFace
            Brand.Text = "Soda.Fun"; Brand.BackgroundTransparency = 1; Brand.BorderSizePixel = 0
            Brand.Position = UDim2.fromOffset(10, 14); Brand.Size = UDim2.new(0, 130, 0, 22)
            Brand.TextSize = 18; Brand.TextXAlignment = Enum.TextXAlignment.Left; Brand.ZIndex = 55; Brand.Parent = Inline
            Library:ApplyTextTheme(Brand, 0)

            Inline.Name = "Inline"; Inline.Position = UDim2.new(0, 1, 0, 1)
            Inline.Size = UDim2.new(1, -2, 1, -2); Inline.BackgroundColor3 = Color3.new(0.051, 0.051, 0.051)
            Inline.BorderSizePixel = 0; Inline.ZIndex = 51

            Holder.Name = "Holder"; Holder.Position = UDim2.new(0, 150, 0, 0)
            Holder.Size = UDim2.new(1, -150, 1, 0); Holder.BackgroundColor3 = Color3.new(0.0588235, 0.0588235, 0.0588235)
            Holder.BorderSizePixel = 0; Holder.ZIndex = 52

            Frame.Size = UDim2.new(0, 5, 1, 0); Frame.BackgroundColor3 = Color3.new(0.0588235, 0.0588235, 0.0588235); Frame.BorderSizePixel = 0

            Tabs.Name = "Tabs"; Tabs.Position = UDim2.new(0, 5, 0, 50)
            Tabs.Size = UDim2.new(0, 140, 1, -60); Tabs.BackgroundTransparency = 1; Tabs.BorderSizePixel = 0
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder; UIListLayout.Padding = UDim.new(0, 4)

            TextButton.Size = UDim2.new(1, 0, 0, 20); TextButton.BackgroundTransparency = 1
            TextButton.BorderSizePixel = 0; TextButton.Text = ""; TextButton.AutoButtonColor = false; TextButton.ZIndex = 100

            local Line1 = Instance.new("Frame"); Line1.BackgroundColor3 = Color3.fromRGB(50, 50, 50); Line1.BorderSizePixel = 0
            Line1.Position = UDim2.fromOffset(0, 50); Line1.Size = UDim2.new(1, 0, 0, 1); Line1.Parent = Holder

            local Line2 = Instance.new("Frame"); Line2.BackgroundColor3 = Color3.fromRGB(50, 50, 50); Line2.BorderSizePixel = 0
            Line2.Size = UDim2.new(0, 1, 1, 0); Line2.Parent = Holder

            local FadeThing = Instance.new("Frame"); FadeThing.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            FadeThing.BorderSizePixel = 0; FadeThing.Position = UDim2.fromOffset(9, 59)
            FadeThing.Size = UDim2.new(1, -18, 1, -63); FadeThing.ZIndex = 55; FadeThing.Parent = Holder; FadeThing.Visible = false

            Window.Elements = {TabHolder = Tabs, Holder = Holder, FadeThing = FadeThing}

            Library:Connection(TextButton.InputBegan, function(input)
                if isPressInput(input) then
                    local Location = UIS:GetMouseLocation()
                    Window.Dragging[1] = true
                    Window.Dragging[2] = UDim2.new(0, Location.X - Outline.AbsolutePosition.X, 0, Location.Y - Outline.AbsolutePosition.Y)
                end
            end)
            Library:Connection(UIS.InputEnded, function(Input)
                if isPressInput(Input) then Window.Dragging[1] = false end
            end)
            Library:Connection(UIS.InputChanged, function(Input)
                if not isMoveInput(Input) then return end
                local Location = UIS:GetMouseLocation()
                if Window.Dragging[1] then
                    TweenService:Create(Outline, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                        Position = UDim2.new(0, Location.X - Window.Dragging[2].X.Offset + (Outline.Size.X.Offset * Outline.AnchorPoint.X), 0, Location.Y - Window.Dragging[2].Y.Offset + (Outline.Size.Y.Offset * Outline.AnchorPoint.Y))
                    }):Play()
                end
            end)

            function Window:UpdateTabs()
                for _, Page in pairs(Window.Pages) do Page:Turn(Page.Open) end
            end

            Library:Connection(UIS.InputBegan, function(Inp)
                if Inp.KeyCode == Library.UIKey then Library:SetOpen(not Library.Open) end
            end)

            TweenService:Create(Library.Holder, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, Window.Size.X.Offset, 0, Window.Size.Y.Offset)}):Play()
            Library.Holder = Outline
            return setmetatable(Window, Library)
        end

        function Library:Seperator(Properties)
            if not Properties then Properties = {} end
            local Page = {Name = Properties.Name or "Page", Window = self, Elements = {}}
            local TextSep = Instance.new('Frame', Page.Window.Elements.TabHolder)
            local TextLabel = Instance.new('TextLabel', TextSep)
            TextSep.Size = UDim2.new(1, 0, 0, 20); TextSep.BackgroundTransparency = 1; TextSep.BorderSizePixel = 0
            TextLabel.Position = UDim2.new(0, 8, 0, 0); TextLabel.Size = UDim2.new(1, -10, 1, 0)
            TextLabel.BackgroundTransparency = 1; TextLabel.BorderSizePixel = 0; TextLabel.Text = Page.Name
            TextLabel.TextColor3 = Color3.new(0.7059, 0.7059, 0.7059); TextLabel.FontFace = Library.FontFace
            TextLabel.TextSize = Library.FontSize; TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        end

        function Library:Page(Properties)
            if not Properties then Properties = {} end
            local Page = {Name = Properties.Name or "Page", Icon = Properties.Icon or "http://www.roblox.com/asset/?id=6022668955", Window = self, Open = false, Sections = {}, Elements = {}}

            local TabButton = Instance.new('TextButton', Page.Window.Elements.TabHolder)
            local Accent = Instance.new('Frame', TabButton)
            local Title = Instance.new('TextLabel', TabButton)
            local Icon = Instance.new('ImageLabel', TabButton)
            local NewPage = Instance.new('Frame', Page.Window.Elements.Holder)
            local Left = Instance.new('Frame', NewPage)
            local LeftLayout = Instance.new('UIListLayout', Left)
            local Right = Instance.new('Frame', NewPage)
            local RightLayout = Instance.new('UIListLayout', Right)

            TabButton.Size = UDim2.new(1, 0, 0, 30); TabButton.BackgroundColor3 = Color3.new(0.0784, 0.0784, 0.0784)
            TabButton.BorderSizePixel = 0; TabButton.BackgroundTransparency = 1; TabButton.Text = ""
            TabButton.AutoButtonColor = false; TabButton.ClipsDescendants = true
            local UICorner_3 = Instance.new('UICorner', TabButton)

            Accent.Position = UDim2.new(0, -8, 0, 5); Accent.Size = UDim2.new(0, 10, 1, -10)
            Accent.BorderSizePixel = 0; Accent.BackgroundTransparency = 0
            local UICorner = Instance.new('UICorner', Accent)
            Library:ApplyTheme(Accent, 90)

            Title.Position = UDim2.new(0, 35, 0, 0); Title.Size = UDim2.new(1, -10, 1, 0)
            Title.BackgroundTransparency = 1; Title.BorderSizePixel = 0; Title.Text = Page.Name
            Title.TextColor3 = Color3.fromRGB(120, 120, 120); Title.FontFace = Library.FontFace
            Title.TextSize = Library.FontSize; Title.TextXAlignment = Enum.TextXAlignment.Left

            Icon.Position = UDim2.new(0, 11, 0, 8); Icon.Size = UDim2.new(0, 15, 0, 15)
            Icon.BackgroundTransparency = 1; Icon.BorderSizePixel = 0; Icon.Image = Page.Icon; Icon.ImageColor3 = Color3.fromRGB(120, 120, 120)

            NewPage.Position = UDim2.new(0, 10, 0, 60); NewPage.Size = UDim2.new(1, -20, 1, -65)
            NewPage.BackgroundTransparency = 1; NewPage.BorderSizePixel = 0; NewPage.ZIndex = 53; NewPage.Visible = false

            Left.Size = UDim2.new(0.5, -4, 1, 0); Left.BackgroundTransparency = 1; Left.ZIndex = 54
            LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder; LeftLayout.Padding = UDim.new(0, 8)
            Right.Position = UDim2.new(0.5, 4, 0, 0); Right.Size = UDim2.new(0.5, -4, 1, 0)
            Right.BackgroundTransparency = 1; Right.ZIndex = 53; RightLayout.SortOrder = Enum.SortOrder.LayoutOrder; RightLayout.Padding = UDim.new(0, 8)

            function Page:Turn(bool)
                Page.Open = bool
                task.spawn(function()
                    Page.Window.Elements.FadeThing.Visible = true
                    TweenService:Create(Page.Window.Elements.FadeThing, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play()
                    task.wait(0.1); NewPage.Visible = Page.Open
                    TweenService:Create(Page.Window.Elements.FadeThing, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play()
                    task.wait(0.1); Page.Window.Elements.FadeThing.Visible = false
                end)
                TweenService:Create(TabButton, TweenInfo.new(0.1), {BackgroundTransparency = Page.Open and 0 or 1}):Play()
                TweenService:Create(Title, TweenInfo.new(0.1), {TextColor3 = Page.Open and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(120, 120, 120)}):Play()
                TweenService:Create(Icon, TweenInfo.new(0.1), {ImageColor3 = Page.Open and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(120, 120, 120)}):Play()
                TweenService:Create(Accent, TweenInfo.new(0.1), {BackgroundTransparency = Page.Open and 0 or 1}):Play()
            end

            Library:Connection(TabButton.MouseButton1Click, function()
                if not Page.Open then
                    Page:Turn(true)
                    for _, Pages in pairs(Page.Window.Pages) do if Pages.Open and Pages ~= Page then Pages:Turn(false) end end
                end
            end)
            Library:Connection(TabButton.MouseEnter, function()
                if not Page.Open then
                    TweenService:Create(Title, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
                    TweenService:Create(Icon, TweenInfo.new(0.1), {ImageColor3 = Color3.fromRGB(180, 180, 180)}):Play()
                end
            end)
            Library:Connection(TabButton.MouseLeave, function()
                if not Page.Open then
                    TweenService:Create(Title, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(120, 120, 120)}):Play()
                    TweenService:Create(Icon, TweenInfo.new(0.1), {ImageColor3 = Color3.fromRGB(120, 120, 120)}):Play()
                end
            end)

            Page.Elements = {Left = Left, Right = Right, TabButton = TabButton}
            if #Page.Window.Pages == 0 then Page:Turn(true) end
            Page.Window.Pages[#Page.Window.Pages + 1] = Page
            Page.Window:UpdateTabs()
            return setmetatable(Page, Library.Pages)
        end

        function Pages:Section(Properties)
            if not Properties then Properties = {} end
            local Section = {Name = Properties.Name or "Section", Page = self, Side = (Properties.side or Properties.Side or "left"):lower(), Size = Properties.size or Properties.Size or 200, Elements = {}, Content = {}}

            local NewSection = Instance.new('Frame', Section.Side == "left" and Section.Page.Elements.Left or Section.Page.Elements.Right)
            local UIStroke = Instance.new('UIStroke', NewSection)
            local UICorner = Instance.new('UICorner', NewSection)
            local Frame = Instance.new('Frame', NewSection)
            local Title = Instance.new('TextLabel', NewSection)
            local Content = Instance.new('Frame', NewSection)
            local UIListLayout = Instance.new('UIListLayout', Content)

            NewSection.Size = Section.Size == "Fill" and UDim2.new(1, 0, 1, 0) or UDim2.new(1, 0, 0, Section.Size)
            NewSection.BackgroundColor3 = Color3.new(0.0784314, 0.0784314, 0.0784314)
            NewSection.BorderSizePixel = 0; NewSection.ZIndex = 53
            UIStroke.Color = Color3.new(0.137255, 0.137255, 0.137255)

            Frame.Position = UDim2.new(0, 0, 0, 20); Frame.Size = UDim2.new(1, 0, 0, 1)
            Frame.BackgroundColor3 = Color3.new(0.1569, 0.1569, 0.1569); Frame.BorderSizePixel = 0

            Title.Position = UDim2.new(0, 8, 0, 1); Title.Size = UDim2.new(1, -10, 0, 20)
            Title.BackgroundTransparency = 1; Title.BorderSizePixel = 0; Title.Text = Section.Name
            Title.TextColor3 = Color3.new(0.7059, 0.7059, 0.7059); Title.FontFace = Library.FontFace
            Title.TextSize = Library.FontSize; Title.TextXAlignment = Enum.TextXAlignment.Left

            Content.Position = UDim2.new(0, 10, 0, 30); Content.Size = UDim2.new(1, -20, 1, -40)
            Content.BackgroundTransparency = 1; Content.BorderSizePixel = 0; Content.ZIndex = 53
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder; UIListLayout.Padding = UDim.new(0, 8)

            Section.Elements = {SectionContent = Content}
            Section.Page.Sections[#Section.Page.Sections + 1] = Section
            return setmetatable(Section, Library.Sections)
        end

        function Sections:Nest(Properties)
            if not Properties then Properties = {} end
            local Section = {Name = Properties.Name or "Section", RealSection = self, Size = Properties.size or Properties.Size or 200, Elements = {}, Content = {}}
            local ScrollHolder = Instance.new("Frame", Section.RealSection.Elements.SectionContent)
            local NewScroll = Instance.new('ScrollingFrame', ScrollHolder)
            local ScrollContent = Instance.new('Frame', NewScroll)
            local UIListLayout = Instance.new('UIListLayout', ScrollContent)

            ScrollHolder.Size = Section.Size == "Fill" and UDim2.new(1, 0, 1, 0) or UDim2.new(1, 0, 0, Section.Size)
            ScrollHolder.BackgroundTransparency = 1; ScrollHolder.BorderSizePixel = 0; ScrollHolder.ClipsDescendants = true
            local UICorner2 = Instance.new('UICorner', ScrollHolder)

            NewScroll.Size = UDim2.new(1, 0, 1, 0); NewScroll.BackgroundTransparency = 1; NewScroll.BorderSizePixel = 0
            NewScroll.CanvasSize = UDim2.new(0, 0, 0, 0); NewScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            NewScroll.ScrollBarThickness = 4; NewScroll.ScrollBarImageColor3 = Library.Accent
            NewScroll.TopImage = ""; NewScroll.BottomImage = ""
            NewScroll.VerticalScrollBarInset = Enum.ScrollBarInset.Always; NewScroll.ClipsDescendants = true
            table.insert(Library.ThemeObjects, NewScroll)

            ScrollContent.Position = UDim2.new(0, 6, 0, 5); ScrollContent.Size = UDim2.new(1, -12, 0, 0)
            ScrollContent.BackgroundTransparency = 1; ScrollContent.AutomaticSize = Enum.AutomaticSize.Y
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder; UIListLayout.Padding = UDim.new(0, 6)

            Section.Elements = {SectionContent = ScrollContent}
            return setmetatable(Section, Library.Sections)
        end

        -- Toggle
        function Sections:Toggle(Properties)
            if not Properties then Properties = {} end
            local Toggle = {
                Window = self.Window, Page = self.Page, Section = self,
                Name = Properties.Name or "Toggle",
                State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or false),
                Callback = (Properties.callback or Properties.Callback or function() end),
                Flag = (Properties.flag or Properties.Flag or Library.NextFlag()),
                Toggled = false,
            }
            local NewToggle = Instance.new('TextButton', Toggle.Section.Elements.SectionContent)
            NewToggle.LayoutOrder = Properties.LayoutOrder or 0
            local ToggleTitle = Instance.new('TextLabel', NewToggle)
            local ToggleFrame = Instance.new('Frame', NewToggle)
            local ToggleAccent = Instance.new('Frame', ToggleFrame)
            local Circle = Instance.new('Frame', ToggleFrame)

            NewToggle.Size = UDim2.new(1, 0, 0, 17); NewToggle.BackgroundTransparency = 1
            NewToggle.BorderSizePixel = 0; NewToggle.Text = ""; NewToggle.AutoButtonColor = false; NewToggle.ZIndex = 53
            local UICorner_2 = Instance.new('UICorner', ToggleFrame)

            ToggleTitle.Size = UDim2.new(1, -10, 0, 17); ToggleTitle.BackgroundTransparency = 1
            ToggleTitle.BorderSizePixel = 0; ToggleTitle.Text = Toggle.Name
            ToggleTitle.TextColor3 = Color3.new(0.7843, 0.7843, 0.7843); ToggleTitle.FontFace = Library.FontFace
            ToggleTitle.TextSize = Library.FontSize; ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left

            ToggleFrame.Position = UDim2.new(1, -40, 0, 0); ToggleFrame.Size = UDim2.new(0, 40, 1, 0)
            ToggleFrame.BackgroundColor3 = Color3.new(0.051, 0.051, 0.051); ToggleFrame.BorderSizePixel = 0; ToggleFrame.ZIndex = 53

            ToggleAccent.Position = UDim2.new(0, 1, 0, 1); ToggleAccent.Size = UDim2.new(1, -2, 1, -2)
            ToggleAccent.BackgroundTransparency = 1; ToggleAccent.BorderSizePixel = 0; ToggleAccent.ZIndex = 53
            local UICorner_3 = Instance.new('UICorner', ToggleAccent)
            Library:ApplyTheme(ToggleAccent, 0)

            Circle.Position = UDim2.new(0, 5, 0.5, -5); Circle.Size = UDim2.new(0, 10, 0, 10)
            Circle.BackgroundColor3 = Color3.new(1, 1, 1); Circle.BorderSizePixel = 0; Circle.ZIndex = 53
            local UICorner_4 = Instance.new('UICorner', Circle); UICorner_4.CornerRadius = UDim.new(1, 0)

            local function SetState()
                Toggle.Toggled = not Toggle.Toggled
                if Toggle.Toggled then
                    TweenService:Create(ToggleAccent, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()
                    TweenService:Create(Circle, TweenInfo.new(0.25), {Position = UDim2.new(1, -15, 0.5, -5)}):Play()
                else
                    TweenService:Create(ToggleAccent, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
                    TweenService:Create(Circle, TweenInfo.new(0.25), {Position = UDim2.new(0, 5, 0.5, -5)}):Play()
                end
                Library.Flags[Toggle.Flag] = Toggle.Toggled
                Toggle.Callback(Toggle.Toggled)
            end

            function Toggle.Set(bool)
                bool = type(bool) == "boolean" and bool or false
                if Toggle.Toggled ~= bool then SetState() end
            end
            Toggle.Set(Toggle.State); Library.Flags[Toggle.Flag] = Toggle.State; Flags[Toggle.Flag] = Toggle.Set
            Library:Connection(NewToggle.MouseButton1Click, SetState)
            return Toggle
        end

        -- Slider (with touch support)
        function Sections:Slider(Properties)
            if not Properties then Properties = {} end
            local Slider = {
                Window = self.Window, Page = self.Page, Section = self,
                Name = Properties.Name or "Slider",
                Min = (Properties.min or Properties.Min or Properties.minimum or Properties.Minimum or 0),
                State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or 10),
                Max = (Properties.max or Properties.Max or Properties.maximum or Properties.Maximum or 100),
                Sub = (Properties.suffix or Properties.Suffix or Properties.ending or Properties.Ending or Properties.prefix or Properties.Prefix or Properties.measurement or Properties.Measurement or ""),
                Decimals = (Properties.decimals or Properties.Decimals or 1),
                Callback = (Properties.callback or Properties.Callback or function() end),
                Flag = (Properties.flag or Properties.Flag or Library.NextFlag()),
            }
            local TextValue = ("[value]" .. Slider.Sub)

            local NewSlider = Instance.new('TextButton', Slider.Section.Elements.SectionContent)
            NewSlider.LayoutOrder = Properties.LayoutOrder or 0
            local SliderTitle = Instance.new('TextLabel', NewSlider)
            local ToggleFrame = Instance.new('Frame', NewSlider)
            local FillHold = Instance.new('Frame', ToggleFrame)
            local Fill = Instance.new('TextButton', FillHold)
            local Circle = Instance.new('Frame', Fill)
            local SliderValue = Instance.new('TextLabel', NewSlider)

            NewSlider.Size = UDim2.new(1, 0, 0, 32); NewSlider.BackgroundTransparency = 1
            NewSlider.BorderSizePixel = 0; NewSlider.Text = ""; NewSlider.AutoButtonColor = false; NewSlider.ZIndex = 53
            local UICorner_2 = Instance.new('UICorner', ToggleFrame)

            SliderTitle.Size = UDim2.new(1, -10, 0, 17); SliderTitle.BackgroundTransparency = 1
            SliderTitle.Text = Slider.Name; SliderTitle.TextColor3 = Color3.new(0.7843, 0.7843, 0.7843)
            SliderTitle.FontFace = Library.FontFace; SliderTitle.TextSize = Library.FontSize; SliderTitle.TextXAlignment = Enum.TextXAlignment.Left

            ToggleFrame.Position = UDim2.new(0, 0, 1, -8); ToggleFrame.Size = UDim2.new(1, 0, 0, 8)
            ToggleFrame.BackgroundColor3 = Color3.new(0.051, 0.051, 0.051); ToggleFrame.BorderSizePixel = 0; ToggleFrame.ZIndex = 53

            FillHold.Position = UDim2.new(0, 1, 0, 1); FillHold.Size = UDim2.new(1, -2, 1, -2)
            FillHold.BackgroundColor3 = Color3.new(0.6667, 0.6667, 1); FillHold.BackgroundTransparency = 1; FillHold.BorderSizePixel = 0; FillHold.ZIndex = 53

            Fill.Size = UDim2.new(0, 0, 1, 0); Fill.BorderSizePixel = 0; Fill.Text = ""; Fill.AutoButtonColor = false; Fill.ZIndex = 53
            Library:ApplyTheme(Fill, 0)

            Circle.Position = UDim2.new(1, -6, 0.5, -6); Circle.Size = UDim2.new(0, 13, 0, 13)
            Circle.BackgroundColor3 = Color3.new(1, 1, 1); Circle.BorderSizePixel = 0; Circle.ZIndex = 53
            local UICorner_5 = Instance.new('UICorner', Circle); UICorner_5.CornerRadius = UDim.new(1, 0)

            SliderValue.Size = UDim2.new(1, 0, 0, 17); SliderValue.BackgroundTransparency = 1
            SliderValue.Text = ""; SliderValue.TextColor3 = Color3.new(0.4706, 0.4706, 0.4706)
            SliderValue.FontFace = Library.FontFace; SliderValue.TextSize = Library.FontSize; SliderValue.TextXAlignment = Enum.TextXAlignment.Right

            local Sliding = false
            local function Set(value)
                value = tonumber(value) or Slider.Min
                value = math.clamp(Library:Round(value, Slider.Decimals), Slider.Min, Slider.Max)
                local sizeX = ((value - Slider.Min) / (Slider.Max - Slider.Min))
                TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(sizeX, 0, 1, 0)}):Play()
                SliderValue.Text = TextValue:gsub("%[value%]", string.format("%.14g", value))
                Library.Flags[Slider.Flag] = value; Slider.Callback(value)
            end
            local function Slide()
                local mousePos = UIS:GetMouseLocation()
                local sizeX = (mousePos.X - NewSlider.AbsolutePosition.X) / NewSlider.AbsoluteSize.X
                Set(((Slider.Max - Slider.Min) * sizeX) + Slider.Min)
            end

            Library:Connection(NewSlider.InputBegan, function(input) if isPressInput(input) then Sliding = true; Slide() end end)
            Library:Connection(NewSlider.InputEnded, function(input) if isPressInput(input) then Sliding = false end end)
            Library:Connection(Fill.InputBegan, function(input) if isPressInput(input) then Sliding = true; Slide() end end)
            Library:Connection(Fill.InputEnded, function(input) if isPressInput(input) then Sliding = false end end)
            Library:Connection(UIS.InputChanged, function(input)
                if isMoveInput(input) and Sliding then Slide() end
            end)
            Library:Connection(UIS.InputEnded, function(input)
                if isPressInput(input) then Sliding = false end
            end)

            function Slider:Set(Value) Set(Value) end
            Flags[Slider.Flag] = Set; Library.Flags[Slider.Flag] = Slider.State; Set(Slider.State)
            return Slider
        end

        -- Textbox
        function Sections:Textbox(Properties)
            Properties = Properties or {}
            local Textbox = {
                Window = self.Window, Page = self.Page, Section = self,
                Placeholder = (Properties.placeholder or Properties.Placeholder or Properties.holder or "Enter your text here"),
                State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or ""),
                Callback = (Properties.callback or Properties.Callback or function() end),
                Flag = (Properties.flag or Properties.Flag or Library.NextFlag()),
            }
            local NewBox = Instance.new("Frame")
            NewBox.BackgroundTransparency = 1; NewBox.Size = UDim2.new(1, 0, 0, 24); NewBox.ZIndex = 54
            NewBox.LayoutOrder = Properties.LayoutOrder or 0
            NewBox.Parent = Textbox.Section.Elements.SectionContent

            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 13); ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Position = UDim2.new(0, 0, 1, -24); ToggleFrame.Size = UDim2.new(1, 0, 0, 24); ToggleFrame.ZIndex = 55
            local UICorner2 = Instance.new("UICorner", ToggleFrame); UICorner2.CornerRadius = UDim.new(0, 4)

            local TextBox = Instance.new("TextBox")
            TextBox.FontFace = Library.FontFace; TextBox.Text = Textbox.State
            TextBox.PlaceholderText = Textbox.Placeholder; TextBox.PlaceholderColor3 = Color3.fromRGB(145, 145, 145)
            TextBox.TextColor3 = Color3.fromRGB(200, 200, 200); TextBox.TextSize = 13
            TextBox.ClearTextOnFocus = false; TextBox.TextXAlignment = Enum.TextXAlignment.Left
            TextBox.BackgroundTransparency = 1; TextBox.Position = UDim2.fromOffset(4, 0)
            TextBox.Size = UDim2.new(1, -10, 1, 0); TextBox.ZIndex = 53
            TextBox.Parent = ToggleFrame; TextBox.TextTruncate = Enum.TextTruncate.SplitWord
            ToggleFrame.Parent = NewBox

            TextBox.FocusLost:Connect(function()
                Textbox.Callback(TextBox.Text); Library.Flags[Textbox.Flag] = TextBox.Text
            end)
            TextBox:GetPropertyChangedSignal("Text"):Connect(function()
                Library.Flags[Textbox.Flag] = TextBox.Text
            end)
            local function set(str) TextBox.Text = str; Library.Flags[Textbox.Flag] = str; Textbox.Callback(str) end
            Flags[Textbox.Flag] = set; Library.Flags[Textbox.Flag] = TextBox.Text
            return Textbox
        end

        -- Button
        function Sections:Button(Properties)
            Properties = Properties or {}
            local Button = {Window = self.Window, Page = self.Page, Section = self, Name = Properties.Name or "button", Callback = (Properties.callback or Properties.Callback or function() end)}
            local NewButton = Instance.new("TextButton")
            NewButton.LayoutOrder = Properties.LayoutOrder or 0
            NewButton.FontFace = Library.FontFace; NewButton.Text = ""; NewButton.TextSize = 14
            NewButton.AutoButtonColor = false; NewButton.BackgroundTransparency = 1
            NewButton.Size = UDim2.new(1, 0, 0, 24); NewButton.ZIndex = 54; NewButton.Parent = Button.Section.Elements.SectionContent

            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Position = UDim2.new(0, 0, 1, -24); ToggleFrame.Size = UDim2.new(1, 0, 0, 24); ToggleFrame.ZIndex = 55
            local UICorner2 = Instance.new("UICorner", ToggleFrame); UICorner2.CornerRadius = UDim.new(0, 4)

            local Label = Instance.new("TextLabel")
            Label.FontFace = Library.FontFace; Label.Text = Button.Name
            Label.TextColor3 = Color3.fromRGB(200, 200, 200); Label.TextSize = 13
            Label.BackgroundTransparency = 1; Label.Size = UDim2.fromScale(1, 1); Label.ZIndex = 53; Label.Parent = ToggleFrame
            ToggleFrame.Parent = NewButton

            Library:Connection(NewButton.MouseButton1Down, function()
                Button.Callback()
                TweenService:Create(Label, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                task.spawn(function()
                    task.wait(0.1); TweenService:Create(Label, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
                end)
            end)
        end

        -- List (dropdown)
        function Sections:List(Properties)
            Properties = Properties or {}
            local Dropdown = {
                Window = self.Window, Page = self.Page, Section = self,
                Name = Properties.Name or Properties.name,
                Options = (Properties.options or Properties.Options or {"1", "2", "3"}),
                Max = (Properties.Max or Properties.max),
                State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default),
                Callback = (Properties.callback or Properties.Callback or function() end),
                Flag = (Properties.flag or Properties.Flag or Library.NextFlag()),
                OptionInsts = {},
            }
            local NewDropdown = Instance.new('Frame', Dropdown.Section.Elements.SectionContent)
            NewDropdown.LayoutOrder = Properties.LayoutOrder or 0
            local DropdownTitle = Instance.new('TextLabel', NewDropdown)
            local ToggleFrame = Instance.new('TextButton', NewDropdown)
            local ToggleContent = Instance.new('Frame', ToggleFrame)
            local UIListLayout = Instance.new('UIListLayout', ToggleContent)
            local DropdownTitle_2 = Instance.new('TextLabel', ToggleFrame)
            local Icon = Instance.new('ImageLabel', ToggleFrame)

            NewDropdown.Size = UDim2.new(1, 0, 0, 48); NewDropdown.BackgroundTransparency = 1; NewDropdown.ZIndex = 54
            DropdownTitle.Size = UDim2.new(1, -10, 0, 17); DropdownTitle.BackgroundTransparency = 1
            DropdownTitle.Text = Dropdown.Name; DropdownTitle.TextColor3 = Color3.new(0.7843, 0.7843, 0.7843)
            DropdownTitle.FontFace = Library.FontFace; DropdownTitle.TextSize = Library.FontSize; DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left

            ToggleFrame.Position = UDim2.new(0, 0, 1, -24); ToggleFrame.Size = UDim2.new(1, 0, 0, 24)
            ToggleFrame.BackgroundColor3 = Color3.new(0.098, 0.098, 0.098); ToggleFrame.BorderSizePixel = 0
            ToggleFrame.ZIndex = 54; ToggleFrame.AutoButtonColor = false; ToggleFrame.Text = ""
            local UICorner_2 = Instance.new('UICorner', ToggleFrame); UICorner_2.CornerRadius = UDim.new(0, 4)

            ToggleContent.Position = UDim2.new(0, 0, 1, 0); ToggleContent.Size = UDim2.new(1, 0, 0, 0)
            ToggleContent.BackgroundColor3 = Color3.new(0.0706, 0.0706, 0.0706); ToggleContent.BorderSizePixel = 0
            ToggleContent.ZIndex = 54; ToggleContent.ClipsDescendants = true
            local UICorner_3 = Instance.new('UICorner', ToggleContent); UICorner_3.CornerRadius = UDim.new(0, 4)
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

            DropdownTitle_2.Position = UDim2.new(0, 4, 0, 0); DropdownTitle_2.Size = UDim2.new(1, -10, 1, 0)
            DropdownTitle_2.BackgroundTransparency = 1; DropdownTitle_2.Text = ""
            DropdownTitle_2.TextColor3 = Color3.new(0.7843, 0.7843, 0.7843); DropdownTitle_2.FontFace = Library.FontFace
            DropdownTitle_2.TextSize = Library.FontSize; DropdownTitle_2.TextXAlignment = Enum.TextXAlignment.Left

            Icon.Position = UDim2.new(1, -25, 0, 5); Icon.Size = UDim2.new(0, 20, 0, 15)
            Icon.BackgroundTransparency = 1; Icon.Image = "http://www.roblox.com/asset/?id=6034818372"
            Icon.ImageColor3 = Color3.new(0.4706, 0.4706, 0.4706); Icon.ZIndex = 54

            local Toggled = false; local Count = 0

            Library:Connection(ToggleFrame.MouseButton1Click, function()
                Toggled = not Toggled; Library.DropdownOpen = Toggled
                if Toggled then
                    NewDropdown.ZIndex = 55
                    TweenService:Create(Icon, TweenInfo.new(0.25), {Rotation = 180}):Play()
                    TweenService:Create(Icon, TweenInfo.new(0.25), {ImageColor3 = Color3.fromRGB(200, 200, 200)}):Play()
                    TweenService:Create(ToggleContent, TweenInfo.new(0.25), {Size = UDim2.new(1, 0, 0, Count * 22)}):Play()
                else
                    TweenService:Create(Icon, TweenInfo.new(0.25), {Rotation = 0}):Play()
                    TweenService:Create(Icon, TweenInfo.new(0.25), {ImageColor3 = Color3.fromRGB(120, 120, 120)}):Play()
                    TweenService:Create(ToggleContent, TweenInfo.new(0.25), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                    task.wait(0.20); NewDropdown.ZIndex = 54
                end
            end)

            Library:Connection(UIS.InputBegan, function(Input)
                if ToggleContent.Visible and isPressInput(Input) then
                    if not Library:IsMouseOverFrame(ToggleContent) and not Library:IsMouseOverFrame(ToggleFrame) and not Library.OptionListOpen then
                        Toggled = false; Library.DropdownOpen = false
                        TweenService:Create(Icon, TweenInfo.new(0.25), {ImageColor3 = Color3.fromRGB(120, 120, 120)}):Play()
                        TweenService:Create(Icon, TweenInfo.new(0.25), {Rotation = 0}):Play()
                        TweenService:Create(ToggleContent, TweenInfo.new(0.25), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                        task.wait(0.20); NewDropdown.ZIndex = 54
                    end
                end
            end)

            local Chosen = Dropdown.Max and {} or nil

            local function handleoptionclick(option, button, text, dot)
                button.MouseButton1Click:Connect(function()
                    if Dropdown.Max then
                        if table.find(Chosen, option) then
                            table.remove(Chosen, table.find(Chosen, option))
                            DropdownTitle_2.Text = #Chosen == 0 and "" or table.concat(Chosen, ", ")
                            TweenService:Create(text, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(120, 120, 120)}):Play()
                            TweenService:Create(dot, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
                            TweenService:Create(text, TweenInfo.new(0.25), {Position = UDim2.new(0, 4, 0, 0)}):Play()
                            Library.Flags[Dropdown.Flag] = Chosen; Dropdown.Callback(Chosen)
                        else
                            if #Chosen == Dropdown.Max then
                                Dropdown.OptionInsts[Chosen[1]].text.Visible = false
                                table.remove(Chosen, 1)
                            end
                            table.insert(Chosen, option)
                            DropdownTitle_2.Text = #Chosen == 0 and "" or table.concat(Chosen, ", ")
                            TweenService:Create(text, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
                            TweenService:Create(dot, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()
                            TweenService:Create(text, TweenInfo.new(0.25), {Position = UDim2.new(0, 20, 0, 0)}):Play()
                            Library.Flags[Dropdown.Flag] = Chosen; Dropdown.Callback(Chosen)
                        end
                    else
                        for opt, tbl in next, Dropdown.OptionInsts do
                            if opt ~= option then
                                TweenService:Create(tbl.text, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(120, 120, 120)}):Play()
                                TweenService:Create(tbl.text, TweenInfo.new(0.25), {Position = UDim2.new(0, 4, 0, 0)}):Play()
                                TweenService:Create(tbl.dot, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
                            end
                        end
                        Chosen = option; DropdownTitle_2.Text = option
                        TweenService:Create(text, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
                        TweenService:Create(dot, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()
                        TweenService:Create(text, TweenInfo.new(0.25), {Position = UDim2.new(0, 20, 0, 0)}):Play()
                        Library.Flags[Dropdown.Flag] = option; Dropdown.Callback(option)
                    end
                end)
            end

            local function createoptions(tbl)
                for _, option in next, tbl do
                    Dropdown.OptionInsts[option] = {}
                    local TextButton = Instance.new('TextButton', ToggleContent)
                    local DropdownTitle3 = Instance.new('TextLabel', TextButton)
                    local AccentDot = Instance.new('Frame', TextButton)
                    local OptionCorner = Instance.new('UICorner', AccentDot)

                    TextButton.Size = UDim2.new(1, 0, 0, 22); TextButton.BackgroundTransparency = 1
                    TextButton.Text = ""; TextButton.AutoButtonColor = false
                    Dropdown.OptionInsts[option].button = TextButton

                    DropdownTitle3.Position = UDim2.new(0, 20, 0, 0); DropdownTitle3.Size = UDim2.new(1, -10, 1, 0)
                    DropdownTitle3.BackgroundTransparency = 1; DropdownTitle3.Text = option
                    DropdownTitle3.TextColor3 = Color3.fromRGB(120, 120, 120); DropdownTitle3.FontFace = Library.FontFace
                    DropdownTitle3.TextSize = Library.FontSize; DropdownTitle3.TextXAlignment = Enum.TextXAlignment.Left
                    Dropdown.OptionInsts[option].text = DropdownTitle3

                    AccentDot.Position = UDim2.new(0, 8, 0, 8); AccentDot.Size = UDim2.new(0, 6, 0, 6)
                    AccentDot.BorderSizePixel = 0; Library:ApplyTheme(AccentDot, 45)
                    Dropdown.OptionInsts[option].dot = AccentDot

                    OptionCorner.CornerRadius = UDim.new(1, 0); Count += 1
                    handleoptionclick(option, TextButton, DropdownTitle3, AccentDot)
                end
            end
            createoptions(Dropdown.Options)

            local set
            set = function(option)
                if Dropdown.Max then
                    table.clear(Chosen); option = type(option) == "table" and option or {}
                    for opt, tbl in next, Dropdown.OptionInsts do
                        if not table.find(option, opt) then
                            TweenService:Create(tbl.text, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(120, 120, 120)}):Play()
                            TweenService:Create(tbl.text, TweenInfo.new(0.25), {Position = UDim2.new(0, 4, 0, 0)}):Play()
                            TweenService:Create(tbl.dot, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
                        end
                    end
                    for _, opt in next, option do
                        if table.find(Dropdown.Options, opt) and #Chosen < Dropdown.Max then
                            table.insert(Chosen, opt)
                            TweenService:Create(Dropdown.OptionInsts[opt].text, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
                            TweenService:Create(Dropdown.OptionInsts[opt].dot, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()
                            TweenService:Create(Dropdown.OptionInsts[opt].text, TweenInfo.new(0.25), {Position = UDim2.new(0, 20, 0, 0)}):Play()
                        end
                    end
                    DropdownTitle_2.Text = #Chosen == 0 and "" or table.concat(Chosen, ", ")
                    Library.Flags[Dropdown.Flag] = Chosen; Dropdown.Callback(Chosen)
                end
            end

            function Dropdown:Set(option)
                if Dropdown.Max then set(option) else
                    for opt, tbl in next, Dropdown.OptionInsts do
                        if opt ~= option then
                            TweenService:Create(tbl.text, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(120, 120, 120)}):Play()
                            TweenService:Create(tbl.text, TweenInfo.new(0.25), {Position = UDim2.new(0, 4, 0, 0)}):Play()
                            TweenService:Create(tbl.dot, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
                        end
                    end
                    if table.find(Dropdown.Options, option) then
                        Chosen = option; DropdownTitle_2.Text = option
                        TweenService:Create(Dropdown.OptionInsts[option].text, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
                        TweenService:Create(Dropdown.OptionInsts[option].dot, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()
                        TweenService:Create(Dropdown.OptionInsts[option].text, TweenInfo.new(0.25), {Position = UDim2.new(0, 20, 0, 0)}):Play()
                        Library.Flags[Dropdown.Flag] = Chosen; Dropdown.Callback(Chosen)
                    else
                        Chosen = nil; DropdownTitle_2.Text = ""; Library.Flags[Dropdown.Flag] = Chosen; Dropdown.Callback(Chosen)
                    end
                end
            end

            if Dropdown.Max then Flags[Dropdown.Flag] = set else Flags[Dropdown.Flag] = Dropdown end
            Dropdown:Set(Dropdown.State); return Dropdown
        end

        -- Watermark
        function Library:Watermark(Properties)
            local Watermark = {Name = (Properties.Name or Properties.name or "v1.0"); AnimateText = nil;}
            local Outline = Instance.new("Frame")
            Outline.AnchorPoint = Vector2.new(1, 0); Outline.AutomaticSize = Enum.AutomaticSize.X
            Outline.BackgroundColor3 = Color3.fromRGB(50, 50, 50); Outline.Position = UDim2.new(1, -10, 0, 10)
            Outline.Size = UDim2.fromOffset(100, 20); Outline.Visible = false; Outline.ZIndex = 50; Outline.Parent = Library.ScreenGUI
            local UICorner = Instance.new("UICorner", Outline); UICorner.CornerRadius = UDim.new(0, 4)
            local UIStroke = Instance.new("UIStroke", Outline)

            local Inline = Instance.new("Frame")
            Inline.BackgroundColor3 = Color3.fromRGB(13, 13, 13); Inline.BorderSizePixel = 0
            Inline.Position = UDim2.fromOffset(1, 1); Inline.Size = UDim2.new(1, -2, 1, -2); Inline.ZIndex = 51; Inline.Parent = Outline
            local UICorner2 = Instance.new("UICorner", Inline); UICorner2.CornerRadius = UDim.new(0, 4)

            local Title = Instance.new("TextLabel")
            Title.FontFace = Library.FontFace; Title.RichText = true
            Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.TextSize = 13
            Title.TextXAlignment = Enum.TextXAlignment.Left; Title.AutomaticSize = Enum.AutomaticSize.X
            Title.BackgroundTransparency = 1; Title.Position = UDim2.fromOffset(5, 0); Title.Size = UDim2.fromScale(0, 1); Title.Parent = Inline
            local UIPadding = Instance.new("UIPadding", Inline); UIPadding.PaddingRight = UDim.new(0, 6)

            local BRAND = "Soda.Fun"
            task.spawn(function()
                while task.wait() do
                    for i = 1, #BRAND do
                        Watermark.AnimateText = string.sub(BRAND, 1, i)
                        Title.Text = '<font color="rgb(255,20,80)">' .. Watermark.AnimateText .. '</font><font color="rgb(120,120,120)"> | </font><font color="rgb(60,120,255)">' .. Watermark.Name .. '</font>'
                        task.wait(0.35)
                    end
                    for i = #BRAND - 1, 1, -1 do
                        Watermark.AnimateText = string.sub(BRAND, 1, i)
                        Title.Text = '<font color="rgb(255,20,80)">' .. Watermark.AnimateText .. '</font><font color="rgb(120,120,120)"> | </font><font color="rgb(60,120,255)">' .. Watermark.Name .. '</font>'
                        task.wait(0.35)
                    end
                end
            end)

            function Watermark:UpdateText(NewText) Watermark.Name = NewText end
            function Watermark:SetVisible(State) Outline.Visible = State end
            return Watermark
        end
    end
end

--====================================================================
-- WINDOW + TABS
--====================================================================
local Soda = Library
local flags = Library.Flags

local window = Soda:New({Size = UDim2.new(0, 620, 0, 480)})
local watermark = Soda:Watermark({Name = "v1.0"})
watermark:SetVisible(true)

local ICONS = {
    Information = "rbxassetid://6031075931",
    Target      = "rbxassetid://6023426921",
    Player      = "rbxassetid://6034684930",
    FunStuff    = "rbxassetid://6031265952",
    Visual      = "rbxassetid://6022668955",
    Rage        = "rbxassetid://14760676189",
    Setting     = "rbxassetid://6031280882",
}

window:Seperator({Name = "Info"})
local tab_info = window:Page({Name = "Information", Icon = ICONS.Information})

window:Seperator({Name = "Combat"})
local tab_target = window:Page({Name = "Target", Icon = ICONS.Target})
local tab_rage   = window:Page({Name = "Rage",   Icon = ICONS.Rage})

window:Seperator({Name = "Character"})
local tab_player = window:Page({Name = "Player",    Icon = ICONS.Player})
local tab_fun    = window:Page({Name = "Fun stuff", Icon = ICONS.FunStuff})

window:Seperator({Name = "Visuals"})
local tab_visual = window:Page({Name = "Visual", Icon = ICONS.Visual})

window:Seperator({Name = "System"})
local tab_setting = window:Page({Name = "Setting", Icon = ICONS.Setting})

--====================================================================
-- INFORMATION TAB
--====================================================================
do
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local info_left = tab_info:Section({Name = "Avatar", Side = "Left", Size = "Fill"})
    local info_right = tab_info:Section({Name = "Info", Side = "Right", Size = "Fill"})

    local function addInfoRow(parent, label, value, order)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 34)
        row.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        row.BorderSizePixel = 0
        row.LayoutOrder = order or 1
        row.Parent = parent

        local rowCorner = Instance.new("UICorner", row); rowCorner.CornerRadius = UDim.new(0, 4)
        local rowStroke = Instance.new("UIStroke", row); rowStroke.Color = Color3.fromRGB(40, 40, 40); rowStroke.Thickness = 1

        local accent = Instance.new("Frame", row)
        accent.Size = UDim2.new(0, 3, 1, -8); accent.Position = UDim2.new(0, 6, 0, 4)
        accent.BorderSizePixel = 0
        local accentCorner = Instance.new("UICorner", accent); accentCorner.CornerRadius = UDim.new(1, 0)
        Soda:ApplyTheme(accent, 90)

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -20, 0, 14); title.Position = UDim2.new(0, 16, 0, 3)
        title.BackgroundTransparency = 1; title.Text = label
        title.TextColor3 = Color3.fromRGB(120, 120, 120)
        title.FontFace = Soda.FontFace; title.TextSize = 11
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = row

        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(1, -20, 0, 16); valueLabel.Position = UDim2.new(0, 16, 0, 15)
        valueLabel.BackgroundTransparency = 1; valueLabel.Text = value
        valueLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
        valueLabel.FontFace = Soda.FontFace; valueLabel.TextSize = 13
        valueLabel.TextXAlignment = Enum.TextXAlignment.Left
        valueLabel.TextTruncate = Enum.TextTruncate.AtEnd
        valueLabel.Parent = row

        return valueLabel
    end

    local avatarFrame = Instance.new("Frame")
    avatarFrame.Size = UDim2.new(1, 0, 0, 240)
    avatarFrame.BackgroundTransparency = 1
    avatarFrame.LayoutOrder = 1
    avatarFrame.Parent = info_left.Elements.SectionContent

    local headshot = Instance.new("ImageLabel")
    headshot.Size = UDim2.new(0, 170, 0, 170)
    headshot.Position = UDim2.new(0.5, 0, 0, 10)
    headshot.AnchorPoint = Vector2.new(0.5, 0)
    headshot.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    headshot.BorderSizePixel = 0
    headshot.Image = ""
    headshot.Parent = avatarFrame

    local headshotCorner = Instance.new("UICorner", headshot); headshotCorner.CornerRadius = UDim.new(0, 10)
    local headshotStroke = Instance.new("UIStroke", headshot)
    headshotStroke.Thickness = 2; headshotStroke.Color = Color3.new(1, 1, 1)
    local strokeGradient = Instance.new("UIGradient", headshotStroke)
    strokeGradient.Color = ColorSequence.new(Soda.AccentGradient[1], Soda.AccentGradient[2])
    strokeGradient.Rotation = 45

    local avatarName = Instance.new("TextLabel")
    avatarName.Size = UDim2.new(1, 0, 0, 24); avatarName.Position = UDim2.new(0, 0, 0, 188)
    avatarName.BackgroundTransparency = 1; avatarName.Text = LocalPlayer.DisplayName
    avatarName.TextColor3 = Color3.fromRGB(255, 255, 255); avatarName.FontFace = Soda.FontFace
    avatarName.TextSize = 16; avatarName.TextXAlignment = Enum.TextXAlignment.Center
    avatarName.Parent = avatarFrame
    Soda:ApplyTextTheme(avatarName, 0)

    local avatarUsername = Instance.new("TextLabel")
    avatarUsername.Size = UDim2.new(1, 0, 0, 18); avatarUsername.Position = UDim2.new(0, 0, 0, 212)
    avatarUsername.BackgroundTransparency = 1; avatarUsername.Text = "@" .. LocalPlayer.Name
    avatarUsername.TextColor3 = Color3.fromRGB(150, 150, 150); avatarUsername.FontFace = Soda.FontFace
    avatarUsername.TextSize = 12; avatarUsername.TextXAlignment = Enum.TextXAlignment.Center
    avatarUsername.Parent = avatarFrame

    addInfoRow(info_right.Elements.SectionContent, "Display Name", LocalPlayer.DisplayName, 1)
    addInfoRow(info_right.Elements.SectionContent, "Username", "@" .. LocalPlayer.Name, 2)
    addInfoRow(info_right.Elements.SectionContent, "User ID", tostring(LocalPlayer.UserId), 3)
    addInfoRow(info_right.Elements.SectionContent, "Place ID", tostring(game.PlaceId), 4)

    local gameNameOk, gameInfo = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    end)
    addInfoRow(info_right.Elements.SectionContent, "Game Name", (gameNameOk and gameInfo and gameInfo.Name) or "Unknown", 5)

    task.spawn(function()
        local ok, thumb = pcall(function()
            return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        end)
        headshot.Image = (ok and thumb) or "rbxassetid://111122112"
    end)
end

--====================================================================
-- TARGET TAB
--====================================================================
do
    local Players     = game:GetService("Players")
    local RunService  = game:GetService("RunService")
    local RS          = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer

    local kill = {
        enabled = false, mode = "Auto Flame Kill", conn = nil,
        flameBuying = false, originalCFrame = nil, spawnPos = nil,
        lastReload = 0, reloadCooldown = 0.5, lastGunNotif = 0,
        selectedMelee = "Combat", flameOffset = Vector3.new(-2, 8, 2), autoAmmo = true,
        bringEnabled = false, bringConn = nil, bringStartPos = nil, lastGrabAttempt = 0,
        _bringToggle = nil,
        autoBagEnabled = false, autoBagConn = nil, bagAlertCd = 0,
    }

    do
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then kill.spawnPos = hrp.CFrame end
        LocalPlayer.CharacterAdded:Connect(function(newChar)
            local newHrp = newChar:WaitForChild("HumanoidRootPart", 5)
            if newHrp then kill.spawnPos = newHrp.CFrame end
        end)
    end

    local function killNotify(msg) Soda:Notification(msg, 2) end
    local function clearPhysics(hrp)
        if hrp then pcall(function() sethiddenproperty(hrp, "PhysicsRepRootPart", nil) end) end
    end
    local function findPlayerByQuery(query)
        if not query or query == "" then return nil end
        local q = query:lower():gsub("^@", "")
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and (p.Name:lower() == q or p.DisplayName:lower() == q) then return p end
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and (p.Name:lower():find(q, 1, true) or p.DisplayName:lower():find(q, 1, true)) then return p end
        end
        return nil
    end

    local function flameKillTick()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if not hrp or not hum then return end
        local flame = char:FindFirstChild("[Flamethrower]") or (backpack and backpack:FindFirstChild("[Flamethrower]"))

        if kill.autoAmmo and not kill.flameBuying then
            local noFlame = not flame
            local lowAmmo = false
            if flame then
                local ammo = flame:FindFirstChild("Ammo")
                if ammo and ammo.Value <= 5 then lowAmmo = true end
            end
            if noFlame or lowAmmo then
                kill.flameBuying = true
                task.spawn(function()
                    clearPhysics(hrp)
                    local ignored = workspace:FindFirstChild("Ignored")
                    local shop = ignored and ignored:FindFirstChild("Shop")
                    local flameShop = shop and shop:FindFirstChild("[Flamethrower] - $10130")
                    local ammoShop = shop and shop:FindFirstChild("140 [Flamethrower Ammo] - $1126")
                    local oldCF = hrp.CFrame
                    if noFlame and flameShop then
                        hrp.CFrame = flameShop:GetPivot() + Vector3.new(0, 3, 0)
                        task.wait(0.3)
                        local cd = flameShop:FindFirstChildWhichIsA("ClickDetector", true)
                        if cd then fireclickdetector(cd); task.wait(0.25) end
                    end
                    if kill.enabled and kill.autoAmmo and ammoShop then
                        hrp.CFrame = ammoShop:GetPivot() + Vector3.new(0, 3, 0)
                        task.wait(0.3)
                        local cd = ammoShop:FindFirstChildWhichIsA("ClickDetector", true)
                        if cd then
                            for _ = 1, 10 do
                                if not kill.enabled then break end
                                fireclickdetector(cd); task.wait(0.15)
                            end
                        end
                    end
                    task.wait(0.15)
                    if hrp and kill.enabled then
                        hrp.CFrame = oldCF
                        task.wait(0.1)
                        local c = LocalPlayer.Character
                        local h = c and c:FindFirstChildOfClass("Humanoid")
                        local f = c and (c:FindFirstChild("[Flamethrower]") or (backpack and backpack:FindFirstChild("[Flamethrower]")))
                        if h and f and f.Parent == backpack then h:EquipTool(f) end
                    end
                    kill.flameBuying = false
                end)
                return
            end
        end

        local found = findPlayerByQuery(flags["target_player_input"] or "")
        if not found then clearPhysics(hrp); if kill.spawnPos then hrp.CFrame = kill.spawnPos end; return end

        hum.PlatformStand = true
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)

        local tChar = found.Character
        local tHrp = tChar and tChar:FindFirstChild("HumanoidRootPart")
        local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
        local tTorso = tChar and (tChar:FindFirstChild("UpperTorso") or tChar:FindFirstChild("Torso") or tHrp)
        if not tHrp or not tHum then clearPhysics(hrp); if kill.spawnPos then hrp.CFrame = kill.spawnPos end; return end

        local pos = tHrp.Position
        if math.abs(pos.X) > 1e10 or math.abs(pos.Y) > 1e10 or math.abs(pos.Z) > 1e10 then
            clearPhysics(hrp); if kill.spawnPos then hrp.CFrame = kill.spawnPos end
            hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero
            return
        end

        local body = tChar:FindFirstChild("BodyEffects")
        local sdeath = body and body:FindFirstChild("SDeath") and body.SDeath.Value == true
        local dead = body and body:FindFirstChild("Dead") and body.Dead.Value == true
        local isDead = tHum.Health <= 0 or sdeath or dead
        local isKO = body and ((body:FindFirstChild("K.O") and body["K.O"].Value == true) or (body:FindFirstChild("KO") and body.KO.Value == true))

        if isDead or tChar:FindFirstChildOfClass("ForceField") then
            clearPhysics(hrp); if kill.spawnPos then hrp.CFrame = kill.spawnPos end
            hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero
            if flame and flame.Parent == char then flame:Deactivate() end
            return
        end

        if isKO then
            clearPhysics(hrp)
            if flame and flame.Parent == char then hum:UnequipTools() end
            hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.CFrame = CFrame.new(tTorso.Position + Vector3.new(0, 2.9, 0)) * CFrame.Angles(0, math.rad(tick() * 180), 0)
            RS.MainEvent:FireServer("Stomp")
            return
        end

        if not flame then
            clearPhysics(hrp); if kill.spawnPos then hrp.CFrame = kill.spawnPos end
            if tick() - kill.lastGunNotif > 4 then killNotify("Need a flamethrower!"); kill.lastGunNotif = tick() end
            return
        end

        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") and child.Name ~= "[Flamethrower]" then child.Parent = backpack end
        end

        local aiming = false
        for _, track in pairs(hum:GetPlayingAnimationTracks()) do
            if track.Name == "LeftAim" then aiming = true else pcall(function() track:Stop() end) end
        end
        if not aiming then
            pcall(function()
                local anim = RS:FindFirstChild("IM") and RS.IM:FindFirstChild("ANIM") and RS.IM.ANIM:FindFirstChild("LeftAim")
                if anim then local loaded = hum:LoadAnimation(anim); if loaded then loaded:Play() end end
            end)
        end

        if char ~= flame.Parent then hum:EquipTool(flame) end
        pcall(function() sethiddenproperty(hrp, "PhysicsRepRootPart", tHrp) end)
        hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(tTorso.Position + kill.flameOffset)

        if char == flame.Parent then
            flame:Activate()
            local ammo = flame:FindFirstChild("Ammo")
            if ammo and ammo.Value <= 0 and tick() - kill.lastReload > kill.reloadCooldown then
                kill.lastReload = tick()
                RS.MainEvent:FireServer("Reload", flame)
            end
        end
    end

    local function meleeKillTick()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if not hrp or not hum then return end

        local found = findPlayerByQuery(flags["target_player_input"] or "")
        if not found then clearPhysics(hrp); if kill.spawnPos then hrp.CFrame = kill.spawnPos end; return end

        local tChar = found.Character
        local tHrp = tChar and tChar:FindFirstChild("HumanoidRootPart")
        local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
        if not tHrp or not tHum then clearPhysics(hrp); if kill.spawnPos then hrp.CFrame = kill.spawnPos end; return end

        local body = tChar:FindFirstChild("BodyEffects")
        local sdeath = body and body:FindFirstChild("SDeath") and body.SDeath.Value == true
        local isDead = tHum.Health <= 0 or sdeath
        local isKO = body and ((body:FindFirstChild("K.O") and body["K.O"].Value == true) or (body:FindFirstChild("KO") and body.KO.Value == true))
        local ff = tChar:FindFirstChildOfClass("ForceField")

        if isDead then clearPhysics(hrp); if kill.spawnPos then hrp.CFrame = kill.spawnPos end; hrp.AssemblyLinearVelocity = Vector3.zero; return end

        local melee = char:FindFirstChild(kill.selectedMelee) or (backpack and backpack:FindFirstChild(kill.selectedMelee))
        if not melee then
            clearPhysics(hrp)
            if tick() - kill.lastGunNotif > 4 then killNotify("Need melee: " .. kill.selectedMelee); kill.lastGunNotif = tick() end
            return
        end

        if isKO and not sdeath then
            local torso = tChar:FindFirstChild("UpperTorso") or tChar:FindFirstChild("LowerTorso") or tHrp
            pcall(function() sethiddenproperty(hrp, "PhysicsRepRootPart", torso) end)
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.CFrame = CFrame.new(torso.Position) * CFrame.Angles(0, math.rad(tick() * 360), 0)
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then tool.Parent = backpack end
            RS.MainEvent:FireServer("Stomp")
            return
        end

        if ff then clearPhysics(hrp); if kill.spawnPos then hrp.CFrame = kill.spawnPos end; hrp.AssemblyLinearVelocity = Vector3.zero; return end

        if backpack then
            local m = backpack:FindFirstChild(kill.selectedMelee)
            if m then m.Parent = char end
        end

        local equipped = char:FindFirstChild(kill.selectedMelee)
        if equipped then
            pcall(function() sethiddenproperty(hrp, "PhysicsRepRootPart", tHrp) end)
            local look = Vector3.new(tHrp.Position.X, hrp.Position.Y, tHrp.Position.Z)
            hrp.CFrame = CFrame.lookAt(tHrp.Position + Vector3.new(0, -2.5, 0), look)
            hrp.AssemblyLinearVelocity = Vector3.zero
            equipped:Activate()
        end
    end

    local function bringTick()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if not hrp or not hum then return end

        local found = findPlayerByQuery(flags["target_player_input"] or "")
        if not found then clearPhysics(hrp); return end

        local tChar = found.Character
        local tHrp = tChar and tChar:FindFirstChild("HumanoidRootPart")
        local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
        if not tHrp or not tHum then clearPhysics(hrp); return end

        if tChar:FindFirstChild("GRABBING_CONSTRAINT") or char:FindFirstChild("GRABBING_CONSTRAINT") then
            clearPhysics(hrp)
            if kill.bringStartPos then hrp.CFrame = kill.bringStartPos end
            hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero
            kill.bringEnabled = false
            if kill.bringConn then kill.bringConn:Disconnect(); kill.bringConn = nil end
            killNotify("Target brought!")
            if kill._bringToggle then kill._bringToggle:Set(false) end
            return
        end

        local body = tChar:FindFirstChild("BodyEffects")
        local sdeath = body and body:FindFirstChild("SDeath") and body.SDeath.Value == true
        local isKO = body and ((body:FindFirstChild("K.O") and body["K.O"].Value == true) or (body:FindFirstChild("KO") and body.KO.Value == true))
        local isDead = tHum.Health <= 0 or sdeath
        local ff = tChar:FindFirstChildOfClass("ForceField")

        if isDead then clearPhysics(hrp); return end
        if ff then
            clearPhysics(hrp); if kill.bringStartPos then hrp.CFrame = kill.bringStartPos end
            hrp.AssemblyLinearVelocity = Vector3.zero; return
        end
        if not isKO then
            if kill.mode == "Auto Flame Kill" then flameKillTick() else meleeKillTick() end
            return
        end

        local torso = tChar:FindFirstChild("UpperTorso") or tChar:FindFirstChild("LowerTorso") or tHrp
        pcall(function() sethiddenproperty(hrp, "PhysicsRepRootPart", torso) end)
        hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(torso.Position + Vector3.new(0, 2, 0))
        if backpack then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then tool.Parent = backpack end
        end
        if tick() - kill.lastGrabAttempt >= 0.3 then
            kill.lastGrabAttempt = tick()
            RS.MainEvent:FireServer("Grabbing", false)
        end
    end

    local function autoBagTick()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if not hrp then return end

        local found = findPlayerByQuery(flags["target_player_input"] or "")
        if not found then return end

        local tChar = found.Character
        local tHrp = tChar and tChar:FindFirstChild("HumanoidRootPart")
        if not tHrp then return end

        local myBag = char:FindFirstChild("[BrownBag]") or (backpack and backpack:FindFirstChild("[BrownBag]"))
        if not myBag then
            clearPhysics(hrp)
            if tick() - kill.lastGunNotif > 4 then killNotify("Need a [BrownBag]!"); kill.lastGunNotif = tick() end
            return
        end

        if not tChar:FindFirstChild("Christmas_Sock") then
            pcall(function() sethiddenproperty(hrp, "PhysicsRepRootPart", tHrp) end)
            if backpack then
                local bagInBackpack = backpack:FindFirstChild("[BrownBag]")
                if bagInBackpack then bagInBackpack.Parent = char end
            end
            hrp.CFrame = tHrp.CFrame * CFrame.new(0, -3.5, 2.5)
            local equippedBag = char:FindFirstChild("[BrownBag]")
            if equippedBag then equippedBag:Activate() end
            return
        end

        clearPhysics(hrp)
        if hrp and kill.spawnPos then hrp.CFrame = kill.spawnPos end
        hrp.AssemblyLinearVelocity = Vector3.zero
        if tick() - kill.bagAlertCd > 4 then kill.bagAlertCd = tick(); killNotify("Bagged: " .. found.Name) end
    end

    local function stopKill()
        if kill.conn then kill.conn:Disconnect(); kill.conn = nil end
        kill.flameBuying = false
        pcall(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
                hum.PlatformStand = false
            end
            if hrp then
                sethiddenproperty(hrp, "PhysicsRepRootPart", nil)
                if kill.originalCFrame then
                    hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero
                    hrp.CFrame = kill.originalCFrame
                    kill.originalCFrame = nil
                end
            end
        end)
    end

    local function startKill()
        stopKill()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then kill.originalCFrame = hrp.CFrame end
        if kill.mode == "Auto Flame Kill" then
            kill.conn = RunService.Heartbeat:Connect(function()
                if not kill.enabled then return end
                if kill.flameBuying then return end
                flameKillTick()
            end)
        else
            kill.conn = RunService.Heartbeat:Connect(function()
                if not kill.enabled then return end
                meleeKillTick()
            end)
        end
    end

    local target_left  = tab_target:Section({Name = "Target",  Side = "Left",  Size = "Fill"})
    local target_right = tab_target:Section({Name = "Preview", Side = "Right", Size = "Fill"})

    local previewFrame = Instance.new("Frame")
    previewFrame.Size = UDim2.new(1, 0, 0, 340)
    previewFrame.BackgroundTransparency = 1
    previewFrame.LayoutOrder = 1
    previewFrame.Parent = target_right.Elements.SectionContent

    local headshot = Instance.new("ImageLabel")
    headshot.Size = UDim2.new(0, 170, 0, 170)
    headshot.Position = UDim2.new(0.5, 0, 0, 10)
    headshot.AnchorPoint = Vector2.new(0.5, 0)
    headshot.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    headshot.BorderSizePixel = 0
    headshot.Image = "rbxassetid://111122112"
    headshot.Parent = previewFrame

    local headshotCorner = Instance.new("UICorner", headshot); headshotCorner.CornerRadius = UDim.new(0, 10)
    local headshotStroke = Instance.new("UIStroke", headshot)
    headshotStroke.Thickness = 2; headshotStroke.Color = Color3.new(1, 1, 1)
    local strokeGradient = Instance.new("UIGradient", headshotStroke)
    strokeGradient.Color = ColorSequence.new(Soda.AccentGradient[1], Soda.AccentGradient[2])
    strokeGradient.Rotation = 45

    local function addTargetRow(parent, label, value, yOffset, order)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -16, 0, 34); row.Position = UDim2.new(0, 8, 0, yOffset)
        row.BackgroundColor3 = Color3.fromRGB(25, 25, 25); row.BorderSizePixel = 0
        row.LayoutOrder = order or 1
        row.Parent = parent

        local rowCorner = Instance.new("UICorner", row); rowCorner.CornerRadius = UDim.new(0, 4)
        local rowStroke = Instance.new("UIStroke", row); rowStroke.Color = Color3.fromRGB(40, 40, 40); rowStroke.Thickness = 1

        local accent = Instance.new("Frame", row)
        accent.Size = UDim2.new(0, 3, 1, -8); accent.Position = UDim2.new(0, 6, 0, 4)
        accent.BorderSizePixel = 0
        local accentCorner = Instance.new("UICorner", accent); accentCorner.CornerRadius = UDim.new(1, 0)
        Soda:ApplyTheme(accent, 90)

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -20, 0, 14); title.Position = UDim2.new(0, 16, 0, 3)
        title.BackgroundTransparency = 1; title.Text = label
        title.TextColor3 = Color3.fromRGB(120, 120, 120)
        title.FontFace = Soda.FontFace; title.TextSize = 11
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = row

        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(1, -20, 0, 16); valueLabel.Position = UDim2.new(0, 16, 0, 15)
        valueLabel.BackgroundTransparency = 1; valueLabel.Text = value
        valueLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
        valueLabel.FontFace = Soda.FontFace; valueLabel.TextSize = 13
        valueLabel.TextXAlignment = Enum.TextXAlignment.Left
        valueLabel.TextTruncate = Enum.TextTruncate.AtEnd
        valueLabel.Parent = row

        return valueLabel
    end

    local headshotName = addTargetRow(previewFrame, "Display Name", "None", 190, 2)
    local headshotUser = addTargetRow(previewFrame, "Username",     "@---", 228, 3)
    local headshotId   = addTargetRow(previewFrame, "User ID",      "---",  266, 4)

    local statusRow = Instance.new("Frame")
    statusRow.Size = UDim2.new(1, 0, 0, 24)
    statusRow.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    statusRow.BorderSizePixel = 0
    statusRow.LayoutOrder = 5
    statusRow.Parent = target_left.Elements.SectionContent
    local statusCorner = Instance.new("UICorner", statusRow); statusCorner.CornerRadius = UDim.new(0, 4)
    local statusStroke = Instance.new("UIStroke", statusRow); statusStroke.Color = Color3.fromRGB(40, 40, 40); statusStroke.Thickness = 1

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -10, 1, 0); statusLabel.Position = UDim2.new(0, 5, 0, 0)
    statusLabel.BackgroundTransparency = 1; statusLabel.Text = "Selected: None"
    statusLabel.TextColor3 = Color3.fromRGB(200, 80, 80); statusLabel.FontFace = Soda.FontFace
    statusLabel.TextSize = 12; statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = statusRow

    target_left:Textbox({
        Name = "Player",
        Flag = "target_player_input",
        Placeholder = "Partial name / @username...",
        LayoutOrder = 0,
        Callback = function(text)
            local found = findPlayerByQuery(text)
            if found then
                statusLabel.Text = "Selected: " .. found.DisplayName
                statusLabel.TextColor3 = Color3.fromRGB(80, 220, 120)
                headshotName.Text = found.DisplayName
                headshotUser.Text = "@" .. found.Name
                headshotId.Text   = tostring(found.UserId)
                task.spawn(function()
                    local ok, thumb = pcall(function()
                        return Players:GetUserThumbnailAsync(found.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
                    end)
                    if ok and thumb then headshot.Image = thumb end
                end)
            else
                statusLabel.Text = "Selected: None"
                statusLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
                headshotName.Text = "None"; headshotUser.Text = "@---"; headshotId.Text = "---"
                headshot.Image = "rbxassetid://111122112"
            end
        end
    })

    target_left:Button({
        Name = "Teleport", LayoutOrder = 10,
        Callback = function()
            local found = findPlayerByQuery(flags["target_player_input"] or "")
            if not found then Soda:Notification("No target selected!", 2); return end
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local tChar = found.Character
            local tHrp = tChar and tChar:FindFirstChild("HumanoidRootPart")
            if not hrp then Soda:Notification("Your character is missing!", 2); return end
            if not tHrp then Soda:Notification("Target has no character!", 2); return end
            hrp.CFrame = tHrp.CFrame + Vector3.new(0, 3, 0)
            Soda:Notification("Teleported to " .. found.DisplayName, 2)
        end
    })

    local spectateConn = nil
    local spectateActive = false
    target_left:Toggle({
        Name = "Spectate", Flag = "target_spectate", LayoutOrder = 20,
        Callback = function(state)
            spectateActive = state
            local cam = workspace.CurrentCamera
            if spectateConn then spectateConn:Disconnect(); spectateConn = nil end
            if state then
                spectateConn = RunService.RenderStepped:Connect(function()
                    if not spectateActive then return end
                    local found = findPlayerByQuery(flags["target_player_input"] or "")
                    if found and found.Character then
                        local hum = found.Character:FindFirstChildOfClass("Humanoid")
                        if hum then cam.CameraSubject = hum end
                    end
                end)
            else
                local myChar = LocalPlayer.Character
                if myChar then
                    local myHum = myChar:FindFirstChildOfClass("Humanoid")
                    if myHum then cam.CameraSubject = myHum end
                end
            end
        end
    })

    local flingEnabled = false
    local flingConn = nil
    local originalCFrameFling = nil
    local function setFling(enabled)
        flingEnabled = enabled
        if enabled then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then originalCFrameFling = hrp.CFrame end
            if flingConn then flingConn:Disconnect() end
            flingConn = RunService.Heartbeat:Connect(function()
                if not flingEnabled then
                    if flingConn then flingConn:Disconnect(); flingConn = nil end
                    return
                end
                local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local found = findPlayerByQuery(flags["target_player_input"] or "")
                if found and found.Character and myHrp then
                    local tHrp = found.Character:FindFirstChild("HumanoidRootPart")
                    local tHum = found.Character:FindFirstChildOfClass("Humanoid")
                    if not (tHrp and tHum and tHum.Health > 0) then
                        pcall(function() sethiddenproperty(myHrp, "PhysicsRepRootPart", nil) end)
                        return
                    end
                    myHrp.CFrame = tHrp.CFrame
                    pcall(function() sethiddenproperty(myHrp, "PhysicsRepRootPart", tHrp) end)
                    local oldVel = myHrp.AssemblyLinearVelocity
                    myHrp.AssemblyLinearVelocity = Vector3.new(99999, 99999, 99999)
                    task.wait()
                    if myHrp then myHrp.AssemblyLinearVelocity = oldVel; return end
                elseif myHrp then
                    pcall(function() sethiddenproperty(myHrp, "PhysicsRepRootPart", nil) end)
                end
            end)
            return
        end
        if flingConn then flingConn:Disconnect(); flingConn = nil end
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            pcall(function() sethiddenproperty(hrp, "PhysicsRepRootPart", nil) end)
            if originalCFrameFling then hrp.CFrame = originalCFrameFling; originalCFrameFling = nil end
            hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end
    target_left:Toggle({
        Name = "Fling", Flag = "target_fling", LayoutOrder = 90,
        Callback = function(state) setFling(state) end
    })

    target_left:Toggle({
        Name = "Auto kill", Flag = "target_auto_flame_kill", LayoutOrder = 100,
        Callback = function(state)
            kill.enabled = state
            if state then startKill(); killNotify("Auto Kill ON — " .. kill.mode)
            else stopKill(); killNotify("Auto Kill OFF") end
        end
    })

    target_left:List({
        Name = "Kill Mode", Flag = "target_kill_mode", LayoutOrder = 101,
        Options = {"Auto Flame Kill", "Melee Auto Kill"},
        Default = "Auto Flame Kill",
        Callback = function(value)
            kill.mode = value
            if kill.enabled then startKill(); killNotify("Switched to " .. value) end
        end
    })

    local bringToggle = target_left:Toggle({
        Name = "Bring", Flag = "target_bring", LayoutOrder = 102,
        Callback = function(state)
            kill.bringEnabled = state
            if state then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then kill.bringStartPos = hrp.CFrame end
                kill.lastGrabAttempt = 0
                if kill.bringConn then kill.bringConn:Disconnect() end
                kill.bringConn = RunService.Heartbeat:Connect(function()
                    if not kill.bringEnabled then return end
                    bringTick()
                end)
                killNotify("Bring ON — Mode: " .. kill.mode)
            else
                if kill.bringConn then kill.bringConn:Disconnect(); kill.bringConn = nil end
                pcall(function()
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then sethiddenproperty(hrp, "PhysicsRepRootPart", nil) end
                end)
                killNotify("Bring OFF")
            end
        end
    })
    kill._bringToggle = bringToggle

    target_left:Toggle({
        Name = "Auto Bag", Flag = "target_auto_bag", LayoutOrder = 103,
        Callback = function(state)
            kill.autoBagEnabled = state
            if state then
                if kill.autoBagConn then kill.autoBagConn:Disconnect() end
                kill.autoBagConn = RunService.Heartbeat:Connect(function()
                    if not kill.autoBagEnabled then return end
                    autoBagTick()
                end)
                killNotify("Auto Bag ON")
            else
                if kill.autoBagConn then kill.autoBagConn:Disconnect(); kill.autoBagConn = nil end
                pcall(function()
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then sethiddenproperty(hrp, "PhysicsRepRootPart", nil) end
                end)
                killNotify("Auto Bag OFF")
            end
        end
    })

    Players.PlayerRemoving:Connect(function(plr)
        local found = findPlayerByQuery(flags["target_player_input"] or "")
        if found == plr then
            headshotName.Text = "None"; headshotUser.Text = "@---"; headshotId.Text = "---"
            headshot.Image = "rbxassetid://111122112"
            statusLabel.Text = "Selected: None"
            statusLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
        end
    end)

    task.spawn(function()
        while task.wait(2) do
            local found = findPlayerByQuery(flags["target_player_input"] or "")
            if found then
                headshotName.Text = found.DisplayName
                headshotUser.Text = "@" .. found.Name
                headshotId.Text   = tostring(found.UserId)
                statusLabel.Text = "Selected: " .. found.DisplayName
            end
        end
    end)
end

--====================================================================
-- RAGE TAB — Ragebot + Hitbox + Godmode
--====================================================================
do
    local R_Players = game:GetService("Players")
    local R_RS      = game:GetService("ReplicatedStorage")
    local R_Local   = R_Players.LocalPlayer
    local R_MainEvent = R_RS:WaitForChild("MainEvent")

    local KillAura = {}
    KillAura.__index = KillAura

    local DEFAULT_CONFIG = {
        Range = 250, MaxShootDistance = 250,
        ShotsPerBurst = 5, BurstDelay = 0.02, Cooldown = 0.1,
        TargetMode = "Nearest", Ignore = {},
    }

    function KillAura.new(config)
        local self = setmetatable({}, KillAura)
        self.Config  = table.clone(DEFAULT_CONFIG)
        self.Running = false
        self._thread = nil
        if config then
            for k, v in pairs(config) do self.Config[k] = v end
        end
        return self
    end

    function KillAura:GetMyRoot()
        local char = R_Local.Character
        if not char then return nil end
        return char:FindFirstChild("HumanoidRootPart")
    end

    function KillAura:IsValidTarget(player, range)
        if player == R_Local then return false end
        if self.Config.Ignore[player] then return false end
        local character = player.Character
        if not character then return false end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return false end
        local root = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")
        if not (root and head) then return false end
        if character:FindFirstChildOfClass("ForceField") then return false end
        local myRoot = self:GetMyRoot()
        if not myRoot then return false end
        local distance = (myRoot.Position - root.Position).Magnitude
        if distance > range then return false end
        return true, {
            player = player, character = character, humanoid = humanoid,
            root = root, head = head, distance = distance,
        }
    end

    function KillAura:GetTargets()
        local targets = {}
        for _, player in ipairs(R_Players:GetPlayers()) do
            local ok, data = self:IsValidTarget(player, self.Config.Range)
            if ok then table.insert(targets, data) end
        end
        return targets
    end

    function KillAura:GetBestTarget(targets)
        if #targets == 0 then return nil end
        local mode = self.Config.TargetMode
        table.sort(targets, function(a, b)
            if mode == "LowestHealth" then return a.humanoid.Health < b.humanoid.Health
            elseif mode == "Farthest" then return a.distance > b.distance end
            return a.distance < b.distance
        end)
        return targets[1]
    end

    function KillAura:Shoot(target, tool)
        local myRoot = self:GetMyRoot()
        local handle = tool and tool:FindFirstChild("Handle")
        if not (myRoot and handle and target.head) then return end
        local distance = (myRoot.Position - target.head.Position).Magnitude
        if distance > self.Config.MaxShootDistance then return end
        for _ = 1, self.Config.ShotsPerBurst do
            if not self.Running then break end
            local humanoid = target.character and target.character:FindFirstChildOfClass("Humanoid")
            local head = target.character and target.character:FindFirstChild("Head")
            if not (humanoid and humanoid.Health > 0 and head) then break end
            pcall(function()
                R_MainEvent:FireServer("ShootGun", handle, myRoot.Position, head.Position, head, Vector3.new(0, 0, -1))
            end)
            task.wait(self.Config.BurstDelay)
        end
    end

    function KillAura:Tick()
        local character = R_Local.Character
        if not character then return end
        local tool = character:FindFirstChildOfClass("Tool")
        if not tool then return end
        local target = self:GetBestTarget(self:GetTargets())
        if not target then return end
        self:Shoot(target, tool)
    end

    function KillAura:Start()
        if self.Running then return end
        self.Running = true
        self._thread = task.spawn(function()
            while self.Running do
                pcall(function() self:Tick() end)
                task.wait(self.Config.Cooldown)
            end
        end)
    end

    function KillAura:Stop()
        self.Running = false
        self._thread = nil
    end

    local ragebot_section = tab_rage:Section({Name = "Ragebot", Side = "Left", Size = "Fill"})

    local aura = KillAura.new({
        Range = 250, MaxShootDistance = 250, ShotsPerBurst = 5, TargetMode = "Nearest",
    })

    ragebot_section:Toggle({
        Name = "Enabled", Flag = "ragebot_enabled",
        Callback = function(state)
            if state then aura:Start(); Soda:Notification("Ragebot ON — " .. aura.Config.TargetMode, 2)
            else aura:Stop(); Soda:Notification("Ragebot OFF", 2) end
        end
    })

    ragebot_section:List({
        Name = "Target Mode", Flag = "ragebot_target_mode",
        Options = {"Nearest", "Farthest", "LowestHealth"},
        Default = "Nearest",
        Callback = function(value)
            aura.Config.TargetMode = value
            if aura.Running then Soda:Notification("Target mode: " .. value, 2) end
        end
    })

    ragebot_section:Slider({
        Name = "Range", Flag = "ragebot_range",
        Min = 10, Max = 1000, Default = 250, Decimals = 0,
        Callback = function(value)
            aura.Config.Range = value
            aura.Config.MaxShootDistance = value
        end
    })

    ragebot_section:Slider({
        Name = "Shots Per Burst", Flag = "ragebot_shots",
        Min = 1, Max = 20, Default = 5, Decimals = 0,
        Callback = function(value) aura.Config.ShotsPerBurst = value end
    })

     ---------------------------------------------------------------
    -- HITBOX EXPANDER (Grey)
    ---------------------------------------------------------------
    local Hitbox = {
        Enabled      = false,
        Size         = 20,
        Transparency = 0.3,
        Color        = Color3.fromRGB(163, 162, 165),
        _conn        = nil,
    }

    local function hbApply(character)
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Size = Vector3.new(Hitbox.Size, Hitbox.Size, Hitbox.Size)
            hrp.Transparency = Hitbox.Transparency
            hrp.Material = Enum.Material.Neon
            hrp.Color = Hitbox.Color
            hrp.CanCollide = false
        end
    end

    local function hbReset(character)
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Size = Vector3.new(2, 2, 1)
            hrp.Transparency = 1
            hrp.Material = Enum.Material.Plastic
            hrp.Color = Color3.fromRGB(163, 162, 165)
            hrp.CanCollide = true
        end
    end

    local function hbExpandAll()
        for _, p in ipairs(R_Players:GetPlayers()) do
            if p ~= R_Local and p.Character then hbApply(p.Character) end
        end
    end

    local function hbRestoreAll()
        for _, p in ipairs(R_Players:GetPlayers()) do
            if p ~= R_Local and p.Character then hbReset(p.Character) end
        end
    end

    local function hbBind(player)
        if player == R_Local then return end
        if player.Character and Hitbox.Enabled then hbApply(player.Character) end
        player.CharacterAdded:Connect(function(char)
            task.wait(0.3)
            if Hitbox.Enabled then hbApply(char) end
        end)
    end

    for _, p in ipairs(R_Players:GetPlayers()) do hbBind(p) end
    R_Players.PlayerAdded:Connect(hbBind)

    ragebot_section:Toggle({
        Name = "Hitbox Expander", Flag = "ragebot_hitbox_enabled",
        Callback = function(state)
            Hitbox.Enabled = state
            if state then
                if Hitbox._conn then task.cancel(Hitbox._conn) end
                Hitbox._conn = task.spawn(function()
                    while Hitbox.Enabled do
                        hbExpandAll()
                        task.wait(0.1)
                    end
                end)
                Soda:Notification("Hitbox Expander ON", 2)
            else
                if Hitbox._conn then task.cancel(Hitbox._conn); Hitbox._conn = nil end
                hbRestoreAll()
                Soda:Notification("Hitbox Expander OFF", 2)
            end
        end
    })

    ragebot_section:Slider({
        Name = "Hitbox Size", Flag = "ragebot_hitbox_size",
        Min = 1, Max = 50, Default = 20, Decimals = 1,
        Callback = function(value)
            Hitbox.Size = value
            if Hitbox.Enabled then hbExpandAll() end
        end
    })

    ragebot_section:Slider({
        Name = "Hitbox Transparency", Flag = "ragebot_hitbox_transparency",
        Min = 0, Max = 1, Default = 0.3, Decimals = 0.01,
        Callback = function(value)
            Hitbox.Transparency = value
            if Hitbox.Enabled then hbExpandAll() end
        end
    })

    ---------------------------------------------------------------
    -- GODMODE
    ---------------------------------------------------------------
    local God = { enabled = false, respawnConn = nil, running = false }
    local GodWorkspace = game:GetService("Workspace")
    local GodVIM       = game:GetService("VirtualInputManager")

    local function godRun()
        if not God.enabled or God.running then return end
        God.running = true

        task.spawn(function()
            local function safeWait(sec)
                local t = 0
                while t < sec do
                    if not God.enabled then return false end
                    task.wait(0.05)
                    t = t + 0.05
                end
                return true
            end

            local LocalPlayer = R_Local
            local HRP = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart", 5)
            if not HRP then God.running = false; return end

            local VehicleSpawner = GodWorkspace:FindFirstChild("VehicleSpawner")
            local myVehicle

            if VehicleSpawner then
                local sign = VehicleSpawner:FindFirstChild("Sign", true)
                local signPart = sign and sign:FindFirstChild("Part", true)
                if signPart then
                    HRP.CFrame = signPart.CFrame + Vector3.new(0, 3, 0)
                end
                if not safeWait(0.2) then God.running = false; return end
                local prompt = signPart and signPart:FindFirstChild("ProximityPrompt")
                if prompt then pcall(function() fireproximityprompt(prompt) end) end
                if not safeWait(0.4) then God.running = false; return end
            end

            local Vehicles = GodWorkspace:FindFirstChild("Vehicles")
            if Vehicles then
                local timestamp = tick()
                while tick() - timestamp < 3 do
                    if not God.enabled then God.running = false; return end
                    for _, v in ipairs(Vehicles:GetChildren()) do
                        if v.Name == LocalPlayer.Name
                           or v:GetAttribute("VehicleOwner") == true
                           or v:GetAttribute("Owner") == LocalPlayer.Name then
                            myVehicle = v
                            break
                        end
                    end
                    if myVehicle then break end
                    task.wait(0.05)
                end

                if not myVehicle and God.enabled then
                    local closest = math.huge
                    for _, v in ipairs(Vehicles:GetChildren()) do
                        local Ride = v:FindFirstChild("Ride")
                        if Ride and Ride:IsA("ProximityPrompt") then
                            local pos = v:IsA("Model") and v:GetPivot().Position
                                or (v:IsA("BasePart") and v.Position)
                            if pos then
                                local dist = (pos - HRP.Position).Magnitude
                                if dist < closest then
                                    closest = dist
                                    myVehicle = v
                                end
                            end
                        end
                    end
                end

                if myVehicle and God.enabled then
                    local Ride = myVehicle:FindFirstChild("Ride")
                    if Ride and Ride:IsA("ProximityPrompt") then
                        if myVehicle:IsA("BasePart") then
                            HRP.CFrame = myVehicle.CFrame + Vector3.new(0, 2, 0)
                        elseif myVehicle:IsA("Model") then
                            local primary = myVehicle.PrimaryPart or myVehicle:FindFirstChildWhichIsA("BasePart")
                            if primary then HRP.CFrame = primary.CFrame + Vector3.new(0, 2, 0) end
                        end
                        if not safeWait(0.15) then God.running = false; return end
                        pcall(function() fireproximityprompt(Ride) end)
                    end
                end
            end
            if not safeWait(0.2) then God.running = false; return end

            if myVehicle and God.enabled then
                task.spawn(function()
                    for _ = 1, 10 do
                        if myVehicle and myVehicle.Parent and God.enabled then
                            if myVehicle:IsA("Model") then
                                local primary = myVehicle.PrimaryPart or myVehicle:FindFirstChildWhichIsA("BasePart")
                                if primary then myVehicle:PivotTo(myVehicle:GetPivot() + primary.CFrame.LookVector * 1.5) end
                            elseif myVehicle:IsA("BasePart") then
                                myVehicle.CFrame = myVehicle.CFrame + myVehicle.CFrame.LookVector * 1.5
                            end
                        end
                        task.wait(0.05)
                    end
                end)
            end
            if not safeWait(0.5) then God.running = false; return end
            if not God.enabled then God.running = false; return end

            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local Humanoid = char:WaitForChild("Humanoid", 5)
            HRP = char:WaitForChild("HumanoidRootPart", 5)
            if not Humanoid or not HRP then God.running = false; return end

            local seatTarget, fallbackTarget
            if Humanoid.SeatPart then
                local SeatPart = Humanoid.SeatPart
                seatTarget = GodWorkspace ~= SeatPart.Parent and SeatPart.Parent or SeatPart
            else
                seatTarget = myVehicle
            end
            fallbackTarget = seatTarget

            local safeCF = CFrame.new(Vector3.new(-432.14392089844, 38.964965820312, -284.10165405273))

            local ladder = {
                Vector3.new(100000, 100000, 100000),
                Vector3.new(200000, 200000, 200000),
                Vector3.new(1500000, 1500000, 1500000),
                Vector3.new(4000000, 4000000, 4000000),
                Vector3.new(6500000, 6500000, 6500000),
                Vector3.new(9000000, 9000000, 9000000),
                Vector3.new(5000000, 5000000, 5000000),
                Vector3.new(18000000, 18000000, 18000000),
            }

            local function moveTo(cf)
                local target
                if Humanoid and Humanoid.SeatPart then
                    local SeatPart = Humanoid.SeatPart
                    target = GodWorkspace ~= SeatPart.Parent and SeatPart.Parent or SeatPart
                else
                    target = myVehicle
                end
                target = target or fallbackTarget
                if target and target:IsA("Model") then target:PivotTo(cf); return end
                if target and target:IsA("BasePart") then target.CFrame = cf; return end
                if HRP then HRP.CFrame = cf end
            end

            local lastPos = HRP.Position
            for _, waypoint in ipairs(ladder) do
                if not God.enabled then God.running = false; return end
                for i = 1, 25 do
                    local a = i / 25
                    moveTo(CFrame.new(lastPos:Lerp(waypoint, a)))
                    task.wait(0.005)
                end
                lastPos = waypoint
            end

            if God.enabled then
                local voidPos = Vector3.new(18812581888888, 1e29, 998235235621111)
                for i = 1, 15 do
                    local a = (i / 15) ^ 2
                    moveTo(CFrame.new(lastPos:Lerp(voidPos, a)))
                    task.wait(0.03)
                end

                Humanoid.Jump = true
                pcall(function()
                    GodVIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait(0.05)
                    GodVIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                end)
                task.wait(0.1)

                moveTo(CFrame.new(voidPos))
                task.wait(5)

                if not God.enabled then God.running = false; return end

                local newChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                HRP = newChar:WaitForChild("HumanoidRootPart", 5)
                local Humanoid2 = newChar:FindFirstChildOfClass("Humanoid")
                if not HRP then God.running = false; return end

                local returnTarget
                if Humanoid2 and Humanoid2.SeatPart then
                    local SeatPart = Humanoid2.SeatPart
                    returnTarget = GodWorkspace ~= SeatPart.Parent and SeatPart.Parent or SeatPart
                else
                    returnTarget = myVehicle
                end
                returnTarget = returnTarget or fallbackTarget

                HRP.Anchored = true
                HRP.AssemblyLinearVelocity = Vector3.zero
                HRP.AssemblyAngularVelocity = Vector3.zero
                HRP.CFrame = safeCF

                if returnTarget then
                    if returnTarget:IsA("Model") then
                        for _, d in ipairs(returnTarget:GetDescendants()) do
                            if d:IsA("BasePart") then
                                d.Anchored = true
                                d.AssemblyLinearVelocity = Vector3.zero
                                d.AssemblyAngularVelocity = Vector3.zero
                            end
                        end
                        returnTarget:PivotTo(safeCF)
                    elseif returnTarget:IsA("BasePart") then
                        returnTarget.Anchored = true
                        returnTarget.AssemblyLinearVelocity = Vector3.zero
                        returnTarget.AssemblyAngularVelocity = Vector3.zero
                        returnTarget.CFrame = safeCF
                    end
                end

                task.wait(0.15)
                HRP.Anchored = false

                if returnTarget then
                    if returnTarget:IsA("Model") then
                        for _, d in ipairs(returnTarget:GetDescendants()) do
                            if d:IsA("BasePart") then d.Anchored = false end
                        end
                    elseif returnTarget:IsA("BasePart") then
                        returnTarget.Anchored = false
                    end
                end
            end

            God.running = false
        end)
    end

    ragebot_section:Toggle({
        Name = "Godmode", Flag = "ragebot_godmode", LayoutOrder = 200,
        Callback = function(state)
            God.enabled = state
            if state then
                if God.respawnConn then God.respawnConn:Disconnect() end
                God.respawnConn = R_Local.CharacterAdded:Connect(function()
                    if God.enabled then
                        task.wait(1.5)
                        godRun()
                    end
                end)
                godRun()
                Soda:Notification("Godmode ON", 2)
            else
                if God.respawnConn then God.respawnConn:Disconnect(); God.respawnConn = nil end
                God.running = false
                Soda:Notification("Godmode OFF", 2)
            end
        end
    })
end

--====================================================================
-- FUN STUFF TAB
--====================================================================
do
    local fun_section = tab_fun:Section({Name = "Fun stuff", Side = "Left", Size = "Fill"})

    fun_section:Button({
        Name = "Troll Sign",
        Callback = function()
            pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/nexoralua-maker/Da-hood-/main/Nazi"))()
            end)
            Soda:Notification("Loaded Troll Sign", 2)
        end
    })

    fun_section:Button({
        Name = "Male",
        Callback = function()
            pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/nexoralua-maker/Da-hood-/main/Penis"))()
            end)
            Soda:Notification("Loaded Male", 2)
        end
    })

    fun_section:Button({
        Name = "Female",
        Callback = function()
            pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/nexoralua-maker/Da-hood-/main/HornySlut"))()
            end)
            Soda:Notification("Loaded Female", 2)
        end
    })
end

--====================================================================
-- PLAYER TAB — Character + Movement
--====================================================================
do
    local PC_Players    = game:GetService("Players")
    local PC_RunService = game:GetService("RunService")
    local PC_Local      = PC_Players.LocalPlayer
    local PC_RS         = game:GetService("ReplicatedStorage")
    local PC_TCS        = game:GetService("TextChatService")
    local SodaUIS       = game:GetService("UserInputService")

    local pc = {
        antiPepperConn=nil, antiStompConn=nil, wasKnocked=false,
        autoEatConn=nil, autoEatBusy=false,
        noclipConn=nil, noJumpConn=nil,
        antiGrabConn=nil, antiGrabEnabled=false,
        cashAuraEnabled=false, cashAuraRadius=20, cashAuraDelay=0.5,
        godBlockEnabled=false, godBlockConn=nil,
        autoReloadConn=nil, autoReloadEnabled=false,
        chatSpamTrashTalk=false, chatSpamLastTime=0, chatSpamIndex=1, chatSpamDelay=3,
        trashTalkList = {
            "imagine getting cracked by Soda.Fun 💀", "Soda.Fun", "get better buddy", "skill issue",
            "get Soda.Fun today", "stop 😂", "free script btw", "mad?", "cry about it", "trash",
            "noob lol", "owned by Soda.Fun", "get rekt", "you're bad", "stay mad with no Soda.Fun",
            "no Soda.Fun = no skill", "washed", "dogwater", "200 pumped by Soda.Fun"
        }
    }

    PC_Local.CharacterAdded:Connect(function() pc.wasKnocked = false end)

    local player_char_section = tab_player:Section({Name = "Player Character", Side = "Left", Size = "Fill"})
    local pc_scroll = player_char_section:Nest({Size = "Fill"})

    pc_scroll:Toggle({
        Name = "Anti stomp", Flag = "pc_anti_stomp",
        Callback = function(state)
            if pc.antiStompConn then pc.antiStompConn:Disconnect(); pc.antiStompConn = nil end
            if state then
                pc.antiStompConn = PC_RunService.Heartbeat:Connect(function()
                    local char = PC_Local.Character
                    local be = char and char:FindFirstChild("BodyEffects")
                    if be then
                        local KO = be:FindFirstChild("K.O") or be:FindFirstChild("KO")
                        if KO and KO.Value == true and not pc.wasKnocked then
                            pc.wasKnocked = true
                            local oldTime = PC_Players.RespawnTime
                            PC_Players.RespawnTime = 0.1
                            local hum = char:FindFirstChildWhichIsA("Humanoid")
                            if hum then hum:ChangeState(Enum.HumanoidStateType.Dead) end
                            char:BreakJoints()
                            task.delay(0.2, function() PC_Players.RespawnTime = oldTime end)
                        end
                    end
                end)
            end
        end
    })

    pc_scroll:Toggle({
        Name = "Anti slow", Flag = "pc_anti_slow",
        Callback = function(state)
            if state then
                PC_RunService:BindToRenderStep("Soda_AntiSlow", Enum.RenderPriority.Camera.Value, function()
                    local char = PC_Local.Character
                    if char and char:FindFirstChild("BodyEffects") then
                        local BE = char.BodyEffects
                        local Movement = BE:FindFirstChild("Movement")
                        if Movement then
                            for _, name in ipairs({"NoWalkSpeed", "ReduceWalk", "NoJumping"}) do
                                local item = Movement:FindFirstChild(name)
                                if item then item:Destroy() end
                            end
                        end
                        local reload = BE:FindFirstChild("Reload")
                        if reload and reload.Value then reload.Value = false end
                    end
                end)
            else
                PC_RunService:UnbindFromRenderStep("Soda_AntiSlow")
            end
        end
    })

    pc_scroll:Toggle({
        Name = "Anti grab", Flag = "pc_anti_grab",
        Callback = function(state)
            pc.antiGrabEnabled = state
            if pc.antiGrabConn then pc.antiGrabConn:Disconnect(); pc.antiGrabConn = nil end
            if state then
                pc.antiGrabConn = PC_RunService.RenderStepped:Connect(function()
                    if not pc.antiGrabEnabled then
                        if pc.antiGrabConn then pc.antiGrabConn:Disconnect(); pc.antiGrabConn = nil end
                        return
                    end
                    local char = PC_Local.Character
                    if not char then return end
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and char:FindFirstChild("GRABBING_CONSTRAINT") then
                        hum:ChangeState(Enum.HumanoidStateType.Physics); task.wait()
                        hum:ChangeState(Enum.HumanoidStateType.GettingUp); task.wait()
                        hum:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end)
            end
        end
    })

    pc_scroll:Toggle({
        Name = "Anti Seat", Flag = "pc_anti_seat",
        Callback = function(state)
            for _, s in ipairs(workspace:GetDescendants()) do
                if s:IsA("Seat") then s.Disabled = state end
            end
        end
    })

    pc_scroll:Toggle({
        Name = "Anti pepperspray", Flag = "pc_anti_pepperspray",
        Callback = function(state)
            if pc.antiPepperConn then pc.antiPepperConn:Disconnect(); pc.antiPepperConn = nil end
            if state then
                pc.antiPepperConn = PC_RunService.RenderStepped:Connect(function()
                    local char = PC_Local.Character
                    if char then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            local trail = hum:FindFirstChild("TrailEffects")
                            if trail then trail:Destroy() end
                        end
                    end
                    local pg = PC_Local:FindFirstChild("PlayerGui")
                    local main = pg and pg:FindFirstChild("MainScreenGui")
                    if main then
                        for _, obj in pairs(main:GetChildren()) do
                            if obj.Name == "PepperSpray" or obj.Name == "Blood" or obj.Name == "Action" then
                                obj.Visible = false
                                if obj:IsA("GuiObject") then obj.Transparency = 1 end
                            end
                        end
                    end
                end)
            end
        end
    })

    pc_scroll:Toggle({
        Name = "Auto Eat [Taco]", Flag = "pc_auto_eat_taco",
        Callback = function(state)
            if pc.autoEatConn then pc.autoEatConn:Disconnect(); pc.autoEatConn = nil end
            if state then
                pc.autoEatConn = PC_RunService.Heartbeat:Connect(function()
                    if pc.autoEatBusy then return end
                    local char = PC_Local.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health < 100 then
                        local food = char:FindFirstChild("[Taco]") or PC_Local.Backpack:FindFirstChild("[Taco]")
                        if food then
                            pc.autoEatBusy = true
                            food.Parent = char
                            food:Activate()
                            task.wait(0.1)
                            pc.autoEatBusy = false
                        else
                            local ignored = workspace:FindFirstChild("Ignored")
                            local shop = ignored and ignored:FindFirstChild("Shop")
                            if shop then
                                for _, item in ipairs(shop:GetChildren()) do
                                    if item.Name:find("%[Taco%]") and item:FindFirstChild("Head") then
                                        pc.autoEatBusy = true
                                        local hrp = char:FindFirstChild("HumanoidRootPart")
                                        if hrp then
                                            local savedPos = hrp.CFrame
                                            hrp.CFrame = item.Head.CFrame
                                            local cd = item:FindFirstChildOfClass("ClickDetector")
                                            if cd then fireclickdetector(cd) end
                                            PC_RunService:BindToRenderStep("Soda_RestoreEatPos", 199, function()
                                                hrp.CFrame = savedPos
                                                PC_RunService:UnbindFromRenderStep("Soda_RestoreEatPos")
                                                pc.autoEatBusy = false
                                            end)
                                        end
                                        break
                                    end
                                end
                            end
                        end
                    elseif hum and hum.Health >= 100 then
                        local heldFood = char:FindFirstChild("[Taco]")
                        if heldFood then heldFood.Parent = PC_Local.Backpack end
                    end
                end)
            end
        end
    })

    pc_scroll:Toggle({
        Name = "Chat Spy", Flag = "pc_chat_spy",
        Callback = function(state)
            if PC_TCS.ChatWindowConfiguration then PC_TCS.ChatWindowConfiguration.Enabled = state end
        end
    })

    pc_scroll:Toggle({
        Name = "Noclip", Flag = "pc_noclip",
        Callback = function(state)
            if pc.noclipConn then pc.noclipConn:Disconnect(); pc.noclipConn = nil end
            if state then
                pc.noclipConn = PC_RunService.Stepped:Connect(function()
                    local char = PC_Local.Character
                    if char then
                        for _, p in ipairs(char:GetDescendants()) do
                            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
                        end
                    end
                end)
            end
        end
    })

    pc_scroll:Toggle({
        Name = "No jump cooldown", Flag = "pc_no_jump_cooldown",
        Callback = function(state)
            local function fixJump(char)
                local hum = char:WaitForChild("Humanoid", 5)
                if hum then hum.UseJumpPower = not state end
            end
            if PC_Local.Character then fixJump(PC_Local.Character) end
            if pc.noJumpConn then pc.noJumpConn:Disconnect() end
            pc.noJumpConn = PC_Local.CharacterAdded:Connect(fixJump)
        end
    })

    pc_scroll:Toggle({
        Name = "Trash Talk", Flag = "pc_trash_talk",
        Callback = function(state) pc.chatSpamTrashTalk = state end
    })

    task.spawn(function()
        while task.wait(0.1) do
            if pc.chatSpamTrashTalk then
                local now = tick()
                if now - pc.chatSpamLastTime >= pc.chatSpamDelay then
                    local msg = pc.trashTalkList[pc.chatSpamIndex]
                    pc.chatSpamIndex = (pc.chatSpamIndex % #pc.trashTalkList) + 1
                    pcall(function()
                        if PC_TCS.ChatVersion == Enum.ChatVersion.TextChatService then
                            local channel = PC_TCS.TextChannels:FindFirstChild("RBXGeneral") or PC_TCS.TextChannels:FindFirstChildOfClass("TextChannel")
                            if channel then channel:SendAsync(msg) end
                        else
                            local chatEvents = PC_RS:FindFirstChild("DefaultChatSystemChatEvents")
                            if chatEvents then chatEvents.SayMessageRequest:FireServer(msg, "All") end
                        end
                    end)
                    pc.chatSpamLastTime = now
                end
            end
        end
    end)

    pc_scroll:Toggle({
        Name = "God Block", Flag = "pc_god_block",
        Callback = function(state)
            pc.godBlockEnabled = state
            if pc.godBlockConn then pc.godBlockConn:Disconnect(); pc.godBlockConn = nil end
            if state then
                pc.godBlockConn = PC_RunService.Stepped:Connect(function()
                    if not pc.godBlockEnabled then return end
                    local char = PC_Local.Character
                    if char and char:FindFirstChild("BodyEffects") then
                        local BE = char.BodyEffects
                        local block = BE:FindFirstChild("Block")
                        if block then block:Destroy() end
                        local tool = char:FindFirstChildWhichIsA("Tool")
                        if tool and tool:FindFirstChild("Ammo") then PC_RS.MainEvent:FireServer("Block", false); return end
                        PC_RS.MainEvent:FireServer("Block", true)
                        task.wait(0.2)
                        PC_RS.MainEvent:FireServer("Block", false)
                    end
                end)
            end
        end
    })

    pc_scroll:Toggle({
        Name = "Auto block", Flag = "pc_auto_block",
        Callback = function(state)
            if state then
                PC_RunService:BindToRenderStep("Soda_AutoBlock", 0, function()
                    local char = PC_Local.Character
                    if not char then return end
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end
                    local wplayers = workspace:FindFirstChild("Players")
                    if not wplayers then return end
                    for _, other in ipairs(wplayers:GetChildren()) do
                        if other:FindFirstChild("UpperTorso") and other:FindFirstChild("BodyEffects") then
                            local dist = (other.UpperTorso.Position - hrp.Position).Magnitude
                            if dist <= 15 then
                                local tool = other:FindFirstChildWhichIsA("Tool")
                                local attacking = other.BodyEffects:FindFirstChild("Attacking") and other.BodyEffects.Attacking.Value
                                if attacking and tool and other.Name ~= PC_Local.Name then
                                    local foodWeapons = {
                                        "[Popcorn]","[HotDog]","[GrenadeLauncher]","[RPG]","[SMG]","[TacticalShotgun]",
                                        "[AK47]","[AUG]","[Glock]","[Shotgun]","[Flamethrower]","[Silencer]","[AR]",
                                        "[Revolver]","[SilencerAR]","[LMG]","[P90]","[DrumGun]","[Double-Barrel SG]",
                                        "[Hamburger]","[Chicken]","[Pizza]","[Cranberry]","[Donut]","[Taco]",
                                        "[Starblox Latte]","[BrownBag]","[Weights]","[HeavyWeights]"
                                    }
                                    if not table.find(foodWeapons, tool.Name) then
                                        PC_RS.MainEvent:FireServer("Block", PC_Local.Name)
                                    end
                                end
                            end
                        end
                    end
                end)
            else
                PC_RunService:UnbindFromRenderStep("Soda_AutoBlock")
            end
        end
    })

    pc_scroll:Toggle({
        Name = "Cash aura", Flag = "pc_cash_aura",
        Callback = function(state)
            pc.cashAuraEnabled = state
            if state then
                task.spawn(function()
                    while pc.cashAuraEnabled do
                        local char = PC_Local.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local ignored = workspace:FindFirstChild("Ignored")
                            local drop = ignored and ignored:FindFirstChild("Drop")
                            if drop then
                                for _, child in ipairs(drop:GetChildren()) do
                                    if child.Name == "MoneyDrop" then
                                        local originalPos = child:GetAttribute("OriginalPos") or child.Position
                                        if (originalPos - hrp.Position).Magnitude <= pc.cashAuraRadius then
                                            local cd = child:FindFirstChildOfClass("ClickDetector")
                                            if cd then fireclickdetector(cd) end
                                        end
                                    end
                                end
                            end
                        end
                        task.wait(pc.cashAuraDelay)
                    end
                end)
            end
        end
    })

    pc_scroll:Toggle({
        Name = "Auto reload", Flag = "pc_auto_reload",
        Callback = function(state)
            pc.autoReloadEnabled = state
            if pc.autoReloadConn then pc.autoReloadConn:Disconnect(); pc.autoReloadConn = nil end
            if state then
                pc.autoReloadConn = PC_RunService.RenderStepped:Connect(function()
                    if not pc.autoReloadEnabled then
                        if pc.autoReloadConn then pc.autoReloadConn:Disconnect(); pc.autoReloadConn = nil end
                        return
                    end
                    local char = PC_Local.Character
                    if not char then return end
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") and tool:FindFirstChild("Ammo") then
                            if tool.Ammo.Value <= 1 then
                                PC_RS.MainEvent:FireServer("Reload", tool)
                                task.wait(3.7)
                            end
                        end
                    end
                end)
            end
        end
    })

    ---------------------------------------------------------------
    -- AUTO ARMOR  ([High-Medium Armor] - $2589)
    ---------------------------------------------------------------
    do
        local AA = {
            ShopItemName  = "[High-Medium Armor] - $2589",
            Threshold     = 100,
            CheckInterval = 0.1,
            BuyCooldown   = 0.3,
            MaxRetries    = 5,
            PostBuyWait   = 0.5,
            Enabled       = false,
            Thread        = nil,
            DummyPart     = nil,
            IsBuying      = false,
            c_enabled     = false,
            c_pos         = nil,
            c_oldPos      = nil,
            c_target      = nil,
            HeartbeatConn = nil,
        }

        local camera = workspace.CurrentCamera

        local function getHRP()
            local char = PC_Local.Character
            return char and char:FindFirstChild("HumanoidRootPart")
        end

        local function getHumanoid()
            local char = PC_Local.Character
            return char and char:FindFirstChildOfClass("Humanoid")
        end

        local function findShopItem()
            local ig   = workspace:FindFirstChild("Ignored")
            local shop = ig and ig:FindFirstChild("Shop")
            return shop and shop:FindFirstChild(AA.ShopItemName)
        end

        local function getArmorValue()
            local char = PC_Local.Character
            if not char then return nil end
            local be = char:FindFirstChild("BodyEffects")
            if not be then return nil end
            local armor = be:FindFirstChild("Armor")
            if not armor then return nil end
            return tonumber(armor.Value) or 0
        end

        local function ensureDummyPart()
            if AA.DummyPart and AA.DummyPart.Parent then return AA.DummyPart end
            local existing = workspace:FindFirstChild("AutoArmor_Setback")
            if existing then AA.DummyPart = existing; return AA.DummyPart end
            local p = Instance.new("Part")
            p.Name         = "AutoArmor_Setback"
            p.Size         = Vector3.new(2, 2, 1)
            p.Anchored     = true
            p.CanCollide   = false
            p.Transparency = 1
            p.Parent       = workspace
            AA.DummyPart   = p
            return p
        end

        local function restoreCamera()
            local hum = getHumanoid()
            if hum then camera.CameraSubject = hum end
        end

        local function buyViaShopItem(item)
            if AA.IsBuying then return false end
            if not item or not item:FindFirstChild("Head") then return false end

            AA.IsBuying  = true
            AA.c_enabled = true
            AA.c_pos     = item.Head.Position
            AA.c_target  = item

            ensureDummyPart()
            camera.CameraSubject = AA.DummyPart
            task.wait(0.15)

            local cd = item:FindFirstChildOfClass("ClickDetector")
            if cd then pcall(function() fireclickdetector(cd) end) end

            task.wait(0.1)
            AA.c_enabled = false
            restoreCamera()
            AA.IsBuying = false
            return true
        end

        -- Heartbeat TP loop — moves HRP to shop for one frame, snaps back
        AA.HeartbeatConn = PC_RunService.Heartbeat:Connect(function()
            if not AA.c_enabled or not AA.c_pos or not AA.c_target then return end
            local hrp = getHRP()
            if not hrp then return end
            AA.c_oldPos = hrp.CFrame
            hrp.CFrame = CFrame.new(AA.c_pos)
            if AA.DummyPart then AA.DummyPart.CFrame = AA.c_oldPos end
            PC_RunService.RenderStepped:Wait()
            hrp.CFrame = AA.c_oldPos
        end)

        local function armorLoop()
            while AA.Enabled do
                local armor = getArmorValue()
                if armor and not AA.IsBuying and armor <= AA.Threshold then
                    local shopItem = findShopItem()
                    if shopItem then
                        local startArmor = armor
                        local succeeded  = false
                        local attempts   = 0
                        repeat
                            attempts += 1
                            buyViaShopItem(shopItem)
                            local waitStart = tick()
                            while tick() - waitStart < AA.BuyCooldown do
                                local current = getArmorValue()
                                if current and current > startArmor then
                                    succeeded = true
                                    break
                                end
                                task.wait(0.05)
                            end
                            if not succeeded and attempts < AA.MaxRetries then task.wait(0.05) end
                        until succeeded or attempts >= AA.MaxRetries
                        task.wait(AA.PostBuyWait)
                    else
                        task.wait(1)
                    end
                end
                task.wait(AA.CheckInterval)
            end
        end

        pc_scroll:Toggle({
            Name = "Auto armor", Flag = "pc_auto_armor",
            Callback = function(state)
                AA.Enabled = state
                if state then
                    Soda:Notification("🛡 Auto Armor ON — threshold " .. AA.Threshold, 2)
                    if not AA.Thread or coroutine.status(AA.Thread) == "dead" then
                        AA.Thread = task.spawn(armorLoop)
                    end
                else
                    Soda:Notification("⛔ Auto Armor OFF", 2)
                    AA.c_enabled = false
                    restoreCamera()
                end
            end
        })

        pc_scroll:Slider({
            Name = "Armor Threshold", Flag = "pc_auto_armor_threshold",
            Min = 0, Max = 150, Default = 100, Decimals = 0,
            Callback = function(value) AA.Threshold = value end
        })
    end

    local CFrameSpeed = {Enabled = false, Speed = 20, _conn = nil}
    local move_section = tab_player:Section({Name = "Movement", Side = "Right", Size = "Fill"})

    local function cfsStart()
        if CFrameSpeed._conn then return end
        CFrameSpeed._conn = PC_RunService.Heartbeat:Connect(function(dt)
            if not CFrameSpeed.Enabled then return end
            local char = PC_Local.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (dt * CFrameSpeed.Speed * 10))
        end)
    end

    local function cfsStop()
        if CFrameSpeed._conn then CFrameSpeed._conn:Disconnect(); CFrameSpeed._conn = nil end
    end

    move_section:Toggle({
        Name = "CFrame", Flag = "movement_cframe_enabled",
        Callback = function(state)
            CFrameSpeed.Enabled = state
            if state then cfsStart(); Soda:Notification("CFrame Speed ON — " .. CFrameSpeed.Speed, 2)
            else cfsStop(); Soda:Notification("CFrame Speed OFF", 2) end
        end
    })

    move_section:Slider({
        Name = "Speed", Flag = "movement_cframe_speed",
        Min = 1, Max = 500, Default = 20, Decimals = 1,
        Callback = function(value) CFrameSpeed.Speed = math.clamp(value, 1, 500) end
    })

    --====================================================================
    -- AUTO SKINNY  ([Lettuce] - $6)
    --====================================================================
    local SkinnyToggle
    do
        local S = {
            ItemName     = "[Lettuce]",
            ShopItemName = "[Lettuce] - $6",
            SafeCF       = CFrame.new(-117, -57, 147),
            LoopDelay    = 0.1,
            BuyCooldown  = 0.25,
            Running      = false,
            Thread       = nil,
        }

        local function getHRP()
            local c = PC_Local.Character
            return c and c:FindFirstChild("HumanoidRootPart")
        end

        local function findShopItem()
            local ig = workspace:FindFirstChild("Ignored")
            local shop = ig and ig:FindFirstChild("Shop")
            return shop and shop:FindFirstChild(S.ShopItemName)
        end

        local function buyItem()
            local item = findShopItem()
            if not item then Soda:Notification("⚠ Lettuce shop item not found!", 3); return false end
            local hrp = getHRP(); if not hrp then return false end
            local head = item:FindFirstChild("Head")
            local cd   = item:FindFirstChild("ClickDetector")
            if not (head and cd) then Soda:Notification("⚠ Shop item missing Head/CD", 3); return false end
            local oldCF = hrp.CFrame
            hrp.CFrame = head.CFrame * CFrame.new(0, 2, 3)
            task.wait(S.BuyCooldown)
            pcall(function() fireclickdetector(cd) end)
            task.wait(S.BuyCooldown)
            hrp.CFrame = oldCF
            return true
        end

        local function equipItem()
            local char = PC_Local.Character; if not char then return false end
            local bp = PC_Local:FindFirstChild("Backpack"); if not bp then return false end
            local tool = bp:FindFirstChild(S.ItemName); if not tool then return false end
            tool.Parent = char
            task.wait(0.1)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                pcall(function() hum:EquipTool(tool) end)
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = S.SafeCF end
            end
            return true
        end

        local function activateItem()
            local char = PC_Local.Character; if not char then return false end
            local tool = char:FindFirstChild(S.ItemName); if not tool then return false end
            pcall(function() tool:Activate() end)
            return true
        end

        local function runLoop()
            while S.Running do
                local char = PC_Local.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local inChar = char:FindFirstChild(S.ItemName)
                    local bp     = PC_Local:FindFirstChild("Backpack")
                    local inBag  = bp and bp:FindFirstChild(S.ItemName)
                    if inChar then activateItem()
                    elseif inBag then equipItem()
                    else buyItem(); task.wait(0.2); equipItem() end
                end
                task.wait(S.LoopDelay)
            end
        end

        SkinnyToggle = move_section:Toggle({
            Name = "Auto Skinny", Flag = "movement_auto_skinny",
            Callback = function(state)
                S.Running = state
                if state then
                    Soda:Notification("✅ Auto Skinny Enabled", 2)
                    if not S.Thread or coroutine.status(S.Thread) == "dead" then
                        S.Thread = task.spawn(runLoop)
                    end
                else
                    Soda:Notification("⛔ Auto Skinny Disabled", 2)
                    pcall(function()
                        local hrp = getHRP()
                        if hrp then hrp.CFrame = S.SafeCF end
                    end)
                end
            end
        })

        SodaUIS.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.RightControl and SkinnyToggle then
                SkinnyToggle:Set(not SkinnyToggle.Toggled)
            end
        end)
    end

    --====================================================================
    -- AUTO WEIGH  ([HeavyWeights] - $281)
    --====================================================================
    local WeighToggle
    do
        local W = {
            ItemName     = "[HeavyWeights]",
            ShopItemName = "[HeavyWeights] - $281",
            SafeCF       = CFrame.new(-117, -57, 147),
            LoopDelay    = 0.1,
            BuyCooldown  = 0.25,
            Running      = false,
            Thread       = nil,
        }

        local function getHRP()
            local c = PC_Local.Character
            return c and c:FindFirstChild("HumanoidRootPart")
        end

        local function findShopItem()
            local ig = workspace:FindFirstChild("Ignored")
            local shop = ig and ig:FindFirstChild("Shop")
            return shop and shop:FindFirstChild(W.ShopItemName)
        end

        local function buyItem()
            local item = findShopItem()
            if not item then Soda:Notification("⚠ HeavyWeights shop item not found!", 3); return false end
            local hrp = getHRP(); if not hrp then return false end
            local head = item:FindFirstChild("Head")
            local cd   = item:FindFirstChild("ClickDetector")
            if not (head and cd) then Soda:Notification("⚠ Shop item missing Head/CD", 3); return false end
            local oldCF = hrp.CFrame
            hrp.CFrame = head.CFrame * CFrame.new(0, 2, 3)
            task.wait(W.BuyCooldown)
            pcall(function() fireclickdetector(cd) end)
            task.wait(W.BuyCooldown)
            hrp.CFrame = oldCF
            return true
        end

        local function equipItem()
            local char = PC_Local.Character; if not char then return false end
            local bp = PC_Local:FindFirstChild("Backpack"); if not bp then return false end
            local tool = bp:FindFirstChild(W.ItemName); if not tool then return false end
            tool.Parent = char
            task.wait(0.1)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                pcall(function() hum:EquipTool(tool) end)
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = W.SafeCF end
            end
            return true
        end

        local function activateItem()
            local char = PC_Local.Character; if not char then return false end
            local tool = char:FindFirstChild(W.ItemName); if not tool then return false end
            pcall(function() tool:Activate() end)
            return true
        end

        local function runLoop()
            while W.Running do
                local char = PC_Local.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local inChar = char:FindFirstChild(W.ItemName)
                    local bp     = PC_Local:FindFirstChild("Backpack")
                    local inBag  = bp and bp:FindFirstChild(W.ItemName)
                    if inChar then activateItem()
                    elseif inBag then equipItem()
                    else buyItem(); task.wait(0.2); equipItem() end
                end
                task.wait(W.LoopDelay)
            end
        end

        WeighToggle = move_section:Toggle({
            Name = "Auto Weigh", Flag = "movement_auto_weigh",
            Callback = function(state)
                W.Running = state
                if state then
                    Soda:Notification("✅ Auto Weigh Enabled", 2)
                    if not W.Thread or coroutine.status(W.Thread) == "dead" then
                        W.Thread = task.spawn(runLoop)
                    end
                else
                    Soda:Notification("⛔ Auto Weigh Disabled", 2)
                    pcall(function()
                        local hrp = getHRP()
                        if hrp then hrp.CFrame = W.SafeCF end
                    end)
                end
            end
        })

        SodaUIS.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.RightShift and WeighToggle then
                WeighToggle:Set(not WeighToggle.Toggled)
            end
        end)
    end

    --====================================================================
    -- BOXING FARM  (Combat spam @ ring)
    --====================================================================
    local BoxingToggle
    do
        local B = {
            ToolName  = "Combat",
            BoxCFrame = CFrame.new(
                -279.363251, 22.5704575, -1142.79883,
                -0.629518926, -4.21714468E-08, -0.776985168,
                -6.35824335E-08, 1, -2.76080292E-09,
                 0.776985168, 4.76646278E-08, -0.629518926
            ),
            SafeCF    = CFrame.new(-117, -57, 147),
            Noclip    = true,
            Running   = false,
            Thread    = nil,
            NoclipConn= nil,
            SavedCF   = nil,
        }

        local function startNoclip()
            if B.NoclipConn then B.NoclipConn:Disconnect(); B.NoclipConn = nil end
            B.NoclipConn = PC_RunService.Stepped:Connect(function()
                if not B.Running or not B.Noclip then return end
                local char = PC_Local.Character; if not char then return end
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
                end
            end)
        end

        local function stopNoclip()
            if B.NoclipConn then B.NoclipConn:Disconnect(); B.NoclipConn = nil end
            local char = PC_Local.Character
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = true end
                end
            end
        end

        local function ensureCombatEquipped()
            local char = PC_Local.Character; if not char then return nil end
            local tool = char:FindFirstChild(B.ToolName)
            if tool then return tool end
            local bp = PC_Local:FindFirstChild("Backpack")
            if bp then
                local inBag = bp:FindFirstChild(B.ToolName)
                if inBag then
                    inBag.Parent = char
                    task.wait(0.05)
                    return char:FindFirstChild(B.ToolName)
                end
            end
            return nil
        end

        local function runLoop()
            while B.Running do
                local char = PC_Local.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = B.BoxCFrame
                    local tool = ensureCombatEquipped()
                    if tool then
                        pcall(function()
                            tool:Activate()
                            task.wait()
                            tool:Deactivate()
                        end)
                    end
                end
                task.wait()
            end
        end

        BoxingToggle = move_section:Toggle({
            Name = "Boxing Farm", Flag = "movement_boxing_farm",
            Callback = function(state)
                B.Running = state
                if state then
                    local hrp = PC_Local.Character and PC_Local.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then B.SavedCF = hrp.CFrame end
                    if B.Noclip then startNoclip() end
                    Soda:Notification("🥊 Boxing Farm Enabled", 2)
                    if not B.Thread or coroutine.status(B.Thread) == "dead" then
                        B.Thread = task.spawn(runLoop)
                    end
                else
                    Soda:Notification("⛔ Boxing Farm Disabled", 2)
                    if B.Noclip then stopNoclip() end
                    if B.SavedCF then
                        pcall(function()
                            local hrp = PC_Local.Character and PC_Local.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then hrp.CFrame = B.SavedCF end
                        end)
                        B.SavedCF = nil
                    end
                end
            end
        })

        SodaUIS.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.RightAlt and BoxingToggle then
                BoxingToggle:Set(not BoxingToggle.Toggled)
            end
        end)
    end
end

--====================================================================
-- FLOATING TOGGLE BUTTON
--====================================================================
local toggle_gui = Instance.new("ScreenGui")
toggle_gui.Name = "SodaToggleGui"
toggle_gui.ResetOnSpawn = false
toggle_gui.DisplayOrder = 999
toggle_gui.Parent = game.CoreGui

local toggle_btn = Instance.new("TextButton")
toggle_btn.Size = UDim2.new(0, 100, 0, 35)
toggle_btn.Position = UDim2.new(0, 20, 0, 20)
toggle_btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
toggle_btn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle_btn.Text = "Soda.Fun"
toggle_btn.FontFace = Soda.FontFace
toggle_btn.TextSize = 14
toggle_btn.AutoButtonColor = false
toggle_btn.Parent = toggle_gui

local toggleCorner = Instance.new("UICorner", toggle_btn); toggleCorner.CornerRadius = UDim.new(0, 6)
local toggleStroke = Instance.new("UIStroke", toggle_btn); toggleStroke.Color = Color3.fromRGB(60, 60, 60)
local toggleGradient = Instance.new("UIGradient", toggle_btn)
toggleGradient.Color = ColorSequence.new(Color3.fromRGB(255, 20, 80), Color3.fromRGB(60, 120, 255))
toggleGradient.Rotation = 0

toggle_btn.MouseButton1Click:Connect(function() Soda:SetOpen(not Soda.Open) end)
toggle_btn.MouseEnter:Connect(function()
    game:GetService("TweenService"):Create(toggleStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(255, 255, 255)}):Play()
end)
toggle_btn.MouseLeave:Connect(function()
    game:GetService("TweenService"):Create(toggleStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(60, 60, 60)}):Play()
end)

--====================================================================
-- DONE
--====================================================================
Soda:Notification("Soda.Fun loaded successfully!", 3)
