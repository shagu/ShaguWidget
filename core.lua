ShaguWidget = CreateFrame("Frame", "ShaguWidget", WorldFrame)
ShaguWidget:RegisterEvent("ADDON_LOADED")
ShaguWidget:SetScript("OnEvent", function()
  if arg1 ~= "ShaguWidget" and arg1 ~= "ShaguWidget-tbc" then return end

  if not ShaguWidget_config then
    ShaguWidget_config = ShaguWidget.defconfig
  end

  for id, config in pairs(ShaguWidget_config) do
    ShaguWidget.frames[id] = ShaguWidget:CreateWidget(id, config)
  end
end)

ShaguWidget.frames = {}
ShaguWidget.backdrop = {
  bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = false, tileSize = 0,
  edgeFile = "Interface\\BUTTONS\\WHITE8X8", edgeSize = 1,
  insets = {left = -1, right = -1, top = -1, bottom = -1},
}

ShaguWidget.MakeMovable = function(self, frame)
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

ShaguWidget.CreateBackdrop = function(self, frame)
  frame:SetBackdrop(self.backdrop)
  frame:SetBackdropColor(.1,.1,.1,.8)
  frame:SetBackdropBorderColor(.2,.2,.2,1)
end
