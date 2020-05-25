local gfind = string.gmatch or string.gfind
local nilerror, olderror = function() return end

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
  widget.lines = {}
  widget.id = id

  widget:SetScript("OnClick", ShaguWidget.ShowEditor)
  widget:SetScript("OnUpdate", UpdateContent)
  widget:SetPoint("CENTER", 0, 0)
  widget:SetWidth(200)
  widget:SetHeight(200)

  ShaguWidget:MakeMovable(widget)

  return widget
end

-- add to core
ShaguWidget.CreateWidget = CreateWidget
