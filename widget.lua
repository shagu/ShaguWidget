local gfind = string.gmatch or string.gfind
local nilerror, olderror = function() return end
local MakeMovable = ShaguWidget.MakeMovable

local function SetAllPointsOffset(frame, parent, offset)
  frame:SetPoint("TOPLEFT", parent, "TOPLEFT", offset, -offset)
  frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -offset, offset)
end

local function DisableErrors()
  olderror = olderror or geterrorhandler()
  seterrorhandler(nilerror)
end

local function EnableErrors()
  seterrorhandler(olderror)
end

local function PrepareLine(self, index)
  if not self.lines[index] then
    self.lines[index] = self:CreateFontString(nil, "LOW", "GameFontNormal")

    -- set line defaults
    self.lines[index].font = STANDARD_TEXT_FONT
    self.lines[index].size = 12

    -- set anchors
    if self.lines[index-1] then
      self.lines[index]:SetPoint("TOP", self.lines[index-1], "BOTTOM", 0, 0)
    else
      self.lines[index]:SetPoint("TOP", self, "TOP", 0, 0)
    end
  end
  self.lines[index]:Show()

  return self.lines[index]
end

local function UpdateContent(self)
  local i = 0
  local width, height = 0, 0
  local self = self or this

  -- check if widget was deleted
  if not ShaguWidget_config or not ShaguWidget_config[self.id] then
    self:Hide()
    return
  end

  -- only enable dragging during edit mode
  if ShaguWidget.unlock and not self.mouse then
    self:EnableMouse(1)
    self.mouse = true
  elseif not ShaguWidget.unlock and self.mouse then
    self:StopMovingOrSizing()
    self:EnableMouse(0)
    self.mouse = nil
  end

  -- enable highlight on mouseover
  if ShaguWidget.unlock and MouseIsOver(self) then
    self.highlight:Show()
    self.highlight:SetAlpha(1)
    self.alpha = 1
  end

  -- continous background fadeout
  if self.alpha and self.alpha >= 0 then
    if self.alpha <= 0 then
      self.highlight:Hide()
    else
      self.highlight:Show()
    end

    self.alpha = self.alpha - .05
    self.highlight:SetAlpha(self.alpha)
  end

  for line in gfind(ShaguWidget_config[self.id]..'\n', '(.-)\r?\n') do
    i = i + 1

    local row = PrepareLine(self, i)

    -- update font size
    local _, _, size = string.find(line, "{size (.-)}")
    line = string.gsub(line, "{size (.-)}", "")
    size = tonumber(size) or 12

    if size and size ~= row.size then
      row.update = true
      row.size = size
    end

    -- update font family
    local _, _, font = string.find(line, "{font (.-)}")
    line = string.gsub(line, "{font (.-)}", "")
    font = font and ShaguWidget.path .. "\\fonts\\" .. font .. ".ttf" or STANDARD_TEXT_FONT

    if font and font ~= row.font then
      row.update = true
      row.font = font
    end

    -- set font updates
    if row.update then
      row:SetFont(row.font, row.size)
    end

    -- parse function variables
    DisableErrors()
    line = string.gsub(line, "({.-})", ShaguWidget.ParseConfig)
    EnableErrors()

    row:SetText(line)

    width = max(row:GetWidth(), width)
    height = row:GetHeight() + height
  end

  for j=i+1, table.getn(self.lines) do
    self.lines[j]:Hide()
  end

  if width ~= self.width then
    self.width = width
    self:SetWidth(width)
  end

  if height ~= self.height then
    self.height = height
    self:SetHeight(height)
  end
end

local function CreateWidget(self, id, config)
  local widget = CreateFrame("Button", "ShaguWidget" .. id, WorldFrame)
  widget.alpha = 0
  widget.mouse = 1
  widget.lines = {}
  widget.id = id

  widget.highlight = widget:CreateTexture(nil, "BACKGROUND")
  widget.highlight:SetTexture(0,0,0,.5)
  widget.highlight:SetAlpha(0)
  SetAllPointsOffset(widget.highlight, widget, -5, -5)

  widget:SetScript("OnClick", ShaguWidget.ShowEditor)
  widget:SetScript("OnUpdate", UpdateContent)
  widget:SetPoint("RIGHT", -100, 0)
  widget:SetWidth(200)
  widget:SetHeight(200)

  MakeMovable(widget)

  return widget
end

-- add to core
ShaguWidget.CreateWidget = CreateWidget
