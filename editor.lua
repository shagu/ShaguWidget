local SetHighlightEnter, SetHighlightLeave, SetHighlight, SetAllPointsOffset
local CreateScrollFrame, CreateScrollChild
local SkinButton, CreateDropDownButton, SkinArrowButton
local MakeMovable = ShaguWidget.MakeMovable
local CreateBackdrop = ShaguWidget.CreateBackdrop

do -- pfUI API exports [https://github.com/shagu/pfUI/blob/master/api/ui-widgets.lua]
  do -- dropdown
    local _, class = UnitClass("player")
    local color = RAID_CLASS_COLORS[class]

    local function ListEntryOnShow()
      if this.parent.id == this.id then
        this.icon:Show()
      else
        this.icon:Hide()
      end
    end

    local function ListEntryOnClick()
      this.parent:SetSelection(this.id)

      if this.parent.mode == "MULTISELECT" then
        this.parent:ShowMenu()
      else
        this.parent:HideMenu()
      end

      if this.parent.menu[this.id].func then
        this.parent.menu[this.id].func()
      end
    end

    local function ListEntryOnEnter()
      this.hover:Show()
    end

    local function ListEntryOnLeave()
      this.hover:Hide()
    end

    local function ListButtonOnClick()
      if this.ToggleMenu then
        this:ToggleMenu()
      else
        this:GetParent():ToggleMenu()
      end
    end

    local function MenuOnUpdate()
      if not MouseIsOver(this, 100, -100, -100, 100) then
        this.button:HideMenu()
      end
    end

    local function ListButtonOnEnter()
      this.button:SetBackdropBorderColor(this.button.cr,this.button.cg,this.button.cb,1)
    end

    local function ListButtonOnLeave()
      this.button:SetBackdropBorderColor(this.button.rr,this.button.rg,this.button.rb,1)
    end

    local handlers = {
      ["SetSelection"] = function(self, id)
        if id and self.menu and self.menu[id] then
          self.text:SetText(self.menu[id].text)
          self.id = id
        end
      end,
      ["SetSelectionByText"] = function(self, name)
        self:UpdateMenu()
        for id, entry in pairs(self.menu) do
          if entry.text == name then
            self:SetSelection(id)
            return true
          end
        end

        self.text:SetText(name)
        return nil
      end,
      ["GetSelection"] = function(self)
        self:UpdateMenu()
        if self.menu and self.menu[self.id] then
          return self.id, self.menu[self.id].text, self.menu[self.id].func
        end
      end,
      ["SetMenu"] = function(self, menu)
        if type(menu) == "function" then
          self.menu = menu()
          self.menufunc = menu
        else
          self.menu = menu
          self.menufunc = nil
        end
      end,
      ["GetMenu"] = function(self)
        self:UpdateMenu()
        return self.menu
      end,
      ["ShowMenu"] = function(self)
        self:UpdateMenu()
        self.menuframe:SetFrameLevel(self:GetFrameLevel() + 8)
        self.menuframe:SetHeight(table.getn(self.menu)*20+4)
        self.menuframe:Show()
      end,
      ["HideMenu"] = function(self)
        self.menuframe:Hide()
      end,
      ["ToggleMenu"] = function(self)
        if self.menuframe:IsShown() then
          self:HideMenu()
        else
          self:ShowMenu()
        end
      end,
      ["UpdateMenu"] = function(self)
        -- run/reload menu function if available
        if self.menufunc then self.menu = self.menufunc() end
        if not self.menu then return end

        -- set caption to the current value
        self.text:SetText(self.menu[self.id] and self.menu[self.id].text or "")

        -- refresh menu buttons
        for id, element in pairs(self.menuframe.elements) do
          element:Hide()
        end

        for id, data in pairs(self.menu) do
          self:CreateMenuEntry(id)
        end
      end,
      ["CreateMenuEntry"] = function(self, id)
        if not self.menu[id] then return end

        local frame, entry
        for count, existing in pairs(self.menuframe.elements) do
          if not existing:IsShown() then
            frame = existing
            entry = count
            break
          end
        end

        if not frame and not entry then
          entry = table.getn(self.menuframe.elements) + 1
          frame = CreateFrame("Button", nil, self.menuframe)
          frame:SetFrameStrata("FULLSCREEN")
          frame:ClearAllPoints()
          frame:SetPoint("TOPLEFT", self.menuframe, "TOPLEFT", 2, -(entry-1)*20-2)
          frame:SetPoint("TOPRIGHT", self.menuframe, "TOPRIGHT", -2, -(entry-1)*20-2)
          frame:SetHeight(20)
          frame.parent = self

          frame.icon = frame:CreateTexture(nil, "OVERLAY")
          frame.icon:SetPoint("RIGHT", frame, "RIGHT", -2, 0)
          frame.icon:SetHeight(16)
          frame.icon:SetWidth(16)
          frame.icon:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")

          frame.text = frame:CreateFontString(nil, "OVERLAY")
          frame.text:SetFontObject(GameFontWhite)
          frame.text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
          frame.text:SetJustifyH("RIGHT")
          frame.text:SetPoint("LEFT", frame, "LEFT", 2, 0)
          frame.text:SetPoint("RIGHT", frame.icon, "LEFT", -2, 0)

          frame.hover = frame:CreateTexture(nil, "BACKGROUND")
          frame.hover:SetAllPoints(frame)
          frame.hover:SetTexture(.4,.4,.4,.4)
          frame.hover:Hide()

          table.insert(self.menuframe.elements, frame)
        end

        frame.id = id
        frame.text:SetText(self.menu[id].text)

        frame:SetScript("OnShow",  ListEntryOnShow)
        frame:SetScript("OnClick", ListEntryOnClick)
        frame:SetScript("OnEnter", ListEntryOnEnter)
        frame:SetScript("OnLeave", ListEntryOnLeave)
        frame:Show()
      end,
    }
    function CreateDropDownButton(name, parent)
      local frame = CreateFrame("Button", name, parent)
      frame:SetScript("OnEnter", ListButtonOnEnter)
      frame:SetScript("OnLeave", ListButtonOnLeave)
      frame:SetScript("OnClick", ListButtonOnClick)
      frame:SetHeight(20)
      frame.id = nil

      CreateBackdrop(frame, nil, true)

      local button = CreateFrame("Button", nil, frame)
      button:SetPoint("RIGHT", frame, "RIGHT", -2, 0)
      button:SetWidth(16)
      button:SetHeight(16)
      button:SetScript("OnClick", ListButtonOnClick)
      SkinArrowButton(button, "down")
      button.icon:SetVertexColor(1,.9,.1)

      local text = frame:CreateFontString(nil, "OVERLAY")
      text:SetFontObject(GameFontWhite)
      text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
      text:SetPoint("RIGHT", button, "LEFT", -4, 0)
      text:SetJustifyH("RIGHT")

      local menuframe = CreateFrame("Frame", tostring(frame).."menu", parent)
      menuframe.button = frame
      menuframe.elements = {}
      menuframe:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -2)
      menuframe:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 2)
      menuframe:SetScript("OnUpdate", MenuOnUpdate)
      menuframe:Hide()
      CreateBackdrop(menuframe, nil, true)

      for name, func in pairs(handlers) do
        frame[name] = func
      end

      frame.menuframe = menuframe
      frame.button = button
      frame.text = text

      return frame
    end
  end

  function SetAllPointsOffset(frame, parent, offset)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", offset, -offset)
    frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -offset, offset)
  end

  function SetHighlightEnter()
    if this.funce then this:funce() end
    if this.locked then return end
    (this.backdrop or this):SetBackdropBorderColor(this.cr,this.cg,this.cb,1)
  end

  function SetHighlightLeave()
    if this.funcl then this:funcl() end
    if this.locked then return end
    (this.backdrop or this):SetBackdropBorderColor(this.rr,this.rg,this.rb,1)
  end

  function SetHighlight(frame, cr, cg, cb)
    if not frame then return end
    if not cr or not cg or not cb then
      local _, class = UnitClass("player")
      local color = RAID_CLASS_COLORS[class]
      cr, cg, cb = color.r , color.g, color.b
    end

    frame.cr, frame.cg, frame.cb = cr, cg, cb
    frame.rr, frame.rg, frame.rb = .2, .2, .2

    if not frame.pfEnterLeave then
      frame.funce = frame:GetScript("OnEnter")
      frame.funcl = frame:GetScript("OnLeave")
      frame:SetScript("OnEnter", SetHighlightEnter)
      frame:SetScript("OnLeave", SetHighlightLeave)
      frame.pfEnterLeave = true
    end
  end

  function CreateScrollFrame(name, parent)
    local f = CreateFrame("ScrollFrame", name, parent)

    -- create slider
    f.slider = CreateFrame("Slider", nil, f)
    f.slider:SetOrientation('VERTICAL')
    f.slider:SetPoint("TOPLEFT", f, "TOPRIGHT", -7, 0)
    f.slider:SetPoint("BOTTOMRIGHT", 0, 0)
    f.slider:SetThumbTexture("Interface\\BUTTONS\\WHITE8X8")
    f.slider.thumb = f.slider:GetThumbTexture()
    f.slider.thumb:SetHeight(50)
    f.slider.thumb:SetTexture(.3,1,.8,.5)

    f.slider:SetScript("OnValueChanged", function()
      f:SetVerticalScroll(this:GetValue())
      f.UpdateScrollState()
    end)

    f.UpdateScrollState = function()
      f.slider:SetMinMaxValues(0, f:GetVerticalScrollRange())
      f.slider:SetValue(f:GetVerticalScroll())

      local m = f:GetHeight()+f:GetVerticalScrollRange()
      local v = f:GetHeight()
      local ratio = v / m

      if ratio < 1 then
        local size = math.floor(v * ratio)
        f.slider.thumb:SetHeight(size)
        f.slider:Show()
      else
        f.slider:Hide()
      end
    end

    f.Scroll = function(self, step)
      local step = step or 0

      local current = f:GetVerticalScroll()
      local max = f:GetVerticalScrollRange()
      local new = current - step

      if new >= max then
        f:SetVerticalScroll(max)
      elseif new <= 0 then
        f:SetVerticalScroll(0)
      else
        f:SetVerticalScroll(new)
      end

      f:UpdateScrollState()
    end

    f:EnableMouseWheel(1)
    f:SetScript("OnMouseWheel", function()
      this:Scroll(arg1*10)
    end)

    return f
  end

  function CreateScrollChild(name, parent)
    local f = CreateFrame("Frame", name, parent)

    -- dummy values required
    f:SetWidth(1)
    f:SetHeight(1)
    f:SetAllPoints(parent)

    parent:SetScrollChild(f)

    -- OnShow is fired too early, postpone to the first frame draw
    f:SetScript("OnUpdate", function()
      this:GetParent():Scroll()
      this:SetScript("OnUpdate", nil)
    end)

    return f
  end

  function SkinButton(button, cr, cg, cb, icon, disableHighlight)
    local b = _G[button]
    if not b then b = button end
    if not b then return end
    if not cr or not cg or not cb then
      local _, class = UnitClass("player")
      local color = RAID_CLASS_COLORS[class]
      cr, cg, cb = color.r , color.g, color.b
    end
    CreateBackdrop(b)
    b:SetNormalTexture("")
    b:SetHighlightTexture("")
    b:SetPushedTexture("")
    b:SetDisabledTexture("")
    if b.SetCheckedTexture then
      b:SetCheckedTexture(nil)
      function b.SetChecked(self, checked)
        if checked == 1 then
          self.locked = true
          self:SetBackdropBorderColor(1,1,1)
        else
          self.locked = false
          self:SetBackdropBorderColor(.2,.2,.2,1)
        end
      end
    end

    if not disableHighlight then
      SetHighlight(b, cr, cg, cb)
    end

    if icon then
      HandleIcon(b, icon)
      b:SetPushedTexture(nil)
    end

    b:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")

    b.LockHighlight = function()
      b:SetBackdropBorderColor(cr,cg,cb,1)
      b.locked = true
    end
    b.UnlockHighlight = function()
      if not MouseIsOver(b) then
        b:SetBackdropBorderColor(.2,.2,.2,1)
      end
      b.locked = false
    end
  end

  function SkinArrowButton(button, dir, size)
    SkinButton(button)

    button:SetHitRectInsets(-3,-3,-3,-3)

    button:SetNormalTexture(nil)
    button:SetPushedTexture(nil)
    button:SetHighlightTexture(nil)
    button:SetDisabledTexture(nil)

    if size then
      button:SetWidth(size)
      button:SetHeight(size)
    end

    if not button.icon then
      button.icon = button:CreateTexture(nil, "ARTWORK")
      button.icon:SetAlpha(.8)
      SetAllPointsOffset(button.icon, button, 3)
    end

    button.icon:SetTexture(ShaguWidget.path .. "\\img\\" .. dir)
  end
end

local editor = CreateFrame("Frame", "ShaguWidgetEditor", UIParent)
editor:Hide()
editor:SetPoint("CENTER", 0, 0)
editor:SetWidth(580)
editor:SetHeight(420)

editor:SetScript("OnShow", function()
  ShaguWidget.unlock = true
end)

editor:SetScript("OnHide", function()
  ShaguWidget.unlock = nil
  ShaguWidget.edit = nil
end)

editor.LoadConfig = function(self, name)
  local config = ShaguWidget_config[name]

  -- set window text
  self.scroll.text:SetText(config)

  -- set visibility
  if ShaguWidget_visible[name] then
    self.visible:SetChecked(1)
  else
    self.visible:SetChecked(0)
  end

  -- set editing mode
  ShaguWidget.edit = name

  -- update dropdown menu
  self.input:SetSelectionByText(name)
end

MakeMovable(editor)
CreateBackdrop(editor)

table.insert(UISpecialFrames, "ShaguWidgetEditor")

do -- Edit Box
  editor.scroll = CreateScrollFrame("ShaguWidgetEditorScroll", editor)
  editor.scroll:SetPoint("TOPLEFT", editor, "TOPLEFT", 10, -65)
  editor.scroll:SetPoint("BOTTOMRIGHT", editor, "BOTTOMRIGHT", -10, 10)
  editor.scroll:SetWidth(560)
  editor.scroll:SetHeight(400)

  editor.scroll.backdrop = CreateFrame("Frame", "ShaguWidgetEditorScrollBackdrop", editor.scroll)
  editor.scroll.backdrop:SetFrameLevel(1)
  editor.scroll.backdrop:SetPoint("TOPLEFT", editor.scroll, "TOPLEFT", -5, 5)
  editor.scroll.backdrop:SetPoint("BOTTOMRIGHT", editor.scroll, "BOTTOMRIGHT", 5, -5)

  editor.scroll.text = CreateFrame("EditBox", "ShaguWidgetEditorScrollEditBox", editor.scroll)
  editor.scroll.text.bg = editor.scroll.text:CreateTexture(nil, "BACKGROUND")
  editor.scroll.text.bg:SetTexture(.2,.2,.2,.2)
  editor.scroll.text:SetMultiLine(true)
  editor.scroll.text:SetWidth(560)
  editor.scroll.text:SetHeight(400)
  editor.scroll.text:SetAllPoints(editor.scroll)
  editor.scroll.text:SetTextInsets(15,15,15,15)
  editor.scroll.text:SetFont(ShaguWidget.path .. "\\fonts\\RobotoMono.ttf", 10)
  editor.scroll.text:SetTextColor(.8,1,.8,1)
  editor.scroll.text:SetAutoFocus(false)
  editor.scroll.text:SetJustifyH("LEFT")
  editor.scroll.text:SetScript("OnEscapePressed", function() this:ClearFocus() end)
  editor.scroll.text:SetScript("OnTextChanged", function()
    this:GetParent():UpdateScrollChildRect()
    this:GetParent():UpdateScrollState()
    local id, text = editor.input:GetSelection()
    if not ShaguWidget_config[text] then return end
    ShaguWidget_config[text] = this:GetText()
  end)

  editor.scroll:SetScrollChild(editor.scroll.text)

  SetAllPointsOffset(editor.scroll.text.bg, editor.scroll.text, 2)
  CreateBackdrop(editor.scroll)
end

do -- button: close
  editor.close = CreateFrame("Button", "ShaguWidgetEditorClose", editor)
  editor.close:SetPoint("TOPRIGHT", -5, -5)
  editor.close:SetHeight(12)
  editor.close:SetWidth(12)
  editor.close.texture = editor.close:CreateTexture()
  editor.close.texture:SetTexture(ShaguWidget.path .. "\\img\\close")
  editor.close.texture:ClearAllPoints()
  editor.close.texture:SetAllPoints(editor.close)
  editor.close.texture:SetVertexColor(1,.25,.25,1)
  editor.close:SetScript("OnClick", function()
   this:GetParent():Hide()
  end)
  SkinButton(editor.close, 1, .5, .5)
end

StaticPopupDialogs["SHAGUWIDGET_NEW"] = {
  text = "Please enter the name for the new widget:",
  button1 = OKAY,
  button2 = CANCEL,
  timeout = 0,
  whileDead = 1,
  hideOnEscape = 1,
  hasEditBox = 1,
  maxLetters = 16,
  OnShow = function()
    getglobal(this:GetName().."Button1"):Disable()
    getglobal(this:GetName().."EditBox"):SetFocus()
    getglobal(this:GetName().."EditBox"):SetText("")
  end,
  EditBoxOnTextChanged = function ()
    local editBox = getglobal(this:GetParent():GetName().."EditBox")
    if string.len(editBox:GetText()) > 0 then
      getglobal(this:GetParent():GetName().."Button1"):Enable()
    else
      getglobal(this:GetParent():GetName().."Button1"):Disable()
    end
  end,
  EditBoxOnEscapePressed = function()
    this:GetParent():Hide()
  end
}

StaticPopupDialogs["SHAGUWIDGET_DELETE"] = {
  button1 = YES,
  button2 = NO,
  timeout = 0,
  whileDead = 1,
  hideOnEscape = 1,
}

do -- caption: title
  editor.title = editor:CreateFontString(nil, "OVERLAY", GameFontWhite)
  editor.title:SetPoint("TOP", editor, "TOP", 0, -10)
  editor.title:SetFont(STANDARD_TEXT_FONT, 14)
  editor.title:SetText("|cff33ffccShagu|cffffffffWidget")
end

do -- button: add
  editor.add = CreateFrame("Button", nil, editor, "UIPanelButtonTemplate")
  SkinButton(editor.add)
  editor.add:SetWidth(75)
  editor.add:SetHeight(22)
  editor.add:SetPoint("TOPLEFT", editor, "TOPLEFT", 10, -35)
  editor.add:GetFontString():SetPoint("CENTER", 1, 0)
  editor.add:SetText("[ + ] |cffccffcc New")
  editor.add:SetTextColor(.5,1,.5,1)
  editor.add:SetScript("OnClick", function()
    local dialog = StaticPopupDialogs["SHAGUWIDGET_NEW"]
    dialog.OnAccept = function()
      if ( getglobal(this:GetParent():GetName().."Button1"):IsEnabled() == 1 ) then
        local editBox = getglobal(this:GetParent():GetName().."EditBox")
        local text = editBox:GetText()
        ShaguWidget_config[text] = [[New Widget]]
        ShaguWidget:ReloadWidgets()
        editor:LoadConfig(text)
        this:GetParent():Hide()
      end
    end
    dialog.EditBoxOnEnterPressed = dialog.OnAccept
    StaticPopup_Show("SHAGUWIDGET_NEW")
  end)
end

do -- button: delete
  editor.del = CreateFrame("Button", nil, editor, "UIPanelButtonTemplate")
  SkinButton(editor.del)
  editor.del:SetWidth(75)
  editor.del:SetHeight(22)
  editor.del:SetPoint("LEFT", editor.add, "RIGHT", 5, 0)
  editor.del:GetFontString():SetPoint("CENTER", 1, 0)
  editor.del:SetText("[ x ] |cffffcccc Remove")
  editor.del:SetTextColor(1,.5,.5,1)
  editor.del:SetScript("OnClick", function()
    local id, text = editor.input:GetSelection()
    local dialog = StaticPopupDialogs["SHAGUWIDGET_DELETE"]
    dialog.text = "Do you really want to delete |cff33ffcc" .. text .. "|r?"
    dialog.OnAccept = function()
      ShaguWidget_config[text] = nil
      ShaguWidget:ReloadWidgets()

      -- set to first entry after deletion
      for name in pairs(ShaguWidget_config) do
        editor:LoadConfig(name)
        break
      end
    end

    StaticPopup_Show("SHAGUWIDGET_DELETE")
  end)
end

do -- dropdown: select
  editor.input = CreateDropDownButton(nil, editor)
  editor.input.menuframe:SetParent(editor)
  editor.input:SetPoint("LEFT", editor.del, "RIGHT", 5, 0)
  editor.input:SetWidth(150)
  editor.input:SetHeight(22)
  editor.input:SetMenu(function()
    local menu = {}
    if ShaguWidget_config then
      for name, config in pairs(ShaguWidget_config) do
        table.insert(menu, {
          text = name,
          func = function()
            editor:LoadConfig(name)
          end
        })
      end
    end
    return menu
  end)
end

do -- character visible
  editor.visible = CreateFrame("CheckButton", nil, editor, "UICheckButtonTemplate")
  editor.visible:SetNormalTexture("")
  editor.visible:SetPushedTexture("")
  editor.visible:SetHighlightTexture("")
  CreateBackdrop(editor.visible)
  editor.visible:SetWidth(14)
  editor.visible:SetHeight(14)
  editor.visible:SetPoint("TOPRIGHT" , -10, -40)
  editor.visible:SetScript("OnClick", function ()
    local id, text = editor.input:GetSelection()
    if text and this:GetChecked() then
      ShaguWidget_visible[text] = true
    elseif text then
      ShaguWidget_visible[text] = nil
    end

    ShaguWidget:ReloadWidgets()
  end)

  editor.visible_font = editor:CreateFontString(nil, "OVERLAY", GameFontWhite)
  editor.visible_font:SetFont(STANDARD_TEXT_FONT, 12)
  editor.visible_font:SetPoint("RIGHT", editor.visible, "LEFT", -5, 0)
  editor.visible_font:SetText(DISPLAY .. " on " .. UnitName("player"))
end

-- add to core
ShaguWidget.ShowEditor = function(self, id)
  local config = self.id

  -- use first config on invalid id
  if not ShaguWidget_config[self.id] then
    for id in pairs(ShaguWidget_config) do
      config = id
      break
    end
  end

  editor:LoadConfig(config)
  editor:Show()
end
