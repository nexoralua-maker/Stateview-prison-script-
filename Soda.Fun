--[[
    Soda.Fun — UI Library & Client
    Original base by Linemaster — rebranded, restyled, and refactored
    Font: Montserrat Bold | Accent: Red → Blue gradient
]]

--====================================================================
-- SAFE DRAWING LOADER
--====================================================================
local Drawing
do
    local ok, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/linemaster2/storage/main/Drawing.lua"))()
    end)
    if ok and result then
        Drawing = result
    else
        Drawing = { new = function() return setmetatable({}, {__index = function() return nil end, __newindex = function() end}) end }
    end
end

--====================================================================
-- LIBRARY
--====================================================================
local Library = {}
do
    local FONT_FACE
    do
        local ok, f = pcall(function()
            return Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Bold)
        end)
        FONT_FACE = ok and f or Enum.Font.GothamBold
    end

    Library = {
        Name = "Soda.Fun";
        Open = true;
        Accent = Color3.fromRGB(255, 20, 80);
        AccentGradient = {Color3.fromRGB(255, 20, 80), Color3.fromRGB(60, 120, 255)};
        FontFace = FONT_FACE;
        Pages = {};
        Sections = {};
        Flags = {};
        UnNamedFlags = 0;
        ThemeObjects = {};
        Instances = {};
        Holder = nil;
        OldSize = nil;
        ScreenGUI = nil;
        DropdownOpen = false;
        OptionListOpen = false;
        Keys = {
            [Enum.KeyCode.Space] = "Space", [Enum.KeyCode.Return] = "Return",
            [Enum.KeyCode.LeftShift] = "LShift", [Enum.KeyCode.RightShift] = "RShift",
            [Enum.KeyCode.LeftControl] = "LCtrl", [Enum.KeyCode.RightControl] = "RCtrl",
            [Enum.KeyCode.LeftAlt] = "LAlt", [Enum.KeyCode.RightAlt] = "RAlt",
            [Enum.KeyCode.CapsLock] = "CAPS",
            [Enum.KeyCode.One] = "1", [Enum.KeyCode.Two] = "2", [Enum.KeyCode.Three] = "3",
            [Enum.KeyCode.Four] = "4", [Enum.KeyCode.Five] = "5", [Enum.KeyCode.Six] = "6",
            [Enum.KeyCode.Seven] = "7", [Enum.KeyCode.Eight] = "8", [Enum.KeyCode.Nine] = "9",
            [Enum.KeyCode.Zero] = "0",
            [Enum.KeyCode.KeypadOne] = "Num1", [Enum.KeyCode.KeypadTwo] = "Num2",
            [Enum.KeyCode.KeypadThree] = "Num3", [Enum.KeyCode.KeypadFour] = "Num4",
            [Enum.KeyCode.KeypadFive] = "Num5", [Enum.KeyCode.KeypadSix] = "Num6",
            [Enum.KeyCode.KeypadSeven] = "Num7", [Enum.KeyCode.KeypadEight] = "Num8",
            [Enum.KeyCode.KeypadNine] = "Num9", [Enum.KeyCode.KeypadZero] = "Num0",
            [Enum.KeyCode.Minus] = "-", [Enum.KeyCode.Equals] = "=",
            [Enum.KeyCode.Tilde] = "~", [Enum.KeyCode.LeftBracket] = "[",
            [Enum.KeyCode.RightBracket] = "]", [Enum.KeyCode.RightParenthesis] = ")",
            [Enum.KeyCode.LeftParenthesis] = "(", [Enum.KeyCode.Semicolon] = ",",
            [Enum.KeyCode.Quote] = "'", [Enum.KeyCode.BackSlash] = "\\",
            [Enum.KeyCode.Comma] = ",", [Enum.KeyCode.Period] = ".",
            [Enum.KeyCode.Slash] = "/", [Enum.KeyCode.Asterisk] = "*",
            [Enum.KeyCode.Plus] = "+", [Enum.KeyCode.Backquote] = "`",
            [Enum.UserInputType.MouseButton1] = "MB1",
            [Enum.UserInputType.MouseButton2] = "MB2",
            [Enum.UserInputType.MouseButton3] = "MB3"
        };
        Connections = {};
        FontSize = 12;
        VisValues = {};
        UIKey = Enum.KeyCode.Insert;
        Notifs = {};
    }

    local Flags = {}
    Library.__index = Library
    Library.Pages.__index = Library.Pages
    Library.Sections.__index = Library.Sections
    local LocalPlayer = game:GetService('Players').LocalPlayer
    local Mouse = LocalPlayer:GetMouse()
    local TweenService = game:GetService("TweenService")

    do
        function Library:Connection(signal, Callback) return signal:Connect(Callback) end
        function Library:Disconnect(Connection) Connection:Disconnect() end
        function Library:Round(Number, Float) return Float * math.floor(Number / Float) end
        function Library.NextFlag()
            Library.UnNamedFlags = Library.UnNamedFlags + 1
            return string.format("%.14g", Library.UnNamedFlags)
        end

        function Library:ApplyTheme(instance, rotation)
            rotation = rotation or 0
            instance.BackgroundColor3 = Color3.new(1, 1, 1)
            local gradient = Instance.new("UIGradient")
            gradient.Color = ColorSequence.new(Library.AccentGradient[1], Library.AccentGradient[2])
            gradient.Rotation = rotation
            gradient.Parent = instance
            table.insert(Library.ThemeObjects, gradient)
            return gradient
        end

        function Library:ApplyTextTheme(instance, rotation)
            rotation = rotation or 0
            instance.TextColor3 = Color3.new(1, 1, 1)
            local gradient = Instance.new("UIGradient")
            gradient.Color = ColorSequence.new(Library.AccentGradient[1], Library.AccentGradient[2])
            gradient.Rotation = rotation
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
                    if item:IsA("UIGradient") then item.Color = ColorSequence.new(Library.AccentGradient[1], Library.AccentGradient[2])
                    elseif item:IsA("Frame") or item:IsA("TextButton") then item.BackgroundColor3 = Library.Accent
                    elseif item:IsA("TextLabel") then item.TextColor3 = Library.Accent
                    elseif item:IsA("ScrollingFrame") then item.ScrollBarImageColor3 = Library.Accent end
                end
            end
        end

        function Library:IsMouseOverFrame(Frame)
            local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize
            if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then return true end
            return false
        end
    end

    --// Notifications
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

    --// Main Window / Pages / Sections
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

            Library:Connection(TextButton.MouseButton1Down, function()
                local Location = game:GetService("UserInputService"):GetMouseLocation()
                Window.Dragging[1] = true
                Window.Dragging[2] = UDim2.new(0, Location.X - Outline.AbsolutePosition.X, 0, Location.Y - Outline.AbsolutePosition.Y)
            end)
            Library:Connection(game:GetService("UserInputService").InputEnded, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then Window.Dragging[1] = false end
            end)
            Library:Connection(game:GetService("UserInputService").InputChanged, function()
                local Location = game:GetService("UserInputService"):GetMouseLocation()
                if Window.Dragging[1] then
                    TweenService:Create(Outline, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                        Position = UDim2.new(0, Location.X - Window.Dragging[2].X.Offset + (Outline.Size.X.Offset * Outline.AnchorPoint.X), 0, Location.Y - Window.Dragging[2].Y.Offset + (Outline.Size.Y.Offset * Outline.AnchorPoint.Y))
                    }):Play()
                end
            end)

            function Window:UpdateTabs()
                for _, Page in pairs(Window.Pages) do Page:Turn(Page.Open) end
            end

            Library:Connection(game:GetService("UserInputService").InputBegan, function(Inp)
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

        --// Nest (scrollable container)
        function Sections:Nest(Properties)
            if not Properties then Properties = {} end
            local Section = {
                Name = Properties.Name or "Section",
                RealSection = self,
                Size = Properties.size or Properties.Size or 200,
                Elements = {},
                Content = {},
            }

            local ScrollHolder = Instance.new("Frame", Section.RealSection.Elements.SectionContent)
            local NewScroll = Instance.new('ScrollingFrame', ScrollHolder)
            local UICorner2 = Instance.new('UICorner', ScrollHolder)
            local UIStroke = Instance.new('UIStroke', ScrollHolder)
            local ScrollContent = Instance.new('Frame', NewScroll)
            local UIListLayout = Instance.new('UIListLayout', ScrollContent)

            ScrollHolder.Size = Section.Size == "Fill" and UDim2.new(1, 0, 1, 0) or UDim2.new(1, 0, 0, Section.Size)
            ScrollHolder.BackgroundTransparency = 1
            ScrollHolder.BorderSizePixel = 0
            ScrollHolder.ClipsDescendants = true

            NewScroll.Size = UDim2.new(1, 0, 1, 0)
            NewScroll.BackgroundTransparency = 1
            NewScroll.BorderSizePixel = 0
            NewScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            NewScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            NewScroll.ScrollBarThickness = 4
            NewScroll.ScrollBarImageColor3 = Library.Accent
            NewScroll.TopImage = ""
            NewScroll.BottomImage = ""
            NewScroll.VerticalScrollBarInset = Enum.ScrollBarInset.Always
            NewScroll.ClipsDescendants = true
            table.insert(Library.ThemeObjects, NewScroll)

            ScrollContent.Position = UDim2.new(0, 6, 0, 5)
            ScrollContent.Size = UDim2.new(1, -12, 0, 0)
            ScrollContent.BackgroundTransparency = 1
            ScrollContent.AutomaticSize = Enum.AutomaticSize.Y

            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout.Padding = UDim.new(0, 6)

            Section.Elements = {SectionContent = ScrollContent}
            return setmetatable(Section, Library.Sections)
        end

        --// Toggle
        function Sections:Toggle(Properties)
            if not Properties then Properties = {} end
            local Toggle = {
                Window = self.Window, Page = self.Page, Section = self,
                Name = Properties.Name or "Toggle",
                State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or false),
                Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
                Flag = (Properties.flag or Properties.Flag or Properties.pointer or Properties.Pointer or Library.NextFlag()),
                Toggled = false,
            }

            local NewToggle = Instance.new('TextButton', Toggle.Section.Elements.SectionContent)
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

        --// Slider
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
                Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
                Flag = (Properties.flag or Properties.Flag or Properties.pointer or Properties.Pointer or Library.NextFlag()),
            }
            local TextValue = ("[value]" .. Slider.Sub)

            local NewSlider = Instance.new('TextButton', Slider.Section.Elements.SectionContent)
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
                value = math.clamp(Library:Round(value, Slider.Decimals), Slider.Min, Slider.Max)
                local sizeX = ((value - Slider.Min) / (Slider.Max - Slider.Min))
                TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(sizeX, 0, 1, 0)}):Play()
                SliderValue.Text = TextValue:gsub("%[value%]", string.format("%.14g", value))
                Library.Flags[Slider.Flag] = value; Slider.Callback(value)
            end
            local function Slide(input)
                local sizeX = (input.Position.X - NewSlider.AbsolutePosition.X) / NewSlider.AbsoluteSize.X
                Set(((Slider.Max - Slider.Min) * sizeX) + Slider.Min)
            end

            Library:Connection(NewSlider.InputBegan, function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = true; Slide(input) end end)
            Library:Connection(NewSlider.InputEnded, function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = false end end)
            Library:Connection(Fill.InputBegan, function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = true; Slide(input) end end)
            Library:Connection(Fill.InputEnded, function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = false end end)
            Library:Connection(game:GetService("UserInputService").InputChanged, function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement and Sliding then Slide(input) end
            end)

            function Slider:Set(Value) Set(Value) end
            Flags[Slider.Flag] = Set; Library.Flags[Slider.Flag] = Slider.State; Set(Slider.State)
            return Slider
        end

        --// Textbox
        function Sections:Textbox(Properties)
            Properties = Properties or {}
            local Textbox = {
                Window = self.Window, Page = self.Page, Section = self,
                Placeholder = (Properties.placeholder or Properties.Placeholder or Properties.holder or "Enter your text here"),
                State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or ""),
                Callback = (Properties.callback or Properties.Callback or function() end),
                Flag = (Properties.flag or Properties.Flag or Properties.pointer or Properties.Pointer or Library.NextFlag()),
            }
            local NewBox = Instance.new("Frame")
            NewBox.BackgroundTransparency = 1; NewBox.Size = UDim2.new(1, 0, 0, 24); NewBox.ZIndex = 54
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
            local function set(str) TextBox.Text = str; Library.Flags[Textbox.Flag] = str; Textbox.Callback(str) end
            Flags[Textbox.Flag] = set; Library.Flags[Textbox.Flag] = TextBox.Text
            return Textbox
        end

        --// Button
        function Sections:Button(Properties)
            Properties = Properties or {}
            local Button = {
                Window = self.Window, Page = self.Page, Section = self,
                Name = Properties.Name or "button",
                Callback = (Properties.callback or Properties.Callback or function() end),
            }
            local NewButton = Instance.new("TextButton")
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

        --// Watermark
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

    -- Info row builder
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

    -- LEFT: avatar
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

    -- RIGHT: info rows
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
    local LocalPlayer = Players.LocalPlayer

    local target = {
        selectedPlayer = nil,
        spectateActive = false,
        flingEnabled   = false,
        flingConn      = nil,
        originalCFrame = nil,
        spectateConn   = nil,
        headshot       = nil,
        headshotName   = nil,
        headshotUser   = nil,
        headshotId     = nil,
        statusLabel    = nil,
    }

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

    local target_left  = tab_target:Section({Name = "Target",  Side = "Left",  Size = "Fill"})
    local target_right = tab_target:Section({Name = "Preview", Side = "Right", Size = "Fill"})

    -- RIGHT: headshot + info rows (created first so textbox callback can update them)
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
    target.headshot = headshot

    local headshotCorner = Instance.new("UICorner", headshot); headshotCorner.CornerRadius = UDim.new(0, 10)

    local headshotStroke = Instance.new("UIStroke", headshot)
    headshotStroke.Thickness = 2; headshotStroke.Color = Color3.new(1, 1, 1)
    local strokeGradient = Instance.new("UIGradient", headshotStroke)
    strokeGradient.Color = ColorSequence.new(Soda.AccentGradient[1], Soda.AccentGradient[2])
    strokeGradient.Rotation = 45

    local function addTargetRow(parent, label, value, yOffset, order)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -16, 0, 34)
        row.Position = UDim2.new(0, 8, 0, yOffset)
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

    target.headshotName = addTargetRow(previewFrame, "Display Name", "None", 190, 2)
    target.headshotUser = addTargetRow(previewFrame, "Username",     "@---", 228, 3)
    target.headshotId   = addTargetRow(previewFrame, "User ID",      "---",  266, 4)

    -- LEFT: textbox
    local target_textbox = target_left:Textbox({
        Name = "Player",
        Flag = "target_player_input",
        Placeholder = "Partial name / @username...",
        Callback = function(text)
            local found = findPlayerByQuery(text)
            target.selectedPlayer = found

            if found then
                if target.statusLabel then
                    target.statusLabel.Text = "Selected: " .. found.DisplayName
                    target.statusLabel.TextColor3 = Color3.fromRGB(80, 220, 120)
                end
                target.headshotName.Text = found.DisplayName
                target.headshotUser.Text = "@" .. found.Name
                target.headshotId.Text   = tostring(found.UserId)

                task.spawn(function()
                    local ok, thumb = pcall(function()
                        return Players:GetUserThumbnailAsync(found.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
                    end)
                    if ok and thumb then target.headshot.Image = thumb end
                end)
            else
                if target.statusLabel then
                    target.statusLabel.Text = "Selected: None"
                    target.statusLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
                end
                target.headshotName.Text = "None"
                target.headshotUser.Text = "@---"
                target.headshotId.Text   = "---"
                target.headshot.Image = "rbxassetid://111122112"
            end
        end
    })

    -- LEFT: status row
    local statusRow = Instance.new("Frame")
    statusRow.Size = UDim2.new(1, 0, 0, 24)
    statusRow.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    statusRow.BorderSizePixel = 0
    statusRow.LayoutOrder = 99
    statusRow.Parent = target_left.Elements.SectionContent
    local statusCorner = Instance.new("UICorner", statusRow); statusCorner.CornerRadius = UDim.new(0, 4)
    local statusStroke = Instance.new("UIStroke", statusRow); statusStroke.Color = Color3.fromRGB(40, 40, 40); statusStroke.Thickness = 1

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -10, 1, 0); statusLabel.Position = UDim2.new(0, 5, 0, 0)
    statusLabel.BackgroundTransparency = 1; statusLabel.Text = "Selected: None"
    statusLabel.TextColor3 = Color3.fromRGB(200, 80, 80); statusLabel.FontFace = Soda.FontFace
    statusLabel.TextSize = 12; statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = statusRow
    target.statusLabel = statusLabel

    -- LEFT: Teleport button
    target_left:Button({
        Name = "Teleport",
        Callback = function()
            local tgt = target.selectedPlayer
            if not tgt then Soda:Notification("No target selected!", 2); return end
            local char  = LocalPlayer.Character
            local hrp   = char and char:FindFirstChild("HumanoidRootPart")
            local tChar = tgt.Character
            local tHrp  = tChar and tChar:FindFirstChild("HumanoidRootPart")
            if not hrp  then Soda:Notification("Your character is missing!", 2); return end
            if not tHrp then Soda:Notification("Target has no character!", 2); return end
            hrp.CFrame = tHrp.CFrame + Vector3.new(0, 3, 0)
            Soda:Notification("Teleported to " .. tgt.DisplayName, 2)
        end
    })

    -- LEFT: Spectate toggle
    target_left:Toggle({
        Name = "Spectate",
        Flag = "target_spectate",
        Callback = function(state)
            target.spectateActive = state
            local cam = workspace.CurrentCamera
            if target.spectateConn then target.spectateConn:Disconnect(); target.spectateConn = nil end
            if state then
                target.spectateConn = RunService.RenderStepped:Connect(function()
                    if not target.spectateActive then return end
                    local tgt = target.selectedPlayer
                    if tgt and tgt.Character then
                        local hum = tgt.Character:FindFirstChildOfClass("Humanoid")
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

    -- LEFT: Fling toggle
    local function setFling(enabled)
        target.flingEnabled = enabled

        if enabled then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then target.originalCFrame = hrp.CFrame end
            if target.flingConn then target.flingConn:Disconnect() end

            target.flingConn = RunService.Heartbeat:Connect(function()
                if not target.flingEnabled then
                    if target.flingConn then target.flingConn:Disconnect(); target.flingConn = nil end
                    return
                end

                local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local tgt = target.selectedPlayer

                if tgt and tgt.Character and myHrp then
                    local tHrp = tgt.Character:FindFirstChild("HumanoidRootPart")
                    local tHum = tgt.Character:FindFirstChildOfClass("Humanoid")
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

        if target.flingConn then target.flingConn:Disconnect(); target.flingConn = nil end
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            pcall(function() sethiddenproperty(hrp, "PhysicsRepRootPart", nil) end)
            if target.originalCFrame then hrp.CFrame = target.originalCFrame; target.originalCFrame = nil end
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end

    target_left:Toggle({
        Name = "Fling",
        Flag = "target_fling",
        Callback = function(state) setFling(state) end
    })

    -- Auto-clear on leave
    Players.PlayerRemoving:Connect(function(plr)
        if target.selectedPlayer == plr then
            target.selectedPlayer = nil
            target.headshotName.Text = "None"
            target.headshotUser.Text = "@---"
            target.headshotId.Text   = "---"
            target.headshot.Image = "rbxassetid://111122112"
            statusLabel.Text = "Selected: None"
            statusLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
        end
    end)

    -- Refresh every 2s
    task.spawn(function()
        while task.wait(2) do
            local tgt = target.selectedPlayer
            if tgt then
                target.headshotName.Text = tgt.DisplayName
                target.headshotUser.Text = "@" .. tgt.Name
                target.headshotId.Text   = tostring(tgt.UserId)
                statusLabel.Text = "Selected: " .. tgt.DisplayName
            end
        end
    end)
end

--====================================================================
-- PLAYER CHARACTER — Services + State
--====================================================================
local PC_Players    = game:GetService("Players")
local PC_RunService = game:GetService("RunService")
local PC_Local      = PC_Players.LocalPlayer
local PC_RS         = game:GetService("ReplicatedStorage")
local PC_TCS        = game:GetService("TextChatService")

local pc = {
    antiPepperConn    = nil,
    antiStompConn     = nil,
    wasKnocked        = false,
    autoEatConn       = nil,
    autoEatBusy       = false,
    noclipConn        = nil,
    noJumpConn        = nil,
    antiGrabConn      = nil,
    antiGrabEnabled   = false,
    cashAuraEnabled   = false,
    cashAuraRadius    = 20,
    cashAuraDelay     = 0.5,
    godBlockEnabled   = false,
    godBlockConn      = nil,
    autoReloadConn    = nil,
    autoReloadEnabled = false,
    chatSpamTrashTalk = false,
    chatSpamLastTime  = 0,
    chatSpamIndex     = 1,
    chatSpamDelay     = 3,
    trashTalkList = {
        "imagine getting cracked by Soda.Fun 💀", "Soda.Fun", "get better buddy", "skill issue",
        "get Soda.Fun today", "stop 😂", "free script btw", "mad?", "cry about it", "trash",
        "noob lol", "owned by Soda.Fun", "get rekt", "you're bad", "stay mad with no Soda.Fun",
        "no Soda.Fun = no skill", "washed", "dogwater", "200 pumped by Soda.Fun"
    }
}

PC_Local.CharacterAdded:Connect(function() pc.wasKnocked = false end)

--====================================================================
-- PLAYER CHARACTER — Section with Scroll + 14 Toggles
--====================================================================
local player_char_section = tab_player:Section({
    Name = "Player Character",
    Side = "Left",
    Size = "Fill"
})

-- Nest = scrollable container
local pc_scroll = player_char_section:Nest({Size = "Fill"})

-- 1. Anti stomp
pc_scroll:Toggle({
    Name = "Anti stomp",
    Flag = "pc_anti_stomp",
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

-- 2. Anti slow
pc_scroll:Toggle({
    Name = "Anti slow",
    Flag = "pc_anti_slow",
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

-- 3. Anti grab
pc_scroll:Toggle({
    Name = "Anti grab",
    Flag = "pc_anti_grab",
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

-- 4. Anti Seat
pc_scroll:Toggle({
    Name = "Anti Seat",
    Flag = "pc_anti_seat",
    Callback = function(state)
        for _, s in ipairs(workspace:GetDescendants()) do
            if s:IsA("Seat") then s.Disabled = state end
        end
    end
})

-- 5. Anti pepperspray
pc_scroll:Toggle({
    Name = "Anti pepperspray",
    Flag = "pc_anti_pepperspray",
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

-- 6. Auto Eat [Taco]
pc_scroll:Toggle({
    Name = "Auto Eat [Taco]",
    Flag = "pc_auto_eat_taco",
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

-- 7. Chat Spy
pc_scroll:Toggle({
    Name = "Chat Spy",
    Flag = "pc_chat_spy",
    Callback = function(state)
        if PC_TCS.ChatWindowConfiguration then
            PC_TCS.ChatWindowConfiguration.Enabled = state
        end
    end
})

-- 8. Noclip
pc_scroll:Toggle({
    Name = "Noclip",
    Flag = "pc_noclip",
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

-- 9. No jump cooldown
pc_scroll:Toggle({
    Name = "No jump cooldown",
    Flag = "pc_no_jump_cooldown",
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

-- 10. Trash Talk
pc_scroll:Toggle({
    Name = "Trash Talk",
    Flag = "pc_trash_talk",
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
                        local channel = PC_TCS.TextChannels:FindFirstChild("RBXGeneral")
                            or PC_TCS.TextChannels:FindFirstChildOfClass("TextChannel")
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

-- 11. God Block
pc_scroll:Toggle({
    Name = "God Block",
    Flag = "pc_god_block",
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
                    if tool and tool:FindFirstChild("Ammo") then
                        PC_RS.MainEvent:FireServer("Block", false)
                        return
                    end
                    PC_RS.MainEvent:FireServer("Block", true)
                    task.wait(0.2)
                    PC_RS.MainEvent:FireServer("Block", false)
                end
            end)
        end
    end
})

-- 12. Auto block
pc_scroll:Toggle({
    Name = "Auto block",
    Flag = "pc_auto_block",
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
                            local attacking = other.BodyEffects:FindFirstChild("Attacking")
                                and other.BodyEffects.Attacking.Value
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

-- 13. Cash aura
pc_scroll:Toggle({
    Name = "Cash aura",
    Flag = "pc_cash_aura",
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

-- 14. Auto reload
pc_scroll:Toggle({
    Name = "Auto reload",
    Flag = "pc_auto_reload",
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

--====================================================================
-- FLOATING TOGGLE BUTTON (Open/Close GUI)
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

local toggleCorner = Instance.new("UICorner", toggle_btn)
toggleCorner.CornerRadius = UDim.new(0, 6)

local toggleStroke = Instance.new("UIStroke", toggle_btn)
toggleStroke.Color = Color3.fromRGB(60, 60, 60)

local toggleGradient = Instance.new("UIGradient", toggle_btn)
toggleGradient.Color = ColorSequence.new(Color3.fromRGB(255, 20, 80), Color3.fromRGB(60, 120, 255))
toggleGradient.Rotation = 0

toggle_btn.MouseButton1Click:Connect(function()
    Soda:SetOpen(not Soda.Open)
end)

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
