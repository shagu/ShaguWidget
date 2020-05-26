ShaguWidget = CreateFrame("Frame", "ShaguWidget", WorldFrame)
ShaguWidget:RegisterEvent("ADDON_LOADED")
ShaguWidget:SetScript("OnEvent", function()
  if strfind(arg1, "ShaguWidget") then
    -- load default config
    if not ShaguWidget_config then
      ShaguWidget_config = ShaguWidget.defconfig
    end

    -- create all widgets
    this:ReloadWidgets()
  end
end)

-- detect current addon path
local tocs = { "", "-master", "-tbc", "-wotlk" }
for _, name in pairs(tocs) do
  local current = string.format("ShaguWidget%s", name)
  local _, title = GetAddOnInfo(current)
  if title then
    ShaguWidget.name = current
    ShaguWidget.path = "Interface\\AddOns\\" .. current
    break
  end
end

ShaguWidget.frames = {}
ShaguWidget.backdrop = {
  bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = false, tileSize = 0,
  edgeFile = "Interface\\BUTTONS\\WHITE8X8", edgeSize = 1,
  insets = {left = -1, right = -1, top = -1, bottom = -1},
}

ShaguWidget.ReloadWidgets = function(self)
  for id, config in pairs(ShaguWidget_config) do
    ShaguWidget.frames[id] = ShaguWidget.frames[id] or ShaguWidget:CreateWidget(id, config)
  end
end

ShaguWidget.MakeMovable = function(frame)
  frame:EnableMouse(true)
  frame:SetMovable(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", function()
    this:StartMoving()
  end)

  frame:SetScript("OnDragStop", function()
    this:StopMovingOrSizing()
  end)
end

ShaguWidget.CreateBackdrop = function(frame)
  frame:SetBackdrop(ShaguWidget.backdrop)
  frame:SetBackdropColor(0,0,0,.8)
  frame:SetBackdropBorderColor(.2,.2,.2,1)
end
