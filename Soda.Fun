--[[
    Soda.Fun — UI Library
    Rebranded & Restyled (Montserrat Bold + Red/Blue Gradient)
]]

--// Safe Drawing loader (won't crash if URL fails)
local Drawing
do
    local ok, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/linemaster2/storage/main/Drawing.lua"))()
    end)
    if ok and result then
        Drawing = result
    else
        warn("[Soda.Fun] Drawing library failed to load - using stub.")
        Drawing = {
            new = function()
                return setmetatable({}, {
                    __index = function() return nil end,
                    __newindex = function() end
                })
            end
        }
    end
end

local Library = {}
do
    --// Font (Montserrat Bold, with fallback)
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
            [Enum.KeyCode.Space] = "Space",
            [Enum.KeyCode.Return] = "Return",
            [Enum.KeyCode.LeftShift] = "LShift",
            [Enum.KeyCode.RightShift] = "RShift",
            [Enum.KeyCode.LeftControl] = "LCtrl",
            [Enum.KeyCode.RightControl] = "RCtrl",
            [Enum.KeyCode.LeftAlt] = "LAlt",
            [Enum.KeyCode.RightAlt] = "RAlt",
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
            [Enum.KeyCode.Minus] = "-",
            [Enum.KeyCode.Equals] = "=",
            [Enum.KeyCode.Tilde] = "~",
            [Enum.KeyCode.LeftBracket] = "[",
            [Enum.KeyCode.RightBracket] = "]",
            [Enum.KeyCode.RightParenthesis] = ")",
            [Enum.KeyCode.LeftParenthesis] = "(",
            [Enum.KeyCode.Semicolon] = ",",
            [Enum.KeyCode.Quote] = "'",
            [Enum.KeyCode.BackSlash] = "\\",
            [Enum.KeyCode.Comma] = ",",
            [Enum.KeyCode.Period] = ".",
            [Enum.KeyCode.Slash] = "/",
            [Enum.KeyCode.Asterisk] = "*",
            [Enum.KeyCode.Plus] = "+",
            [Enum.KeyCode.Backquote] = "`",
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
    local ColorHolders = {}

    Library.__index = Library
    Library.Pages.__index = Library.Pages
    Library.Sections.__index = Library.Sections
    local LocalPlayer = game:GetService('Players').LocalPlayer;
    local Mouse = LocalPlayer:GetMouse();
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")

    --// Misc functions
    do
        function Library:Connection(signal, Callback)
            return signal:Connect(Callback)
        end
        function Library:Disconnect(Connection)
            Connection:Disconnect()
        end
        function Library:Round(Number, Float)
            return Float * math.floor(Number / Float)
        end
        function Library.NextFlag()
            Library.UnNamedFlags = Library.UnNamedFlags + 1
            return string.format("%.14g", Library.UnNamedFlags)
        end

        --// Apply gradient to a frame + register for theme updates
        function Library:ApplyTheme(instance, rotation)
            rotation = rotation or 0
            instance.BackgroundColor3 = Color3.new(1, 1, 1)
            local gradient = Instance.new("UIGradient")
            gradient.Name = "SodaGradient"
            gradient.Color = ColorSequence.new(Library.AccentGradient[1], Library.AccentGradient[2])
            gradient.Rotation = rotation
            gradient.Parent = instance
            table.insert(Library.ThemeObjects, gradient)
            return gradient
        end

        --// Apply gradient to text label's text color (works on modern Roblox)
        function Library:ApplyTextTheme(instance, rotation)
            rotation = rotation or 0
            instance.TextColor3 = Color3.new(1, 1, 1)
            local gradient = Instance.new("UIGradient")
            gradient.Name = "SodaTextGradient"
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
                        local hue, sat, val = Value2:ToHSV()
                        Final = ("rgb(%s,%s,%s,%s)"):format(hue, sat, val, 1)
                    elseif typeof(Value2) == "table" and Value2.Color and Value2.Transparency then
                        local hue, sat, val = Value2.Color:ToHSV()
                        Final = ("rgb(%s,%s,%s,%s)"):format(hue, sat, val, Value2.Transparency)
                    elseif typeof(Value2) == "table" and Value.Mode then
                        local Values = Value.current
                        Final = ("key(%s,%s,%s)"):format(Values[1] or "nil", Values[2] or "nil", Value.Mode)
                    elseif Value2 ~= nil then
                        if typeof(Value2) == "boolean" then
                            Value2 = ("bool(%s)"):format(tostring(Value2))
                        elseif typeof(Value2) == "table" then
                            local New = "table("
                            for Index2, Value3 in pairs(Value2) do
                                New = New .. Value3 .. ","
                            end
                            if New:sub(#New) == "," then New = New:sub(0, #New - 1) end
                            Value2 = New .. ")"
                        elseif typeof(Value2) == "string" then
                            Value2 = ("string(%s)"):format(Value2)
                        elseif typeof(Value2) == "number" then
                            Value2 = ("number(%s)"):format(Value2)
                        end
                        Final = Value2
                    end
                    Config = Config .. Index .. ": " .. tostring(Final) .. "\n"
                end
            end
            return Config
        end

        function Library:LoadConfig(Config)
            local Table = string.split(Config, "\n")
            local Table2 = {}
            for Index, Value in pairs(Table) do
                local Table3 = string.split(Value, ":")
                if Table3[1] ~= "ConfigConfig_List" and #Table3 >= 2 then
                    local Value = Table3[2]:sub(2, #Table3[2])
                    if Value:sub(1, 3) == "rgb" then
                        local Table4 = string.split(Value:sub(5, #Value - 1), ",")
                        Value = Table4
                    elseif Value:sub(1, 3) == "key" then
                        local Table4 = string.split(Value:sub(5, #Value - 1), ",")
                        if Table4[1] == "nil" and Table4[2] == "nil" then
                            Table4[1] = nil; Table4[2] = nil
                        end
                        Value = Table4
                    elseif Value:sub(1, 4) == "bool" then
                        Value = Value:sub(6, #Value - 1) == "true"
                    elseif Value:sub(1, 5) == "table" then
                        Value = string.split(Value:sub(7, #Value - 1), ",")
                    elseif Value:sub(1, 6) == "string" then
                        Value = Value:sub(8, #Value - 1)
                    elseif Value:sub(1, 6) == "number" then
                        Value = tonumber(Value:sub(8, #Value - 1))
                    end
                    Table2[Table3[1]] = Value
                end
            end
            for i, v in pairs(Table2) do
                if Flags[i] then
                    if typeof(Flags[i]) == "table" then
                        Flags[i]:Set(v)
                    else
                        Flags[i](v)
                    end
                end
            end
        end

        function Library:SetOpen(bool)
            if typeof(bool) == 'boolean' then
                Library.Open = bool;
                if Library.Open then
                    Library.Holder.Visible = true
                    TweenService:Create(Library.Holder, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, Library.OldSize.X.Offset,0,Library.OldSize.Y.Offset)}):Play()
                else
                    TweenService:Create(Library.Holder, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0,0,20)}):Play()
                    task.wait(0.25)
                    Library.Holder.Visible = false
                end
            end
        end;

        function Library:ChangeAccent(Color1, Color2)
            if typeof(Color1) == "table" then
                Library.AccentGradient = {Color1[1], Color1[2] or Color1[1]}
            elseif typeof(Color1) == "Color3" and typeof(Color2) == "Color3" then
                Library.AccentGradient = {Color1, Color2}
            elseif typeof(Color1) == "Color3" then
                Library.AccentGradient = {Color1, Color1}
            else
                return
            end
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
            local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize;
            if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X
                and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then
                return true;
            end;
            return false;
        end;
    end

    --// Colorpicker
    do
        function Library:NewPicker(name, default, parent, count, flag, callback)
            local ColorpickerFrame = Instance.new("TextButton")
            ColorpickerFrame.BackgroundColor3 = default
            ColorpickerFrame.BorderSizePixel = 0
            if count == 1 then
                ColorpickerFrame.Position = UDim2.new(1, -(count * 20), 0.5, 0)
            else
                ColorpickerFrame.Position = UDim2.new(1, -(count * 20) - (count * 4), 0.5, 0)
            end
            ColorpickerFrame.Size = UDim2.new(0, 20, 0, 20)
            ColorpickerFrame.AnchorPoint = Vector2.new(0, 0.5)
            ColorpickerFrame.Text = ""
            ColorpickerFrame.AutoButtonColor = false

            local UICorner = Instance.new("UICorner", ColorpickerFrame)
            UICorner.CornerRadius = UDim.new(0, 4)

            local UIStroke = Instance.new("UIStroke", ColorpickerFrame)
            UIStroke.Color = Color3.fromRGB(40, 40, 40)

            ColorpickerFrame.Parent = parent

            local Colorpicker = Instance.new("TextButton")
            Colorpicker.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            Colorpicker.BorderSizePixel = 0
            Colorpicker.Position = UDim2.new(0, ColorpickerFrame.AbsolutePosition.X - 100, 0, ColorpickerFrame.AbsolutePosition.Y - 50)
            Colorpicker.Size = UDim2.new(0, 180, 0, 180)
            Colorpicker.Parent = Library.ScreenGUI
            Colorpicker.ZIndex = 100
            Colorpicker.Visible = false
            Colorpicker.Text = ""
            Colorpicker.AutoButtonColor = false

            local H = default:ToHSV()
            local ImageLabel = Instance.new("ImageLabel")
            ImageLabel.Image = "rbxassetid://11970108040"
            ImageLabel.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
            ImageLabel.BorderSizePixel = 0
            ImageLabel.Position = UDim2.new(0.0556, 0, 0.026, 0)
            ImageLabel.Size = UDim2.new(0, 160, 0, 154)
            ImageLabel.Parent = Colorpicker

            local UICorner = Instance.new("UICorner", Colorpicker)
            UICorner.CornerRadius = UDim.new(0, 6)

            local ImageButton = Instance.new("ImageButton")
            ImageButton.Image = "rbxassetid://14684562507"
            ImageButton.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
            ImageButton.BorderSizePixel = 0
            ImageButton.Position = UDim2.new(0.056, 0, 0.026, 0)
            ImageButton.Size = UDim2.new(0, 160, 0, 154)
            ImageButton.AutoButtonColor = false

            local SVSlider = Instance.new("Frame")
            SVSlider.BackgroundTransparency = 1
            SVSlider.ClipsDescendants = true
            SVSlider.Position = UDim2.new(0.855, 0, 0.0966, 0)
            SVSlider.Size = UDim2.new(0, 7, 0, 7)
            SVSlider.ZIndex = 3

            local Val = Instance.new("ImageLabel")
            Val.Image = "http://www.roblox.com/asset/?id=14684563800"
            Val.BackgroundTransparency = 1
            Val.BorderSizePixel = 0
            Val.Size = UDim2.new(1, 0, 1, 0)
            Val.Parent = ImageButton

            local UICorner1 = Instance.new("UICorner", SVSlider)
            UICorner1.CornerRadius = UDim.new(0, 100)

            local UIStroke = Instance.new("UIStroke", SVSlider)
            UIStroke.Color = Color3.fromRGB(255, 255, 255)

            SVSlider.Parent = ImageButton
            ImageButton.Parent = Colorpicker

            local ImageButton1 = Instance.new("ImageButton")
            ImageButton1.Image = "http://www.roblox.com/asset/?id=16789872274"
            ImageButton1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ImageButton1.BorderSizePixel = 0
            ImageButton1.Position = UDim2.new(0.5, 0, 0, 165)
            ImageButton1.Size = UDim2.new(0, 160, 0, 8)
            ImageButton1.AutoButtonColor = false
            ImageButton1.AnchorPoint = Vector2.new(0.5, 0)
            ImageButton1.BackgroundTransparency = 1

            local Frame = Instance.new("Frame")
            Frame.BackgroundColor3 = Color3.fromRGB(254, 254, 254)
            Frame.BorderSizePixel = 0
            Frame.Position = UDim2.new(0.926, 0, 0.5, 0)
            Frame.Size = UDim2.new(0, 12, 0, 12)
            Frame.AnchorPoint = Vector2.new(0, 0.5)
            Frame.ZIndex = 45

            local UICorner2 = Instance.new("UICorner", Frame)
            UICorner2.CornerRadius = UDim.new(1, 0)

            local UICorner3 = Instance.new("UICorner", ImageButton1)

            Frame.Parent = ImageButton1
            ImageButton1.Parent = Colorpicker

            local hue, sat, val = default:ToHSV()
            local hsv = default:ToHSV()
            local slidingsaturation = false
            local slidinghue = false

            local function update()
                local real_pos = game:GetService("UserInputService"):GetMouseLocation()
                local mouse_position = Vector2.new(real_pos.X, real_pos.Y - 30)
                local relative_palette = (mouse_position - ImageButton.AbsolutePosition)
                local relative_hue = (mouse_position - ImageButton1.AbsolutePosition)
                if slidingsaturation then
                    sat = math.clamp(1 - relative_palette.X / ImageButton.AbsoluteSize.X, 0, 1)
                    val = math.clamp(1 - relative_palette.Y / ImageButton.AbsoluteSize.Y, 0, 1)
                elseif slidinghue then
                    hue = math.clamp(relative_hue.X / ImageButton.AbsoluteSize.X, 0, 1)
                end
                hsv = Color3.fromHSV(hue, sat, val)
                TweenService:Create(SVSlider, TweenInfo.new(0.05), {Position = UDim2.new(math.clamp(1 - sat, 0.000, 1 - 0.055), 0, math.clamp(1 - val, 0.000, 1 - 0.045), 0)}):Play()
                ImageButton.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                ColorpickerFrame.BackgroundColor3 = hsv
                TweenService:Create(Frame, TweenInfo.new(0.05), {Position = UDim2.new(math.clamp(hue, 0.000, 0.982), -5, 0.5, 0)}):Play()
                if flag then
                    Library.Flags[flag] = Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255)
                end
                callback(Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255))
            end

            local function set(color)
                if type(color) == "table" then color = Color3.fromHSV(color[1], color[2], color[3]) end
                if type(color) == "string" then color = Color3.fromHex(color) end
                local oldcolor = hsv
                hue, sat, val = color:ToHSV()
                hsv = Color3.fromHSV(hue, sat, val)
                if hsv ~= oldcolor then
                    ColorpickerFrame.BackgroundColor3 = hsv
                    TweenService:Create(SVSlider, TweenInfo.new(0.05), {Position = UDim2.new(math.clamp(1 - sat, 0.000, 1 - 0.055), 0, math.clamp(1 - val, 0.000, 1 - 0.045), 0)}):Play()
                    ImageButton.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    TweenService:Create(Frame, TweenInfo.new(0.05), {Position = UDim2.new(math.clamp(hue, 0.000, 0.982), -5, 0.5, 0)}):Play()
                    if flag then
                        Library.Flags[flag] = Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255)
                    end
                    callback(Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255))
                end
            end

            Flags[flag] = set
            set(default)

            ImageButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    slidingsaturation = true; update()
                end
            end)
            ImageButton.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    slidingsaturation = false; update()
                end
            end)
            ImageButton1.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    slidinghue = true; update()
                end
            end)
            ImageButton1.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    slidinghue = false; update()
                end
            end)

            Library:Connection(game:GetService("UserInputService").InputChanged, function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    if slidinghue then update() end
                    if slidingsaturation then update() end
                end
            end)

            local colorpickertypes = {}
            function colorpickertypes:Set(color, newalpha) set(color, newalpha) end

            Library:Connection(game:GetService("UserInputService").InputBegan, function(Input)
                if Colorpicker.Visible and Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if not Library:IsMouseOverFrame(Colorpicker) and not Library:IsMouseOverFrame(ColorpickerFrame) then
                        TweenService:Create(Colorpicker, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play()
                        task.spawn(function()
                            task.wait(0.1)
                            Colorpicker.Visible = false
                            parent.ZIndex = 1
                        end)
                        for _, V in next, Colorpicker:GetDescendants() do
                            if V:IsA("Frame") or V:IsA("TextButton") then
                                TweenService:Create(V, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play()
                            elseif V:IsA("TextLabel") or V:IsA("TextBox") then
                                TweenService:Create(V, TweenInfo.new(0.1), {TextTransparency = 1}):Play()
                            elseif V:IsA("ImageLabel") or V:IsA("ImageButton") then
                                TweenService:Create(V, TweenInfo.new(0.1), {ImageTransparency = 1}):Play()
                            elseif V:IsA("UIStroke") then
                                TweenService:Create(V, TweenInfo.new(0.1), {Transparency = 1}):Play()
                            end
                        end
                    end
                end
            end)

            ColorpickerFrame.MouseButton1Down:Connect(function()
                if Colorpicker.Visible == false then
                    Colorpicker.Position = UDim2.new(0, ColorpickerFrame.AbsolutePosition.X - 100, 0, ColorpickerFrame.AbsolutePosition.Y)
                    TweenService:Create(Colorpicker, TweenInfo.new(0.25), {Position = UDim2.new(0, ColorpickerFrame.AbsolutePosition.X - 100, 0, ColorpickerFrame.AbsolutePosition.Y + 25)}):Play()
                end
                Colorpicker.Visible = true
                parent.ZIndex = 100
                TweenService:Create(Colorpicker, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play()
                for _, V in next, Colorpicker:GetDescendants() do
                    if V:IsA("Frame") or V:IsA("TextButton") then
                        TweenService:Create(V, TweenInfo.new(0.1), {BackgroundTransparency = Library.VisValues[V] or 0}):Play()
                    elseif V:IsA("TextLabel") or V:IsA("TextBox") then
                        TweenService:Create(V, TweenInfo.new(0.1), {TextTransparency = Library.VisValues[V] or 0}):Play()
                    elseif V:IsA("ImageLabel") or V:IsA("ImageButton") then
                        TweenService:Create(V, TweenInfo.new(0.1), {ImageTransparency = Library.VisValues[V] or 0}):Play()
                    elseif V:IsA("UIStroke") then
                        TweenService:Create(V, TweenInfo.new(0.1), {Transparency = 0}):Play()
                    end
                end
            end)

            return colorpickertypes, Colorpicker
        end
    end

    --// Notifications
    function Library:updateNotifsPositions()
        for i, v in pairs(Library.Notifs) do
            TweenService:Create(v.Container, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.new(0, 20, 0, 20 + (i * 25))}):Play()
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

        local UICorner = Instance.new("UICorner", Outline)
        UICorner.CornerRadius = UDim.new(0, 4)

        local UIStroke = Instance.new("UIStroke", Outline)
        UIStroke.Transparency = 1

        local Inline = Instance.new("Frame")
        Inline.BackgroundColor3 = Color3.fromRGB(13, 13, 13)
        Inline.BorderSizePixel = 0
        Inline.Position = UDim2.fromOffset(1, 1)
        Inline.Size = UDim2.new(1, -2, 1, -2)
        Inline.ZIndex = 51
        Inline.BackgroundTransparency = 1
        Inline.Parent = Outline

        local UICorner2 = Instance.new("UICorner", Inline)
        UICorner2.CornerRadius = UDim.new(0, 4)

        local Title = Instance.new("TextLabel")
        Title.FontFace = Library.FontFace
        Title.RichText = true
        Title.Text = message
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextSize = 13
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.AutomaticSize = Enum.AutomaticSize.X
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.fromOffset(5, 0)
        Title.Size = UDim2.fromScale(0, 1)
        Title.Parent = Inline
        Title.TextTransparency = 1

        local UIPadding = Instance.new("UIPadding", Inline)
        UIPadding.PaddingRight = UDim.new(0, 6)

        function notification:remove()
            table.remove(Library.Notifs, table.find(Library.Notifs, notification))
            Library:updateNotifsPositions()
            task.wait(0.5)
            NewInd:Destroy()
        end

        task.spawn(function()
            Outline.AnchorPoint = Vector2.new(1, 0)
            for _, v in next, NewInd:GetDescendants() do
                if v:IsA("Frame") then
                    TweenService:Create(v, TweenInfo.new(1, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
                elseif v:IsA("UIStroke") then
                    TweenService:Create(v, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
                end
            end
            TweenService:Create(Outline, TweenInfo.new(1, Enum.EasingStyle.Exponential), {AnchorPoint = Vector2.new(0, 0)}):Play()
            TweenService:Create(Title, TweenInfo.new(1, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
            task.wait(duration)
            for _, v in next, NewInd:GetDescendants() do
                if v:IsA("Frame") then
                    TweenService:Create(v, TweenInfo.new(1, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
                elseif v:IsA("UIStroke") then
                    TweenService:Create(v, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
                end
            end
            TweenService:Create(Title, TweenInfo.new(1, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
        end)

        task.delay(duration + 0.1, function()
            notification:remove()
        end)

        table.insert(Library.Notifs, notification)
        Library:updateNotifsPositions()
        return notification
    end

    --// Main
    do
        local Pages = Library.Pages
        local Sections = Library.Sections

        function Library:New(Properties)
            if not Properties then Properties = {} end
            local Window = {
                Size = Properties.Size or UDim2.new(0, 600, 0, 450),
                Pages = {},
                Dragging = {false, UDim2.new(0, 0, 0, 0)},
                Elements = {},
            }

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

            ScreenGui.DisplayOrder = 100
            ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            Library.ScreenGUI = ScreenGui

            Outline.Name = "SodaOutline"
            Outline.Position = UDim2.new(0.5, 0, 0.5, 0)
            Outline.Size = UDim2.new(0, 0, 0, 40)
            Outline.BackgroundColor3 = Color3.new(0.1961, 0.1961, 0.1961)
            Outline.AnchorPoint = Vector2.new(0.5, 0.5)
            Outline.ZIndex = 50
            Outline.ClipsDescendants = false
            Library.Holder = Outline
            Library.OldSize = Window.Size

            --// "Soda.Fun" brand in the sidebar
            local Brand = Instance.new("TextLabel")
            Brand.Name = "SodaBrand"
            Brand.FontFace = Library.FontFace
            Brand.Text = "Soda.Fun"
            Brand.BackgroundTransparency = 1
            Brand.BorderSizePixel = 0
            Brand.Position = UDim2.fromOffset(10, 14)
            Brand.Size = UDim2.new(0, 130, 0, 22)
            Brand.TextSize = 18
            Brand.TextXAlignment = Enum.TextXAlignment.Left
            Brand.ZIndex = 55
            Brand.Parent = Inline
            Library:ApplyTextTheme(Brand, 0)

            --// Logo
            local Logo = Instance.new("ImageLabel")
            Logo.Image = "http://www.roblox.com/asset/?id=17673929618"
            Logo.ScaleType = Enum.ScaleType.Fit
            Logo.BackgroundTransparency = 1
            Logo.BorderSizePixel = 0
            Logo.Position = UDim2.fromOffset(10, -20)
            Logo.Size = UDim2.fromOffset(90, 90)
            Logo.Parent = Holder

            Inline.Name = "Inline"
            Inline.Position = UDim2.new(0, 1, 0, 1)
            Inline.Size = UDim2.new(1, -2, 1, -2)
            Inline.BackgroundColor3 = Color3.new(0.051, 0.051, 0.051)
            Inline.BorderSizePixel = 0
            Inline.ZIndex = 51

            Holder.Name = "Holder"
            Holder.Position = UDim2.new(0, 150, 0, 0)
            Holder.Size = UDim2.new(1, -150, 1, 0)
            Holder.BackgroundColor3 = Color3.new(0.0588235, 0.0588235, 0.0588235)
            Holder.BorderSizePixel = 0
            Holder.ZIndex = 52

            Frame.Size = UDim2.new(0, 5, 1, 0)
            Frame.BackgroundColor3 = Color3.new(0.0588235, 0.0588235, 0.0588235)
            Frame.BorderSizePixel = 0

            Tabs.Name = "Tabs"
            Tabs.Position = UDim2.new(0, 5, 0, 50)
            Tabs.Size = UDim2.new(0, 140, 1, -60)
            Tabs.BackgroundTransparency = 1
            Tabs.BorderSizePixel = 0

            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout.Padding = UDim.new(0, 4)

            TextButton.Size = UDim2.new(1, 0, 0, 20)
            TextButton.BackgroundTransparency = 1
            TextButton.BorderSizePixel = 0
            TextButton.Text = ""
            TextButton.AutoButtonColor = false
            TextButton.ZIndex = 100

            local Line1 = Instance.new("Frame")
            Line1.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Line1.BorderSizePixel = 0
            Line1.Position = UDim2.fromOffset(0, 50)
            Line1.Size = UDim2.new(1, 0, 0, 1)
            Line1.Parent = Holder

            local Line2 = Instance.new("Frame")
            Line2.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Line2.BorderSizePixel = 0
            Line2.Size = UDim2.new(0, 1, 1, 0)
            Line2.Parent = Holder

            local FadeThing = Instance.new("Frame")
            FadeThing.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            FadeThing.BorderSizePixel = 0
            FadeThing.Position = UDim2.fromOffset(9, 59)
            FadeThing.Size = UDim2.new(1, -18, 1, -63)
            FadeThing.ZIndex = 55
            FadeThing.Parent = Holder
            FadeThing.Visible = false

            Window.Elements = {
                TabHolder = Tabs,
                Holder = Holder,
                FadeThing = FadeThing
            }

            --// Dragging
            Library:Connection(TextButton.MouseButton1Down, function()
                local Location = game:GetService("UserInputService"):GetMouseLocation()
                Window.Dragging[1] = true
                Window.Dragging[2] = UDim2.new(0, Location.X - Outline.AbsolutePosition.X, 0, Location.Y - Outline.AbsolutePosition.Y)
            end)
            Library:Connection(game:GetService("UserInputService").InputEnded, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Window.Dragging[1] = false
                end
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
                for _, Page in pairs(Window.Pages) do
                    Page:Turn(Page.Open)
                end
            end

            Library:Connection(game:GetService("UserInputService").InputBegan, function(Inp)
                if Inp.KeyCode == Library.UIKey then
                    Library:SetOpen(not Library.Open)
                end
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
            TextSep.Size = UDim2.new(1, 0, 0, 20)
            TextSep.BackgroundTransparency = 1
            TextSep.BorderSizePixel = 0
            TextLabel.Position = UDim2.new(0, 8, 0, 0)
            TextLabel.Size = UDim2.new(1, -10, 1, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0
            TextLabel.Text = Page.Name
            TextLabel.TextColor3 = Color3.new(0.7059, 0.7059, 0.7059)
            TextLabel.FontFace = Library.FontFace
            TextLabel.TextSize = Library.FontSize
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        end

        function Library:Page(Properties)
            if not Properties then Properties = {} end
            local Page = {
                Name = Properties.Name or "Page",
                Icon = Properties.Icon or "http://www.roblox.com/asset/?id=6022668955",
                Window = self,
                Open = false,
                Sections = {},
                Elements = {},
            }

            local TabButton = Instance.new('TextButton', Page.Window.Elements.TabHolder)
            local UICorner_3 = Instance.new('UICorner', TabButton)
            local Accent = Instance.new('Frame', TabButton)
            local UICorner = Instance.new('UICorner', Accent)
            local Title = Instance.new('TextLabel', TabButton)
            local Icon = Instance.new('ImageLabel', TabButton)
            local NewPage = Instance.new('Frame', Page.Window.Elements.Holder)
            local Left = Instance.new('Frame', NewPage)
            local LeftLayout = Instance.new('UIListLayout', Left)
            local Right = Instance.new('Frame', NewPage)
            local RightLayout = Instance.new('UIListLayout', Right)

            TabButton.Size = UDim2.new(1, 0, 0, 30)
            TabButton.BackgroundColor3 = Color3.new(0.0784, 0.0784, 0.0784)
            TabButton.BorderSizePixel = 0
            TabButton.BackgroundTransparency = 1
            TabButton.Text = ""
            TabButton.AutoButtonColor = false
            TabButton.ClipsDescendants = true

            Accent.Position = UDim2.new(0, -8, 0, 5)
            Accent.Size = UDim2.new(0, 10, 1, -10)
            Accent.BorderSizePixel = 0
            Accent.BackgroundTransparency = 0
            Library:ApplyTheme(Accent, 90) -- vertical red->blue

            Title.Position = UDim2.new(0, 35, 0, 0)
            Title.Size = UDim2.new(1, -10, 1, 0)
            Title.BackgroundTransparency = 1
            Title.BorderSizePixel = 0
            Title.Text = Page.Name
            Title.TextColor3 = Color3.fromRGB(120, 120, 120)
            Title.FontFace = Library.FontFace
            Title.TextSize = Library.FontSize
            Title.TextXAlignment = Enum.TextXAlignment.Left

            Icon.Position = UDim2.new(0, 11, 0, 8)
            Icon.Size = UDim2.new(0, 15, 0, 15)
            Icon.BackgroundTransparency = 1
            Icon.BorderSizePixel = 0
            Icon.Image = Page.Icon
            Icon.ImageColor3 = Color3.fromRGB(120, 120, 120)

            NewPage.Position = UDim2.new(0, 10, 0, 60)
            NewPage.Size = UDim2.new(1, -20, 1, -65)
            NewPage.BackgroundTransparency = 1
            NewPage.BorderSizePixel = 0
            NewPage.ZIndex = 53
            NewPage.Visible = false

            Left.Size = UDim2.new(0.5, -4, 1, 0)
            Left.BackgroundTransparency = 1
            Left.BorderSizePixel = 0
            Left.ZIndex = 54
            LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
            LeftLayout.Padding = UDim.new(0, 8)

            Right.Position = UDim2.new(0.5, 4, 0, 0)
            Right.Size = UDim2.new(0.5, -4, 1, 0)
            Right.BackgroundTransparency = 1
            Right.BorderSizePixel = 0
            Right.ZIndex = 53
            RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
            RightLayout.Padding = UDim.new(0, 8)

            function Page:Turn(bool)
                Page.Open = bool
                task.spawn(function()
                    Page.Window.Elements.FadeThing.Visible = true
                    TweenService:Create(Page.Window.Elements.FadeThing, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play()
                    task.wait(0.1)
                    NewPage.Visible = Page.Open
                    TweenService:Create(Page.Window.Elements.FadeThing, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play()
                    task.wait(0.1)
                    Page.Window.Elements.FadeThing.Visible = false
                end)
                TweenService:Create(TabButton, TweenInfo.new(0.1), {BackgroundTransparency = Page.Open and 0 or 1}):Play()
                TweenService:Create(Title, TweenInfo.new(0.1), {TextColor3 = Page.Open and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(120, 120, 120)}):Play()
                TweenService:Create(Icon, TweenInfo.new(0.1), {ImageColor3 = Page.Open and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(120, 120, 120)}):Play()
                TweenService:Create(Accent, TweenInfo.new(0.1), {BackgroundTransparency = Page.Open and 0 or 1}):Play()
            end

            Library:Connection(TabButton.MouseButton1Click, function()
                if not Page.Open then
                    Page:Turn(true)
                    for _, Pages in pairs(Page.Window.Pages) do
                        if Pages.Open and Pages ~= Page then Pages:Turn(false) end
                    end
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
            local Section = {
                Name = Properties.Name or "Section",
                Page = self,
                Side = (Properties.side or Properties.Side or "left"):lower(),
                Size = Properties.size or Properties.Size or 200,
                Elements = {},
                Content = {},
            }

            local NewSection = Instance.new('Frame', Section.Side == "left" and Section.Page.Elements.Left or Section.Page.Elements.Right)
            local UIStroke = Instance.new('UIStroke', NewSection)
            local UICorner = Instance.new('UICorner', NewSection)
            local Frame = Instance.new('Frame', NewSection)
            local Title = Instance.new('TextLabel', NewSection)
            local Content = Instance.new('Frame', NewSection)
            local UIListLayout = Instance.new('UIListLayout', Content)

            NewSection.Size = Section.Size == "Fill" and UDim2.new(1, 0, 1, 0) or UDim2.new(1, 0, 0, Section.Size)
            NewSection.BackgroundColor3 = Color3.new(0.0784314, 0.0784314, 0.0784314)
            NewSection.BorderSizePixel = 0
            NewSection.ZIndex = 53
            UIStroke.Color = Color3.new(0.137255, 0.137255, 0.137255)

            Frame.Position = UDim2.new(0, 0, 0, 20)
            Frame.Size = UDim2.new(1, 0, 0, 1)
            Frame.BackgroundColor3 = Color3.new(0.1569, 0.1569, 0.1569)
            Frame.BorderSizePixel = 0

            Title.Position = UDim2.new(0, 8, 0, 1)
            Title.Size = UDim2.new(1, -10, 0, 20)
            Title.BackgroundTransparency = 1
            Title.BorderSizePixel = 0
            Title.Text = Section.Name
            Title.TextColor3 = Color3.new(0.7059, 0.7059, 0.7059)
            Title.FontFace = Library.FontFace
            Title.TextSize = Library.FontSize
            Title.TextXAlignment = Enum.TextXAlignment.Left

            Content.Position = UDim2.new(0, 10, 0, 30)
            Content.Size = UDim2.new(1, -20, 1, -40)
            Content.BackgroundTransparency = 1
            Content.BorderSizePixel = 0
            Content.ZIndex = 53
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout.Padding = UDim.new(0, 8)

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
            local UICorner_2 = Instance.new('UICorner', ToggleFrame)
            local ToggleAccent = Instance.new('Frame', ToggleFrame)
            local UICorner_3 = Instance.new('UICorner', ToggleAccent)
            local Circle = Instance.new('Frame', ToggleFrame)
            local UICorner_4 = Instance.new('UICorner', Circle)

            NewToggle.Size = UDim2.new(1, 0, 0, 17)
            NewToggle.BackgroundTransparency = 1
            NewToggle.BorderSizePixel = 0
            NewToggle.Text = ""
            NewToggle.AutoButtonColor = false
            NewToggle.ZIndex = 53

            ToggleTitle.Size = UDim2.new(1, -10, 0, 17)
            ToggleTitle.BackgroundTransparency = 1
            ToggleTitle.BorderSizePixel = 0
            ToggleTitle.Text = Toggle.Name
            ToggleTitle.TextColor3 = Color3.new(0.7843, 0.7843, 0.7843)
            ToggleTitle.FontFace = Library.FontFace
            ToggleTitle.TextSize = Library.FontSize
            ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left

            ToggleFrame.Position = UDim2.new(1, -40, 0, 0)
            ToggleFrame.Size = UDim2.new(0, 40, 1, 0)
            ToggleFrame.BackgroundColor3 = Color3.new(0.051, 0.051, 0.051)
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.ZIndex = 53

            ToggleAccent.Position = UDim2.new(0, 1, 0, 1)
            ToggleAccent.Size = UDim2.new(1, -2, 1, -2)
            ToggleAccent.BackgroundTransparency = 1
            ToggleAccent.BorderSizePixel = 0
            ToggleAccent.ZIndex = 53
            Library:ApplyTheme(ToggleAccent, 0) -- horizontal red->blue

            Circle.Position = UDim2.new(0, 5, 0.5, -5)
            Circle.Size = UDim2.new(0, 10, 0, 10)
            Circle.BackgroundColor3 = Color3.new(1, 1, 1)
            Circle.BorderSizePixel = 0
            Circle.ZIndex = 53
            UICorner_4.CornerRadius = UDim.new(1, 0)

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
                local UICorner = Instance.new('UICorner', OptionList)
                local UIStroke = Instance.new('UIStroke', OptionList)
                local OptionContent = Instance.new('Frame', OptionList)
                local UIListLayout = Instance.new('UIListLayout', OptionContent)

                OptionButton.Position = UDim2.new(1, -65, 0, 1)
                OptionButton.Size = UDim2.new(0, 15, 0, 15)
                OptionButton.BackgroundTransparency = 1
                OptionButton.BorderSizePixel = 0
                OptionButton.Image = "http://www.roblox.com/asset/?id=6031280882"
                OptionButton.ImageColor3 = Color3.new(0.7843, 0.7843, 0.7843)
                OptionButton.ZIndex = 54

                OptionList.Position = UDim2.new(0, 70, 0, -10)
                OptionList.Size = UDim2.new(0, 200, 0, 10)
                OptionList.BackgroundColor3 = Color3.new(0.0784314, 0.0784314, 0.0784314)
                OptionList.BorderSizePixel = 0
                OptionList.AutomaticSize = Enum.AutomaticSize.Y
                OptionList.Visible = false
                OptionList.ZIndex = 54
                UIStroke.Color = Color3.new(0.137255, 0.137255, 0.137255)

                OptionContent.Position = UDim2.new(0, 10, 0, 10)
                OptionContent.Size = UDim2.new(1, -20, 1, -10)
                OptionContent.BackgroundTransparency = 1
                OptionContent.AutomaticSize = Enum.AutomaticSize.Y
                OptionContent.ZIndex = 54
                UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout.Padding = UDim.new(0, 4)

                Library:Connection(OptionButton.MouseButton1Click, function()
                    local State = not OptionList.Visible
                    OptionList.Visible = State
                    Library.OptionListOpen = State
                end)
                Library:Connection(game:GetService("UserInputService").InputBegan, function(Input)
                    if Library.DropdownOpen then return end
                    if OptionList.Visible and Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if not Library:IsMouseOverFrame(OptionList) and not Library:IsMouseOverFrame(OptionButton) then
                            OptionList.Visible = false
                        end
                    end
                end)

                Section.Elements = {SectionContent = OptionContent}
                return setmetatable(Section, Library.Sections)
            end

            function Toggle.Set(bool)
                bool = type(bool) == "boolean" and bool or false
                if Toggle.Toggled ~= bool then SetState() end
            end
            Toggle.Set(Toggle.State)
            Library.Flags[Toggle.Flag] = Toggle.State
            Flags[Toggle.Flag] = Toggle.Set

            Library:Connection(NewToggle.MouseButton1Click, SetState)
            return Toggle
        end

        --// Nest
        function Sections:Nest(Properties)
            if not Properties then Properties = {} end
            local Section = {
                Name = Properties.Name or "Section",
                RealSection = self,
                Size = Properties.size or Properties.Size or 200,
                Elements = {},
            }
            local ScrollHolder = Instance.new("Frame", Section.RealSection.Elements.SectionContent)
            local NewScroll = Instance.new('ScrollingFrame', ScrollHolder)
            local UICorner2 = Instance.new('UICorner', ScrollHolder)
            local UIStroke = Instance.new('UIStroke', ScrollHolder)
            local ScrollContent = Instance.new('Frame', NewScroll)
            local UIListLayout = Instance.new('UIListLayout', ScrollContent)

            ScrollHolder.Size = UDim2.new(1, 0, 0, Section.Size)
            ScrollHolder.BackgroundColor3 = Color3.new(0.0784314, 0.0784314, 0.0784314)
            ScrollHolder.BorderSizePixel = 0
            ScrollHolder.ClipsDescendants = true

            NewScroll.Size = UDim2.new(1, 0, 1, 0)
            NewScroll.BackgroundTransparency = 1
            NewScroll.BorderSizePixel = 0
            NewScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            NewScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            NewScroll.ScrollBarThickness = 2
            NewScroll.TopImage = ""
            NewScroll.BottomImage = ""
            NewScroll.VerticalScrollBarInset = Enum.ScrollBarInset.Always
            NewScroll.ScrollBarImageColor3 = Library.Accent
            NewScroll.ClipsDescendants = true
            table.insert(Library.ThemeObjects, NewScroll)

            UIStroke.Color = Color3.new(0.137255, 0.137255, 0.137255)
            ScrollContent.Position = UDim2.new(0, 10, 0, 5)
            ScrollContent.Size = UDim2.new(1, -20, 0, 0)
            ScrollContent.BackgroundTransparency = 1
            ScrollContent.AutomaticSize = Enum.AutomaticSize.Y

            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout.Padding = UDim.new(0, 4)

            Section.Elements = {SectionContent = ScrollContent}
            return setmetatable(Section, Library.Sections)
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
            local UICorner_2 = Instance.new('UICorner', ToggleFrame)
            local FillHold = Instance.new('Frame', ToggleFrame)
            local UICorner_3 = Instance.new('UICorner', FillHold)
            local Fill = Instance.new('TextButton', FillHold)
            local UICorner_4 = Instance.new('UICorner', Fill)
            local Circle = Instance.new('Frame', Fill)
            local UICorner_5 = Instance.new('UICorner', Circle)
            local SliderValue = Instance.new('TextLabel', NewSlider)

            NewSlider.Size = UDim2.new(1, 0, 0, 32)
            NewSlider.BackgroundTransparency = 1
            NewSlider.BorderSizePixel = 0
            NewSlider.Text = ""
            NewSlider.AutoButtonColor = false
            NewSlider.ZIndex = 53

            SliderTitle.Size = UDim2.new(1, -10, 0, 17)
            SliderTitle.BackgroundTransparency = 1
            SliderTitle.Text = Slider.Name
            SliderTitle.TextColor3 = Color3.new(0.7843, 0.7843, 0.7843)
            SliderTitle.FontFace = Library.FontFace
            SliderTitle.TextSize = Library.FontSize
            SliderTitle.TextXAlignment = Enum.TextXAlignment.Left

            ToggleFrame.Position = UDim2.new(0, 0, 1, -8)
            ToggleFrame.Size = UDim2.new(1, 0, 0, 8)
            ToggleFrame.BackgroundColor3 = Color3.new(0.051, 0.051, 0.051)
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.ZIndex = 53

            FillHold.Position = UDim2.new(0, 1, 0, 1)
            FillHold.Size = UDim2.new(1, -2, 1, -2)
            FillHold.BackgroundColor3 = Color3.new(0.6667, 0.6667, 1)
            FillHold.BackgroundTransparency = 1
            FillHold.BorderSizePixel = 0
            FillHold.ZIndex = 53

            Fill.Size = UDim2.new(0, 0, 1, 0)
            Fill.BorderSizePixel = 0
            Fill.Text = ""
            Fill.AutoButtonColor = false
            Fill.ZIndex = 53
            Library:ApplyTheme(Fill, 0)

            Circle.Position = UDim2.new(1, -6, 0.5, -6)
            Circle.Size = UDim2.new(0, 13, 0, 13)
            Circle.BackgroundColor3 = Color3.new(1, 1, 1)
            Circle.BorderSizePixel = 0
            Circle.ZIndex = 53
            UICorner_5.CornerRadius = UDim.new(1, 0)

            SliderValue.Size = UDim2.new(1, 0, 0, 17)
            SliderValue.BackgroundTransparency = 1
            SliderValue.Text = ""
            SliderValue.TextColor3 = Color3.new(0.4706, 0.4706, 0.4706)
            SliderValue.FontFace = Library.FontFace
            SliderValue.TextSize = Library.FontSize
            SliderValue.TextXAlignment = Enum.TextXAlignment.Right

            local Sliding = false
            local function Set(value)
                value = math.clamp(Library:Round(value, Slider.Decimals), Slider.Min, Slider.Max)
                local sizeX = ((value - Slider.Min) / (Slider.Max - Slider.Min))
                TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(sizeX, 0, 1, 0)}):Play()
                SliderValue.Text = TextValue:gsub("%[value%]", string.format("%.14g", value))
                Library.Flags[Slider.Flag] = value
                Slider.Callback(value)
            end
            local function Slide(input)
                local sizeX = (input.Position.X - NewSlider.AbsolutePosition.X) / NewSlider.AbsoluteSize.X
                Set(((Slider.Max - Slider.Min) * sizeX) + Slider.Min)
            end

            Library:Connection(NewSlider.InputBegan, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = true; Slide(input) end
            end)
            Library:Connection(NewSlider.InputEnded, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = false end
            end)
            Library:Connection(Fill.InputBegan, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = true; Slide(input) end
            end)
            Library:Connection(Fill.InputEnded, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = false end
            end)
            Library:Connection(game:GetService("UserInputService").InputChanged, function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement and Sliding then Slide(input) end
            end)

            function Slider:Set(Value) Set(Value) end
            Flags[Slider.Flag] = Set
            Library.Flags[Slider.Flag] = Slider.State
            Set(Slider.State)
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
            local UICorner_2 = Instance.new('UICorner', ToggleFrame)
            local ToggleContent = Instance.new('Frame', ToggleFrame)
            local UICorner_3 = Instance.new('UICorner', ToggleContent)
            local UIListLayout = Instance.new('UIListLayout', ToggleContent)
            local DropdownTitle_2 = Instance.new('TextLabel', ToggleFrame)
            local Icon = Instance.new('ImageLabel', ToggleFrame)

            NewDropdown.Size = UDim2.new(1, 0, 0, 48)
            NewDropdown.BackgroundTransparency = 1
            NewDropdown.ZIndex = 54

            DropdownTitle.Size = UDim2.new(1, -10, 0, 17)
            DropdownTitle.BackgroundTransparency = 1
            DropdownTitle.Text = Dropdown.Name
            DropdownTitle.TextColor3 = Color3.new(0.7843, 0.7843, 0.7843)
            DropdownTitle.FontFace = Library.FontFace
            DropdownTitle.TextSize = Library.FontSize
            DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left

            ToggleFrame.Position = UDim2.new(0, 0, 1, -24)
            ToggleFrame.Size = UDim2.new(1, 0, 0, 24)
            ToggleFrame.BackgroundColor3 = Color3.new(0.098, 0.098, 0.098)
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.ZIndex = 54
            ToggleFrame.AutoButtonColor = false
            ToggleFrame.Text = ""
            UICorner_2.CornerRadius = UDim.new(0, 4)

            ToggleContent.Position = UDim2.new(0, 0, 1, 0)
            ToggleContent.Size = UDim2.new(1, 0, 0, 0)
            ToggleContent.BackgroundColor3 = Color3.new(0.0706, 0.0706, 0.0706)
            ToggleContent.BorderSizePixel = 0
            ToggleContent.ZIndex = 54
            ToggleContent.ClipsDescendants = true
            UICorner_3.CornerRadius = UDim.new(0, 4)
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

            DropdownTitle_2.Position = UDim2.new(0, 4, 0, 0)
            DropdownTitle_2.Size = UDim2.new(1, -10, 1, 0)
            DropdownTitle_2.BackgroundTransparency = 1
            DropdownTitle_2.Text = ""
            DropdownTitle_2.TextColor3 = Color3.new(0.7843, 0.7843, 0.7843)
            DropdownTitle_2.FontFace = Library.FontFace
            DropdownTitle_2.TextSize = Library.FontSize
            DropdownTitle_2.TextXAlignment = Enum.TextXAlignment.Left

            Icon.Position = UDim2.new(1, -25, 0, 5)
            Icon.Size = UDim2.new(0, 20, 0, 15)
            Icon.BackgroundTransparency = 1
            Icon.Image = "http://www.roblox.com/asset/?id=6034818372"
            Icon.ImageColor3 = Color3.new(0.4706, 0.4706, 0.4706)
            Icon.ZIndex = 54

            local Toggled = false
            local Count = 0

            Library:Connection(ToggleFrame.MouseButton1Click, function()
                Toggled = not Toggled
                Library.DropdownOpen = Toggled
                if Toggled then
                    NewDropdown.ZIndex = 55
                    TweenService:Create(Icon, TweenInfo.new(0.25), {Rotation = 180}):Play()
                    TweenService:Create(Icon, TweenInfo.new(0.25), {ImageColor3 = Color3.fromRGB(200, 200, 200)}):Play()
                    TweenService:Create(ToggleContent, TweenInfo.new(0.25), {Size = UDim2.new(1, 0, 0, Count * 22)}):Play()
                else
                    TweenService:Create(Icon, TweenInfo.new(0.25), {Rotation = 0}):Play()
                    TweenService:Create(Icon, TweenInfo.new(0.25), {ImageColor3 = Color3.fromRGB(120, 120, 120)}):Play()
                    TweenService:Create(ToggleContent, TweenInfo.new(0.25), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                    task.wait(0.20)
                    NewDropdown.ZIndex = 54
                end
            end)

            Library:Connection(game:GetService("UserInputService").InputBegan, function(Input)
                if ToggleContent.Visible and Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if not Library:IsMouseOverFrame(ToggleContent) and not Library:IsMouseOverFrame(ToggleFrame) and not Library.OptionListOpen then
                        Toggled = false
                        Library.DropdownOpen = false
                        TweenService:Create(Icon, TweenInfo.new(0.25), {ImageColor3 = Color3.fromRGB(120, 120, 120)}):Play()
                        TweenService:Create(Icon, TweenInfo.new(0.25), {Rotation = 0}):Play()
                        TweenService:Create(ToggleContent, TweenInfo.new(0.25), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                        task.wait(0.20)
                        NewDropdown.ZIndex = 54
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
                            Library.Flags[Dropdown.Flag] = Chosen
                            Dropdown.Callback(Chosen)
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
                            Library.Flags[Dropdown.Flag] = Chosen
                            Dropdown.Callback(Chosen)
                        end
                    else
                        for opt, tbl in next, Dropdown.OptionInsts do
                            if opt ~= option then
                                TweenService:Create(tbl.text, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(120, 120, 120)}):Play()
                                TweenService:Create(tbl.text, TweenInfo.new(0.25), {Position = UDim2.new(0, 4, 0, 0)}):Play()
                                TweenService:Create(tbl.dot, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
                            end
                        end
                        Chosen = option
                        DropdownTitle_2.Text = option
                        TweenService:Create(text, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
                        TweenService:Create(dot, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()
                        TweenService:Create(text, TweenInfo.new(0.25), {Position = UDim2.new(0, 20, 0, 0)}):Play()
                        Library.Flags[Dropdown.Flag] = option
                        Dropdown.Callback(option)
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

                    TextButton.Size = UDim2.new(1, 0, 0, 22)
                    TextButton.BackgroundTransparency = 1
                    TextButton.Text = ""
                    TextButton.AutoButtonColor = false
                    Dropdown.OptionInsts[option].button = TextButton

                    DropdownTitle3.Position = UDim2.new(0, 20, 0, 0)
                    DropdownTitle3.Size = UDim2.new(1, -10, 1, 0)
                    DropdownTitle3.BackgroundTransparency = 1
                    DropdownTitle3.Text = option
                    DropdownTitle3.TextColor3 = Color3.fromRGB(120, 120, 120)
                    DropdownTitle3.FontFace = Library.FontFace
                    DropdownTitle3.TextSize = Library.FontSize
                    DropdownTitle3.TextXAlignment = Enum.TextXAlignment.Left
                    Dropdown.OptionInsts[option].text = DropdownTitle3

                    AccentDot.Position = UDim2.new(0, 8, 0, 8)
                    AccentDot.Size = UDim2.new(0, 6, 0, 6)
                    AccentDot.BorderSizePixel = 0
                    Library:ApplyTheme(AccentDot, 45)
                    Dropdown.OptionInsts[option].dot = AccentDot

                    OptionCorner.CornerRadius = UDim.new(1, 0)
                    Count += 1
                    handleoptionclick(option, TextButton, DropdownTitle3, AccentDot)
                end
            end
            createoptions(Dropdown.Options)

            local set
            set = function(option)
                if Dropdown.Max then
                    table.clear(Chosen)
                    option = type(option) == "table" and option or {}
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
                    Library.Flags[Dropdown.Flag] = Chosen
                    Dropdown.Callback(Chosen)
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
                        Chosen = option
                        DropdownTitle_2.Text = option
                        TweenService:Create(Dropdown.OptionInsts[option].text, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
                        TweenService:Create(Dropdown.OptionInsts[option].dot, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()
                        TweenService:Create(Dropdown.OptionInsts[option].text, TweenInfo.new(0.25), {Position = UDim2.new(0, 20, 0, 0)}):Play()
                        Library.Flags[Dropdown.Flag] = Chosen
                        Dropdown.Callback(Chosen)
                    else
                        Chosen = nil
                        DropdownTitle_2.Text = ""
                        Library.Flags[Dropdown.Flag] = Chosen
                        Dropdown.Callback(Chosen)
                    end
                end
            end

            function Dropdown:Refresh(tbl)
                Count = 0
                for _, opt in next, Dropdown.OptionInsts do
                    coroutine.wrap(function() opt.button:Destroy() end)()
                end
                table.clear(Dropdown.OptionInsts)
                createoptions(tbl)
                Chosen = nil
                Library.Flags[Dropdown.Flag] = Chosen
                Dropdown.Callback(Chosen)
            end

            if Dropdown.Max then Flags[Dropdown.Flag] = set
            else Flags[Dropdown.Flag] = Dropdown end
            Dropdown:Set(Dropdown.State)
            return Dropdown
        end

        --// Colorpicker
        function Sections:Colorpicker(Properties)
            Properties = Properties or {}
            local Colorpicker = {
                Window = self.Window, Page = self.Page, Section = self,
                Name = (Properties.Name or "Colorpicker"),
                State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or Color3.fromRGB(255, 0, 0)),
                Callback = (Properties.callback or Properties.Callback or function() end),
                Flag = (Properties.flag or Properties.Flag or Properties.pointer or Properties.Pointer or Library.NextFlag()),
                Colorpickers = 0,
            }
            local NewColor = Instance.new("TextButton")
            NewColor.FontFace = Library.FontFace
            NewColor.Text = ""
            NewColor.TextSize = 14
            NewColor.AutoButtonColor = false
            NewColor.BackgroundTransparency = 1
            NewColor.Size = UDim2.new(1, 0, 0, 17)
            NewColor.ZIndex = 54
            NewColor.Parent = Colorpicker.Section.Elements.SectionContent

            local ToggleTitle = Instance.new("TextLabel")
            ToggleTitle.FontFace = Library.FontFace
            ToggleTitle.Text = Colorpicker.Name
            ToggleTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
            ToggleTitle.TextSize = 13
            ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
            ToggleTitle.BackgroundTransparency = 1
            ToggleTitle.Size = UDim2.new(1, -10, 0, 17)
            ToggleTitle.Parent = NewColor

            Colorpicker.Colorpickers = Colorpicker.Colorpickers + 1
            local colorpickertypes = Library:NewPicker(Colorpicker.Name, Colorpicker.State, NewColor, Colorpicker.Colorpickers, Colorpicker.Flag, Colorpicker.Callback)

            function Colorpicker:Set(color) colorpickertypes:Set(color, false, true) end
            return Colorpicker
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
            local Key
            local State = false

            local NewKey = Instance.new("TextButton")
            NewKey.FontFace = Library.FontFace
            NewKey.Text = ""
            NewKey.TextSize = 14
            NewKey.AutoButtonColor = false
            NewKey.BackgroundTransparency = 1
            NewKey.Size = UDim2.new(1, 0, 0, 17)
            NewKey.ZIndex = 54
            NewKey.Parent = Keybind.Section.Elements.SectionContent

            local ToggleTitle = Instance.new("TextLabel")
            ToggleTitle.FontFace = Library.FontFace
            ToggleTitle.Text = Keybind.Name
            ToggleTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
            ToggleTitle.TextSize = 13
            ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
            ToggleTitle.BackgroundTransparency = 1
            ToggleTitle.Size = UDim2.new(1, -10, 0, 17)
            ToggleTitle.Parent = NewKey

            local KeyText = Instance.new("TextLabel")
            KeyText.FontFace = Library.FontFace
            KeyText.Text = "None"
            KeyText.TextColor3 = Color3.fromRGB(200, 200, 200)
            KeyText.TextSize = 13
            KeyText.TextXAlignment = Enum.TextXAlignment.Right
            KeyText.BackgroundTransparency = 1
            KeyText.Position = UDim2.new(1, -180, 0, 0)
            KeyText.Size = UDim2.new(1, -10, 0, 17)
            KeyText.Parent = NewKey

            local c
            local function set(newkey)
                if string.find(tostring(newkey), "Enum") then
                    if c then
                        c:Disconnect()
                        if Keybind.Flag then Library.Flags[Keybind.Flag] = false end
                        Keybind.Callback(false)
                    end
                    if tostring(newkey):find("Enum.KeyCode.") then
                        newkey = Enum.KeyCode[tostring(newkey):gsub("Enum.KeyCode.", "")]
                    elseif tostring(newkey):find("Enum.UserInputType.") then
                        newkey = Enum.UserInputType[tostring(newkey):gsub("Enum.UserInputType.", "")]
                    end
                    if newkey == Enum.KeyCode.Backspace then
                        Key = nil
                        if Keybind.UseKey then
                            if Keybind.Flag then Library.Flags[Keybind.Flag] = Key end
                            Keybind.Callback(Key)
                        end
                        KeyText.Text = "None"
                    elseif newkey ~= nil then
                        Key = newkey
                        if Keybind.UseKey then
                            if Keybind.Flag then Library.Flags[Keybind.Flag] = Key end
                            Keybind.Callback(Key)
                        end
                        KeyText.Text = (Library.Keys[newkey] or tostring(newkey):gsub("Enum.KeyCode.", ""))
                    end
                    Library.Flags[Keybind.Flag .. "_KEY"] = newkey
                elseif table.find({"Always", "Toggle", "Hold"}, newkey) then
                    if not Keybind.UseKey then
                        Library.Flags[Keybind.Flag .. "_KEY STATE"] = newkey
                        Keybind.Mode = newkey
                        if Keybind.Mode == "Always" then
                            State = true
                            if Keybind.Flag then Library.Flags[Keybind.Flag] = State end
                            Keybind.Callback(true)
                        end
                    end
                else
                    State = newkey
                    if Keybind.Flag then Library.Flags[Keybind.Flag] = newkey end
                    Keybind.Callback(newkey)
                end
            end

            set(Keybind.State)
            set(Keybind.Mode)

            NewKey.MouseButton1Click:Connect(function()
                if not Keybind.Binding then
                    KeyText.Text = "..."
                    TweenService:Create(KeyText, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                    Keybind.Binding = Library:Connection(game:GetService("UserInputService").InputBegan, function(input, gpe)
                        if gpe then return end
                        if input.UserInputType == Enum.UserInputType.Touch then return end
                        set(input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType)
                        Library:Disconnect(Keybind.Binding)
                        task.wait()
                        Keybind.Binding = nil
                        TweenService:Create(KeyText, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
                    end)
                end
            end)

            Library:Connection(game:GetService("UserInputService").InputBegan, function(inp, gpe)
                if gpe then return end
                if (inp.KeyCode == Key or inp.UserInputType == Key) and not Keybind.Binding and not Keybind.UseKey then
                    if Keybind.Mode == "Hold" then
                        if Keybind.Flag then Library.Flags[Keybind.Flag] = true end
                        c = Library:Connection(game:GetService("RunService").RenderStepped, function()
                            Keybind.Callback(true)
                        end)
                    elseif Keybind.Mode == "Toggle" then
                        State = not State
                        if Keybind.Flag then Library.Flags[Keybind.Flag] = State end
                        Keybind.Callback(State)
                    end
                end
            end)

            Library:Connection(game:GetService("UserInputService").InputEnded, function(inp, gpe)
                if gpe then return end
                if Keybind.Mode == "Hold" and not Keybind.UseKey then
                    if inp.KeyCode == Key or inp.UserInputType == Key then
                        if c then
                            c:Disconnect()
                            if Keybind.Flag then Library.Flags[Keybind.Flag] = false end
                            Keybind.Callback(false)
                        end
                    end
                end
            end)

            Library.Flags[Keybind.Flag .. "_KEY"] = Keybind.State
            Library.Flags[Keybind.Flag .. "_KEY STATE"] = Keybind.Mode
            Flags[Keybind.Flag] = set
            Flags[Keybind.Flag .. "_KEY"] = set
            Flags[Keybind.Flag .. "_KEY STATE"] = set

            function Keybind:Set(key) set(key) end
            return Keybind
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
            NewBox.BackgroundTransparency = 1
            NewBox.Size = UDim2.new(1, 0, 0, 24)
            NewBox.ZIndex = 54
            NewBox.Parent = Textbox.Section.Elements.SectionContent

            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 13)
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Position = UDim2.new(0, 0, 1, -24)
            ToggleFrame.Size = UDim2.new(1, 0, 0, 24)
            ToggleFrame.ZIndex = 55

            local UICorner2 = Instance.new("UICorner", ToggleFrame)
            UICorner2.CornerRadius = UDim.new(0, 4)

            local DropdownTitle = Instance.new("TextBox")
            DropdownTitle.FontFace = Library.FontFace
            DropdownTitle.Text = Textbox.State
            DropdownTitle.PlaceholderText = Textbox.Placeholder
            DropdownTitle.PlaceholderColor3 = Color3.fromRGB(145, 145, 145)
            DropdownTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
            DropdownTitle.TextSize = 13
            DropdownTitle.ClearTextOnFocus = false
            DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
            DropdownTitle.BackgroundTransparency = 1
            DropdownTitle.Position = UDim2.fromOffset(4, 0)
            DropdownTitle.Size = UDim2.new(1, -10, 1, 0)
            DropdownTitle.ZIndex = 53
            DropdownTitle.Parent = ToggleFrame
            DropdownTitle.TextTruncate = Enum.TextTruncate.SplitWord

            ToggleFrame.Parent = NewBox

            DropdownTitle.FocusLost:Connect(function()
                Textbox.Callback(DropdownTitle.Text)
                Library.Flags[Textbox.Flag] = DropdownTitle.Text
            end)

            local function set(str)
                DropdownTitle.Text = str
                Library.Flags[Textbox.Flag] = str
                Textbox.Callback(str)
            end

            Flags[Textbox.Flag] = set
            Library.Flags[Textbox.Flag] = DropdownTitle.Text
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
            NewButton.FontFace = Library.FontFace
            NewButton.Text = ""
            NewButton.TextSize = 14
            NewButton.AutoButtonColor = false
            NewButton.BackgroundTransparency = 1
            NewButton.Size = UDim2.new(1, 0, 0, 24)
            NewButton.ZIndex = 54
            NewButton.Parent = Button.Section.Elements.SectionContent

            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Position = UDim2.new(0, 0, 1, -24)
            ToggleFrame.Size = UDim2.new(1, 0, 0, 24)
            ToggleFrame.ZIndex = 55

            local UICorner2 = Instance.new("UICorner", ToggleFrame)
            UICorner2.CornerRadius = UDim.new(0, 4)

            local Label = Instance.new("TextLabel")
            Label.FontFace = Library.FontFace
            Label.Text = Button.Name
            Label.TextColor3 = Color3.fromRGB(200, 200, 200)
            Label.TextSize = 13
            Label.BackgroundTransparency = 1
            Label.Size = UDim2.fromScale(1, 1)
            Label.ZIndex = 53
            Label.Parent = ToggleFrame

            ToggleFrame.Parent = NewButton

            Library:Connection(NewButton.MouseButton1Down, function()
                Button.Callback()
                TweenService:Create(Label, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                task.spawn(function()
                    task.wait(0.1)
                    TweenService:Create(Label, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
                end)
            end)
        end

        --// Watermark (Soda.Fun)
        function Library:Watermark(Properties)
            local Watermark = {
                Name = (Properties.Name or Properties.name or "v1.0");
                AnimateText = nil;
            }
            local Outline = Instance.new("Frame")
            Outline.AnchorPoint = Vector2.new(1, 0)
            Outline.AutomaticSize = Enum.AutomaticSize.X
            Outline.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Outline.Position = UDim2.new(1, -10, 0, 10)
            Outline.Size = UDim2.fromOffset(100, 20)
            Outline.Visible = false
            Outline.ZIndex = 50
            Outline.Parent = Library.ScreenGUI

            local UICorner = Instance.new("UICorner", Outline)
            UICorner.CornerRadius = UDim.new(0, 4)

            local UIStroke = Instance.new("UIStroke", Outline)

            local Inline = Instance.new("Frame")
            Inline.BackgroundColor3 = Color3.fromRGB(13, 13, 13)
            Inline.BorderSizePixel = 0
            Inline.Position = UDim2.fromOffset(1, 1)
            Inline.Size = UDim2.new(1, -2, 1, -2)
            Inline.ZIndex = 51
            Inline.Parent = Outline

            local UICorner2 = Instance.new("UICorner", Inline)
            UICorner2.CornerRadius = UDim.new(0, 4)

            local Title = Instance.new("TextLabel")
            Title.FontFace = Library.FontFace
            Title.RichText = true
            Title.Text = Watermark.Name
            Title.TextColor3 = Color3.fromRGB(255, 255, 255)
            Title.TextSize = 13
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.AutomaticSize = Enum.AutomaticSize.X
            Title.BackgroundTransparency = 1
            Title.Position = UDim2.fromOffset(5, 0)
            Title.Size = UDim2.fromScale(0, 1)
            Title.Parent = Inline

            local UIPadding = Instance.new("UIPadding", Inline)
            UIPadding.PaddingRight = UDim.new(0, 6)

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

            function Watermark:UpdateText(NewText)
                Watermark.Name = NewText
            end
            function Watermark:SetVisible(State)
                Outline.Visible = State
            end
            return Watermark
        end
    end
end

--====================================================================
-- WINDOW + TABS (all empty, ready for your own elements)
--====================================================================

local Soda = Library;
local flags = Library.Flags;

local window = Soda:New({Size = UDim2.new(0, 620, 0, 480)});

local watermark = Soda:Watermark({Name = "v1.0"});
watermark:SetVisible(true);

--// Icons (swap with your own rbxassetid if you like)
local ICONS = {
    Information = "rbxassetid://6031075931",
    Target      = "rbxassetid://6023426921",
    Player      = "rbxassetid://6034684930",
    FunStuff    = "rbxassetid://6031265952",
    Visual      = "rbxassetid://6022668955",
    Rage        = "rbxassetid://14760676189",
    Setting     = "rbxassetid://6031280882",
};

window:Seperator({Name = "Info"});
local tab_info = window:Page({Name = "Information", Icon = ICONS.Information});

window:Seperator({Name = "Combat"});
local tab_target = window:Page({Name = "Target", Icon = ICONS.Target});
local tab_rage   = window:Page({Name = "Rage",   Icon = ICONS.Rage});

window:Seperator({Name = "Character"});
local tab_player = window:Page({Name = "Player",    Icon = ICONS.Player});
local tab_fun    = window:Page({Name = "Fun stuff", Icon = ICONS.FunStuff});

window:Seperator({Name = "Visuals"});
local tab_visual = window:Page({Name = "Visual", Icon = ICONS.Visual});

window:Seperator({Name = "System"});
local tab_setting = window:Page({Name = "Setting", Icon = ICONS.Setting});

--// Example of how to add stuff later (uncomment to test):
--[[
local sec = tab_target:Section({Name = "Main", Side = "Left", Size = 200});
sec:Toggle({Name = "Enabled", Flag = "test_on", Callback = function(s) print(s) end});
sec:Slider({Name = "FOV", Flag = "test_fov", Min = 1, Max = 180, Default = 60});
sec:List({Name = "Part", Flag = "test_part", Options = {"Head", "Torso"}, Default = "Head"});
sec:Colorpicker({Name = "Color", Flag = "test_color"});
sec:Keybind({Name = "Bind", Flag = "test_bind", Default = Enum.KeyCode.E});
sec:Textbox({Name = "Pred", Flag = "test_pred", Placeholder = "0.134"});
sec:Button({Name = "Reset", Callback = function() print("reset") end});
]]

Soda:Notification("Soda.Fun loaded successfully!", 3);
