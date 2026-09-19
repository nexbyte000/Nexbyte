--[[ MODERN UI v6.1 — Delta Edition (sem Fly) ]]
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local StarterGui       = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    Title = "MODERN UI", Subtitle = "v6.1",
    Keybind = Enum.KeyCode.RightShift,
    DefaultWalkSpeed = 16, MaxWalkSpeed = 300,
}

local T = {
    Bg=Color3.fromRGB(18,18,24), Surface=Color3.fromRGB(26,27,35),
    Surface2=Color3.fromRGB(34,36,46), Border=Color3.fromRGB(48,50,62),
    Text=Color3.fromRGB(235,235,245), TextDim=Color3.fromRGB(150,152,165),
    Accent=Color3.fromRGB(110,130,255), AccentDk=Color3.fromRGB(80,100,220),
    Font=Enum.Font.Gotham, FontBold=Enum.Font.GothamBold,
}

local function notify(t, x, d)
    pcall(function()
        StarterGui:SetCore("SendNotification",{Title=t,Text=x,Duration=d or 5})
    end)
end
local function tw(o,p,t)
    pcall(function() TweenService:Create(o,TweenInfo.new(t or 0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),p):Play() end)
end
local function corner(p,r)
    local c=Instance.new("UICorner"); c.CornerRadius=r or UDim.new(0,6); c.Parent=p; return c
end
local function stroke(p,col,th)
    local s=Instance.new("UIStroke"); s.Color=col or T.Border; s.Thickness=th or 1; s.Parent=p; return s
end
local function getParent()
    if gethui then local ok,h=pcall(gethui); if ok and h then return h end end
    local pg=LocalPlayer:FindFirstChildOfClass("PlayerGui"); if pg then return pg end
    local ok,cg=pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then return cg end
    return LocalPlayer:WaitForChild("PlayerGui",5)
end

--========== COMPONENTES ==========
local UI = {}

function UI.Toggle(parent, text, default, cb)
    local state = default or false
    local row = Instance.new("Frame")
    row.BackgroundColor3=T.Surface2; row.BorderSizePixel=0
    row.Size=UDim2.new(1,0,0,32); row.Parent=parent; corner(row,UDim.new(0,5))
    local lbl=Instance.new("TextLabel")
    lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(1,-50,1,0); lbl.Position=UDim2.new(0,10,0,0)
    lbl.Font=T.Font; lbl.Text=text; lbl.TextColor3=T.Text; lbl.TextSize=12
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=row
    local sw=Instance.new("TextButton")
    sw.BackgroundColor3=state and T.Accent or T.Border; sw.BorderSizePixel=0
    sw.Size=UDim2.new(0,36,0,18); sw.Position=UDim2.new(1,-46,0.5,-9)
    sw.Text=""; sw.AutoButtonColor=false; sw.Parent=row; corner(sw,UDim.new(1,0))
    local knob=Instance.new("Frame")
    knob.BackgroundColor3=Color3.new(1,1,1); knob.BorderSizePixel=0
    knob.Size=UDim2.new(0,14,0,14)
    knob.Position=state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
    knob.Parent=sw; corner(knob,UDim.new(1,0))
    local function set(v)
        state=v
        tw(sw,{BackgroundColor3=state and T.Accent or T.Border},0.15)
        tw(knob,{Position=state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)},0.15)
        if cb then pcall(cb,state) end
    end
    sw.MouseButton1Click:Connect(function() set(not state) end)
    return {Instance=row,Set=set,Get=function() return state end}
end

function UI.Slider(parent, text, min, max, default, cb)
    local value = default or min
    local box = Instance.new("Frame")
    box.BackgroundColor3=T.Surface2; box.BorderSizePixel=0
    box.Size=UDim2.new(1,0,0,54); box.Parent=parent; corner(box,UDim.new(0,5))
    local lbl=Instance.new("TextLabel")
    lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(1,-70,0,16); lbl.Position=UDim2.new(0,10,0,6)
    lbl.Font=T.Font; lbl.Text=text; lbl.TextColor3=T.Text; lbl.TextSize=12
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=box
    local inp=Instance.new("TextBox")
    inp.BackgroundColor3=T.Bg; inp.BorderSizePixel=0
    inp.Size=UDim2.new(0,52,0,20); inp.Position=UDim2.new(1,-60,0,5)
    inp.Font=T.Font; inp.Text=tostring(value); inp.TextColor3=T.Text; inp.TextSize=11
    inp.ClearTextOnFocus=false; inp.Parent=box; corner(inp,UDim.new(0,4)); stroke(inp,T.Border,1)
    local track=Instance.new("TextButton")
    track.BackgroundColor3=T.Border; track.BorderSizePixel=0
    track.Size=UDim2.new(1,-20,0,6); track.Position=UDim2.new(0,10,1,-14)
    track.Text=""; track.AutoButtonColor=false; track.Parent=box; corner(track,UDim.new(1,0))
    local fill=Instance.new("Frame")
    fill.BackgroundColor3=T.Accent; fill.BorderSizePixel=0
    fill.Size=UDim2.new((value-min)/(max-min),0,1,0); fill.Parent=track; corner(fill,UDim.new(1,0))
    local dragging=false
    local function applyX(x)
        local rel=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        value=math.floor(min+rel*(max-min)); inp.Text=tostring(value)
        fill.Size=UDim2.new(rel,0,1,0); if cb then pcall(cb,value) end
    end
    track.InputBegan:Connect(function(io)
        if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then
            dragging=true; applyX(io.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(io)
        if dragging and (io.UserInputType==Enum.UserInputType.MouseMovement or io.UserInputType==Enum.UserInputType.Touch) then
            applyX(io.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(io)
        if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then
            dragging=false
        end
    end)
    inp.FocusLost:Connect(function()
        local n=tonumber(inp.Text)
        if n then
            n=math.clamp(n,min,max); value=n; inp.Text=tostring(n)
            fill.Size=UDim2.new((n-min)/(max-min),0,1,0); if cb then pcall(cb,value) end
        else inp.Text=tostring(value) end
    end)
    return {Instance=box,Set=function(v)
        v=math.clamp(v,min,max); value=v; inp.Text=tostring(v)
        fill.Size=UDim2.new((v-min)/(max-min),0,1,0); if cb then pcall(cb,v) end
    end,Get=function() return value end}
end

function UI.Section(parent, titleText, order)
    local s=Instance.new("Frame")
    s.BackgroundColor3=T.Surface; s.BorderSizePixel=0
    s.Size=UDim2.new(1,0,0,0); s.AutomaticSize=Enum.AutomaticSize.Y
    s.LayoutOrder=order or 0; s.Parent=parent; corner(s,UDim.new(0,8)); stroke(s,T.Border,1)
    local pad=Instance.new("UIPadding")
    pad.PaddingTop=UDim.new(0,8); pad.PaddingBottom=UDim.new(0,8)
    pad.PaddingLeft=UDim.new(0,8); pad.PaddingRight=UDim.new(0,8); pad.Parent=s
    local lay=Instance.new("UIListLayout")
    lay.Padding=UDim.new(0,6); lay.SortOrder=Enum.SortOrder.LayoutOrder; lay.Parent=s
    local t=Instance.new("TextLabel")
    t.BackgroundTransparency=1; t.Size=UDim2.new(1,0,0,16); t.Font=T.FontBold
    t.Text=string.upper(titleText); t.TextColor3=T.Accent; t.TextSize=10
    t.TextXAlignment=Enum.TextXAlignment.Left; t.LayoutOrder=-1; t.Parent=s
    return s
end

--========== FEATURES ==========
local F = {}

F.Speed = (function()
    local en, sp, cn = false, CONFIG.DefaultWalkSpeed, nil
    local function apply()
        local c=LocalPlayer.Character; if not c then return end
        local h=c:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = en and sp or CONFIG.DefaultWalkSpeed end
    end
    return {
        Enable=function(v)
            en=v
            if v then
                if cn then cn:Disconnect() end
                cn=RunService.Heartbeat:Connect(apply)
            else
                if cn then cn:Disconnect(); cn=nil end
                apply()
            end
        end,
        SetSpeed=function(v) sp=v; apply() end,
    }
end)()

F.Noclip = (function()
    local en, cn = false, nil
    local function loop()
        local c=LocalPlayer.Character; if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide=false end
        end
    end
    return {
        Enable=function(v)
            en=v
            if v then
                if cn then cn:Disconnect() end
                cn=RunService.Stepped:Connect(loop)
            else
                if cn then cn:Disconnect(); cn=nil end
                local c=LocalPlayer.Character
                if c then
                    for _,p in ipairs(c:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide=true end
                    end
                end
            end
        end,
    }
end)()

F.ESP = (function()
    local en = false
    local draw = {}
    local function create(plr)
        if plr==LocalPlayer then return end
        local c = plr.Character
        if not c or draw[plr] then return end
        local hl = Instance.new("Highlight")
        hl.FillColor=T.Accent; hl.OutlineColor=Color3.new(1,1,1)
        hl.FillTransparency=0.6; hl.Adornee=c; hl.Parent=c
        local head = c:FindFirstChild("Head")
        if head then
            local bb = Instance.new("BillboardGui")
            bb.Adornee=head; bb.Size=UDim2.new(0,100,0,20)
            bb.StudsOffsetWorldSpace=Vector3.new(0,3,0)
            bb.AlwaysOnTop=true; bb.Parent=c
            local l = Instance.new("TextLabel")
            l.BackgroundTransparency=1; l.Size=UDim2.new(1,0,1,0)
            l.Font=T.FontBold; l.Text=plr.Name; l.TextColor3=Color3.new(1,1,1)
            l.TextStrokeTransparency=0.2; l.TextSize=12; l.Parent=bb
            draw[plr]={hl=hl,bb=bb}
        else draw[plr]={hl=hl} end
    end
    local function remove(plr)
        local d=draw[plr]; if not d then return end
        if d.hl then d.hl:Destroy() end
        if d.bb then d.bb:Destroy() end
        draw[plr]=nil
    end
    local cs = {}
    return {
        Enable=function(v)
            en=v
            if v then
                for _,p in ipairs(Players:GetPlayers()) do create(p) end
                table.insert(cs,Players.PlayerAdded:Connect(function(p) if en then create(p) end end))
                table.insert(cs,Players.PlayerRemoving:Connect(remove))
            else
                for _,c in ipairs(cs) do pcall(function() c:Disconnect() end) end
                cs={}
                for plr,_ in pairs(draw) do remove(plr) end
            end
        end,
    }
end)()

--========== BUILD UI ==========
local function buildUI()
    local parent = getParent()
    if not parent then notify("Erro","Sem parent",10) return end

    local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
        or Vector2.new(800,600)
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

    local WIN_W, WIN_H
    if isMobile then
        WIN_W = math.clamp(vp.X * 0.72, 240, 320)
        WIN_H = math.clamp(vp.Y * 0.55, 300, 460)
    else
        WIN_W = 280; WIN_H = 440
    end

    local gui = Instance.new("ScreenGui")
    gui.Name="ModernCheatUI_v6_1"
    gui.ResetOnSpawn=false
    gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset=true
    gui.DisplayOrder=999
    gui.Parent=parent

    --============ BOTÃO ≡ (arrastável) ============
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size=UDim2.new(0,42,0,42)
    toggleBtn.Position=UDim2.new(1,-54,0,20)
    toggleBtn.BackgroundColor3=T.Accent; toggleBtn.BorderSizePixel=0
    toggleBtn.Text="≡"; toggleBtn.Font=T.FontBold; toggleBtn.TextSize=22
    toggleBtn.TextColor3=Color3.new(1,1,1); toggleBtn.AutoButtonColor=false
    toggleBtn.Active=true; toggleBtn.Parent=gui
    corner(toggleBtn,UDim.new(1,0)); stroke(toggleBtn,T.AccentDk,1)

    local bDrag, bStart, bPos, bMoved = false, nil, nil, false
    toggleBtn.InputBegan:Connect(function(io)
        if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then
            bDrag=true; bMoved=false
            bStart=io.Position; bPos=toggleBtn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(io)
        if not bDrag then return end
        if io.UserInputType==Enum.UserInputType.MouseMovement or io.UserInputType==Enum.UserInputType.Touch then
            local d = io.Position - bStart
            if math.abs(d.X)>5 or math.abs(d.Y)>5 then bMoved=true end
            toggleBtn.Position = UDim2.new(
                bPos.X.Scale, bPos.X.Offset+d.X,
                bPos.Y.Scale, bPos.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(io)
        if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then
            bDrag=false
        end
    end)

    --============ JANELA ============
    local win = Instance.new("Frame")
    win.Size=UDim2.new(0,WIN_W,0,WIN_H)
    win.Position=UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2)
    win.BackgroundColor3=T.Bg; win.BorderSizePixel=0
    win.Active=true; win.Parent=gui
    corner(win,UDim.new(0,10)); stroke(win,T.Border,1)

    local header = Instance.new("Frame")
    header.Size=UDim2.new(1,0,0,42); header.BackgroundColor3=T.Surface
    header.BorderSizePixel=0; header.Active=true; header.Parent=win
    corner(header,UDim.new(0,10))

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency=1; title.Size=UDim2.new(1,-40,0,20)
    title.Position=UDim2.new(0,12,0,5); title.Font=T.FontBold
    title.Text=CONFIG.Title; title.TextColor3=T.Text; title.TextSize=13
    title.TextXAlignment=Enum.TextXAlignment.Left; title.Parent=header

    local sub = Instance.new("TextLabel")
    sub.BackgroundTransparency=1; sub.Size=UDim2.new(1,-40,0,12)
    sub.Position=UDim2.new(0,12,0,24); sub.Font=T.Font
    sub.Text=CONFIG.Subtitle; sub.TextColor3=T.TextDim; sub.TextSize=9
    sub.TextXAlignment=Enum.TextXAlignment.Left; sub.Parent=header

    local minBtn = Instance.new("TextButton")
    minBtn.Size=UDim2.new(0,22,0,22); minBtn.Position=UDim2.new(1,-30,0,10)
    minBtn.BackgroundColor3=T.Surface2; minBtn.BorderSizePixel=0
    minBtn.Text="–"; minBtn.Font=T.FontBold; minBtn.TextColor3=T.Text
    minBtn.TextSize=14; minBtn.AutoButtonColor=false; minBtn.Parent=header
    corner(minBtn,UDim.new(0,5))

    local scroll = Instance.new("ScrollingFrame")
    scroll.Position=UDim2.new(0,0,0,42); scroll.Size=UDim2.new(1,0,1,-42)
    scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0
    scroll.ScrollBarThickness=4; scroll.ScrollBarImageColor3=T.Accent
    scroll.CanvasSize=UDim2.new(0,0,0,0)
    scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
    scroll.Active=true; scroll.Parent=win
    scroll.ScrollingDirection = Enum.ScrollingDirection.Y

    local pad = Instance.new("UIPadding")
    pad.PaddingTop=UDim.new(0,8); pad.PaddingBottom=UDim.new(0,8)
    pad.PaddingLeft=UDim.new(0,8); pad.PaddingRight=UDim.new(0,8); pad.Parent=scroll

    local lay = Instance.new("UIListLayout")
    lay.Padding=UDim.new(0,8); lay.SortOrder=Enum.SortOrder.LayoutOrder; lay.Parent=scroll

    local resizeH = Instance.new("TextButton")
    resizeH.Size=UDim2.new(0,22,0,22); resizeH.Position=UDim2.new(1,-22,1,-22)
    resizeH.BackgroundColor3=T.Accent; resizeH.BackgroundTransparency=0.3
    resizeH.BorderSizePixel=0; resizeH.Text="⇲"; resizeH.Font=T.FontBold
    resizeH.TextColor3=Color3.new(1,1,1); resizeH.TextSize=14
    resizeH.AutoButtonColor=false; resizeH.ZIndex=5; resizeH.Parent=win
    corner(resizeH,UDim.new(0,6))

    --============ SEÇÕES ============
    local speedSec = UI.Section(scroll,"Speed",1)
    UI.Toggle(speedSec,"Ativar Speed",false,function(v) F.Speed.Enable(v) end)
    UI.Slider(speedSec,"Velocidade",16,CONFIG.MaxWalkSpeed,CONFIG.DefaultWalkSpeed,function(v) F.Speed.SetSpeed(v) end)

    local noclipSec = UI.Section(scroll,"Noclip",2)
    UI.Toggle(noclipSec,"Ativar Noclip",false,function(v) F.Noclip.Enable(v) end)

    local espSec = UI.Section(scroll,"Ver Jogadores",3)
    UI.Toggle(espSec,"Ativar ESP",false,function(v) F.ESP.Enable(v) end)

    --============ DRAG DA JANELA ============
    do
        local d, s, p = false, nil, nil
        header.InputBegan:Connect(function(io)
            if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then
                d=true; s=io.Position; p=win.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(io)
            if not d then return end
            if io.UserInputType==Enum.UserInputType.MouseMovement or io.UserInputType==Enum.UserInputType.Touch then
                local dl = io.Position - s
                win.Position = UDim2.new(p.X.Scale, p.X.Offset+dl.X, p.Y.Scale, p.Y.Offset+dl.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(io)
            if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then
                d=false
            end
        end)
    end

    --============ RESIZE ============
    do
        local r, s, sz = false, nil, nil
        resizeH.InputBegan:Connect(function(io)
            if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then
                r=true; s=io.Position
                sz=Vector2.new(win.AbsoluteSize.X, win.AbsoluteSize.Y)
            end
        end)
        UserInputService.InputChanged:Connect(function(io)
            if not r then return end
            if io.UserInputType==Enum.UserInputType.MouseMovement or io.UserInputType==Enum.UserInputType.Touch then
                local dl = io.Position - s
                local w = math.clamp(sz.X + dl.X, 180, 700)
                local h = math.clamp(sz.Y + dl.Y, 200, 900)
                win.Size = UDim2.new(0, w, 0, h)
            end
        end)
        UserInputService.InputEnded:Connect(function(io)
            if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then
                r=false
            end
        end)
    end

    --============ MINIMIZE ============
    local open = true
    local function setOpen(v)
        open = v
        if v then
            win.Visible = true
            win.Size = UDim2.new(0,0,0,WIN_H)
            tw(win,{Size=UDim2.new(0,WIN_W,0,WIN_H)},0.2)
        else
            tw(win,{Size=UDim2.new(0,0,0,WIN_H)},0.18)
            task.delay(0.2,function() if not open then win.Visible=false end end)
        end
    end

    minBtn.MouseButton1Click:Connect(function() setOpen(false) end)
    toggleBtn.MouseButton1Click:Connect(function()
        if bMoved then return end
        setOpen(not open)
    end)
    UserInputService.InputBegan:Connect(function(io, gpe)
        if gpe then return end
        if io.KeyCode == CONFIG.Keybind then setOpen(not open) end
    end)
end

--========== EXEC ==========
local ok, err = pcall(buildUI)
if ok then
    notify("Modern UI","v6.1 carregada!",5)
    print("[ModernUI v6.1] ✅ OK")
else
    warn("[ModernUI v6.1] ❌ "..tostring(err))
    notify("Erro",tostring(err):sub(1,100),10)
end
