--[[
    Soda.Fun — UI Library & Client
    Original base by Linemaster — rebranded, restyled, and refactored
    Font: Montserrat Bold | Accent: Red → Blue gradient
]]

--====================================================================
-- SAFE DRAWING LOADER (won't crash if URL fails)
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
    -- Font
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
        DropdownOpen = false,
        OptionListOpen = false,
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

        function Library:GetConfig()
            local Config = ""
            for Index, Value in pairs(self.Flags) do
                if Index ~= "ConfigConfig_List" and Index ~= "ConfigConfig_Load" and Index ~= "ConfigConfig_Save" then
                    local Value2 = Value
                    local Final = ""
                    if typeof(Value2) == "Color3" then
                        local h, s, v = Value2:ToHSV()
                        Final = ("rgb(%s,%s,%s,%s)"):format(h, s, v, 1)
                    elseif typeof(Value2) == "boolean" then
                        Final = ("bool(%s)"):format(tostring(Value2))
                    elseif typeof(Value2) == "table" then
                        Final = "table(" .. table.concat(Value2, ",") .. ")"
                    elseif typeof(Value2) == "string" then
                        Final = ("string(%s)"):format(Value2)
                    elseif typeof(Value2) == "number" then
                        Final = ("number(%s)"):format(Value2)
                    end
                    if Final ~= "" then Config = Config .. Index .. ": " .. tostring(Final) .. "\n" end
                end
            end
            return Config
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

            function Toggle:OptionList()
                local Section = {Elements = {}, Content = {}}
                local OptionButton = Instance.new('ImageButton', NewToggle)
                local OptionList = Instance.new('Frame', OptionButton)
                local OptionContent = Instance.new('Frame', OptionList)
                local UIListLayout = Instance.new('UIListLayout', OptionContent)

                OptionButton.Position = UDim2.new(1, -65, 0, 1); OptionButton.Size = UDim2.new(0, 15, 0, 15)
                OptionButton.BackgroundTransparency = 1; OptionButton.BorderSizePixel = 0
                OptionButton.Image = "http://www.roblox.com/asset/?id=6031280882"; OptionButton.ImageColor3 = Color3.new(0.7843, 0.7843, 0.7843); OptionButton.ZIndex = 54
                local UICorner = Instance.new('UICorner', OptionList)

                OptionList.Position = UDim2.new(0, 70, 0, -10); OptionList.Size = UDim2.new(0, 200, 0, 10)
                OptionList.BackgroundColor3 = Color3.new(0.0784314, 0.0784314, 0.0784314); OptionList.BorderSizePixel = 0
                OptionList.AutomaticSize = Enum.AutomaticSize.Y; OptionList.Visible = false; OptionList.ZIndex = 54
                local UIStroke = Instance.new('UIStroke', OptionList); UIStroke.Color = Color3.new(0.137255, 0.137255, 0.137255)

                OptionContent.Position = UDim2.new(0, 10, 0, 10); OptionContent.Size = UDim2.new(1, -20, 1, -10)
                OptionContent.BackgroundTransparency = 1; OptionContent.AutomaticSize = Enum.AutomaticSize.Y; OptionContent.ZIndex = 54
                UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder; UIListLayout.Padding = UDim.new(0, 4)

                Library:Connection(OptionButton.MouseButton1Click, function()
                    local State = not OptionList.Visible; OptionList.Visible = State; Library.OptionListOpen = State
                end)
                Library:Connection(game:GetService("UserInputService").InputBegan, function(Input)
                    if Library.DropdownOpen then return end
                    if OptionList.Visible and Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if not Library:IsMouseOverFrame(OptionList) and not Library:IsMouseOverFrame(OptionButton) then OptionList.Visible = false end
                    end
                end)
                Section.Elements = {SectionContent = OptionContent}
                return setmetatable(Section, Library.Sections)
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

        --// Dropdown
        function Sections:List(Properties)
            Properties = Properties or {}
            local Dropdown = {
                Window = self.Window, Page = self.Page, Section = self,
                Name = Properties.Name or Properties.name,
                Options = (Properties.options or Properties.Options or {"1", "2", "3"}),
                Max = (Properties.Max or Properties.max),
                State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default),
                Callback = (Properties.callback or Properties.Callback or function() end),
                Flag = (Properties.flag or Properties.Flag or Properties.pointer or Properties.Pointer or Library.NextFlag()),
                OptionInsts = {},
            }
            local NewDropdown = Instance.new('Frame', Dropdown.Section.Elements.SectionContent)
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

            Library:Connection(game:GetService("UserInputService").InputBegan, function(Input)
                if ToggleContent.Visible and Input.UserInputType == Enum.UserInputType.MouseButton1 then
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

        --// Keybind
        function Sections:Keybind(Properties)
            Properties = Properties or {}
            local Keybind = {
                Section = self,
                Name = Properties.name or Properties.Name or "Keybind",
                State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or Enum.KeyCode.E),
                Mode = (Properties.mode or Properties.Mode or "Toggle"),
                UseKey = (Properties.UseKey or false),
                Callback = (Properties.callback or Properties.Callback or function() end),
                Flag = (Properties.flag or Properties.Flag or Properties.pointer or Properties.Pointer or Library.NextFlag()),
                Binding = nil,
            }
            local Key; local State = false
            local NewKey = Instance.new("TextButton")
            NewKey.FontFace = Library.FontFace; NewKey.Text = ""; NewKey.TextSize = 14
            NewKey.AutoButtonColor = false; NewKey.BackgroundTransparency = 1
            NewKey.Size = UDim2.new(1, 0, 0, 17); NewKey.ZIndex = 54; NewKey.Parent = Keybind.Section.Elements.SectionContent

            local ToggleTitle = Instance.new("TextLabel")
            ToggleTitle.FontFace = Library.FontFace; ToggleTitle.Text = Keybind.Name
            ToggleTitle.TextColor3 = Color3.fromRGB(200, 200, 200); ToggleTitle.TextSize = 13
            ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left; ToggleTitle.BackgroundTransparency = 1
            ToggleTitle.Size = UDim2.new(1, -10, 0, 17); ToggleTitle.Parent = NewKey

            local KeyText = Instance.new("TextLabel")
            KeyText.FontFace = Library.FontFace; KeyText.Text = "None"
            KeyText.TextColor3 = Color3.fromRGB(200, 200, 200); KeyText.TextSize = 13
            KeyText.TextXAlignment = Enum.TextXAlignment.Right; KeyText.BackgroundTransparency = 1
            KeyText.Position = UDim2.new(1, -180, 0, 0); KeyText.Size = UDim2.new(1, -10, 0, 17); KeyText.Parent = NewKey

            local c
            local function set(newkey)
                if string.find(tostring(newkey), "Enum") then
                    if c then c:Disconnect(); if Keybind.Flag then Library.Flags[Keybind.Flag] = false end; Keybind.Callback(false) end
                    if tostring(newkey):find("Enum.KeyCode.") then newkey = Enum.KeyCode[tostring(newkey):gsub("Enum.KeyCode.", "")]
                    elseif tostring(newkey):find("Enum.UserInputType.") then newkey = Enum.UserInputType[tostring(newkey):gsub("Enum.UserInputType.", "")] end
                    if newkey == Enum.KeyCode.Backspace then
                        Key = nil
                        if Keybind.UseKey then if Keybind.Flag then Library.Flags[Keybind.Flag] = Key end; Keybind.Callback(Key) end
                        KeyText.Text = "None"
                    elseif newkey ~= nil then
                        Key = newkey
                        if Keybind.UseKey then if Keybind.Flag then Library.Flags[Keybind.Flag] = Key end; Keybind.Callback(Key) end
                        KeyText.Text = (Library.Keys[newkey] or tostring(newkey):gsub("Enum.KeyCode.", ""))
                    end
                    Library.Flags[Keybind.Flag .. "_KEY"] = newkey
                elseif table.find({"Always", "Toggle", "Hold"}, newkey) then
                    if not Keybind.UseKey then
                        Library.Flags[Keybind.Flag .. "_KEY STATE"] = newkey; Keybind.Mode = newkey
                        if Keybind.Mode == "Always" then State = true; if Keybind.Flag then Library.Flags[Keybind.Flag] = State end; Keybind.Callback(true) end
                    end
                else
                    State = newkey; if Keybind.Flag then Library.Flags[Keybind.Flag] = newkey end; Keybind.Callback(newkey)
                end
            end

            set(Keybind.State); set(Keybind.Mode)

            NewKey.MouseButton1Click:Connect(function()
                if not Keybind.Binding then
                    KeyText.Text = "..."
                    TweenService:Create(KeyText, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                    Keybind.Binding = Library:Connection(game:GetService("UserInputService").InputBegan, function(input, gpe)
                        if gpe then return end
                        if input.UserInputType == Enum.UserInputType.Touch then return end
                        set(input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType)
                        Library:Disconnect(Keybind.Binding); task.wait(); Keybind.Binding = nil
                        TweenService:Create(KeyText, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
                    end)
                end
            end)

            Library:Connection(game:GetService("UserInputService").InputBegan, function(inp, gpe)
                if gpe then return end
                if (inp.KeyCode == Key or inp.UserInputType == Key) and not Keybind.Binding and not Keybind.UseKey then
                    if Keybind.Mode == "Hold" then
                        if Keybind.Flag then Library.Flags[Keybind.Flag] = true end
                        c = Library:Connection(game:GetService("RunService").RenderStepped, function() Keybind.Callback(true) end)
                    elseif Keybind.Mode == "Toggle" then
                        State = not State; if Keybind.Flag then Library.Flags[Keybind.Flag] = State end; Keybind.Callback(State)
                    end
                end
            end)

            Library:Connection(game:GetService("UserInputService").InputEnded, function(inp, gpe)
                if gpe then return end
                if Keybind.Mode == "Hold" and not Keybind.UseKey then
                    if inp.KeyCode == Key or inp.UserInputType == Key then
                        if c then c:Disconnect(); if Keybind.Flag then Library.Flags[Keybind.Flag] = false end; Keybind.Callback(false) end
                    end
                end
            end)

            Library.Flags[Keybind.Flag .. "_KEY"] = Keybind.State
            Library.Flags[Keybind.Flag .. "_KEY STATE"] = Keybind.Mode
            Flags[Keybind.Flag] = set; Flags[Keybind.Flag .. "_KEY"] = set; Flags[Keybind.Flag .. "_KEY STATE"] = set
            function Keybind:Set(key) set(key) end
            return Keybind
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

PC_Local.CharacterAdded:Connect(function()
    pc.wasKnocked = false
end)

--====================================================================
-- PLAYER CHARACTER — Section + Toggles
--====================================================================
local player_char_section = tab_player:Section({
    Name = "Player Character",
    Side = "Left",
    Size = "Fill"
})

-- 1. Anti stomp
player_char_section:Toggle({
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
player_char_section:Toggle({
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
player_char_section:Toggle({
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
                    hum:ChangeState(Enum.HumanoidStateType.Physics)
                    task.wait()
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    task.wait()
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end
            end)
        end
    end
})

-- 4. Anti Seat
player_char_section:Toggle({
    Name = "Anti Seat",
    Flag = "pc_anti_seat",
    Callback = function(state)
        for _, s in ipairs(workspace:GetDescendants()) do
            if s:IsA("Seat") then s.Disabled = state end
        end
    end
})

-- 5. Anti pepperspray
player_char_section:Toggle({
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
player_char_section:Toggle({
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
player_char_section:Toggle({
    Name = "Chat Spy",
    Flag = "pc_chat_spy",
    Callback = function(state)
        if PC_TCS.ChatWindowConfiguration then
            PC_TCS.ChatWindowConfiguration.Enabled = state
        end
    end
})

-- 8. Noclip
player_char_section:Toggle({
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
player_char_section:Toggle({
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
player_char_section:Toggle({
    Name = "Trash Talk",
    Flag = "pc_trash_talk",
    Callback = function(state)
        pc.chatSpamTrashTalk = state
    end
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
player_char_section:Toggle({
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
player_char_section:Toggle({
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
player_char_section:Toggle({
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
player_char_section:Toggle({
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
