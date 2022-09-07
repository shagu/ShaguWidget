local gfind = string.gmatch or string.gfind

local function strsplit(delimiter, subject)
  if not subject then return nil end
  local delimiter, fields = delimiter or ":", {}
  local pattern = string.format("([^%s]+)", delimiter)
  string.gsub(subject, pattern, function(c) fields[table.getn(fields) + 1] = c end)
  return fields
end

local function round(input, places)
  if not places then places = 0 end
  if type(input) == "number" and type(places) == "number" then
    local pow = 1
    for i = 1, places do pow = pow * 10 end
    return floor(input * pow + 0.5) / pow
  end
end

local varcache, elements, fired, events = {}, {}, {}, { ["NONE"] = true, ["TIMER"] = true }
local updater = CreateFrame("Frame", "ShaguWidgetUpdater", WorldFrame)
updater:SetScript("OnUpdate", function()
  if (this.tick or 1) > GetTime() then return else this.tick = GetTime() + .1 end

  -- update clock timers each .1 second
  fired["CLOCK"] = true

  -- update timers each .5 second
  if (this.timer or 1) < GetTime() then
    this.timer = GetTime() + .5
    fired["TIMER"] = true
  end

  -- handle events
  for event in pairs(fired) do
    for capture, data in pairs(varcache) do
      if strfind(data[1], event .. ":") or strfind(data[1], event .. "$") then
        varcache[capture] = nil
      end
    end

    fired[event] = nil
  end
end)

updater:SetScript("OnEvent", function()
  fired[event] = true
end)

local captures = {
  ["{color(.-)}"] = { "NONE", function(params)
    return params and "|cff" .. params or "|r"
  end },
  ["{date(.-)}"] = { "CLOCK", function(params)
    return date(params) or ""
  end },
  ["{name(.-)}"] = { "TIMER:PLAYER_TARGET_CHANGED", function(params)
    return UnitName((params or "player")) or ""
  end },
  ["{level(.-)}"] = { "UNIT_LEVEL:PLAYER_TARGET_CHANGED", function(params)
    return UnitLevel((params or "player")) or ""
  end },
  ["{elite(.-)}"] = { "TIMER:PLAYER_TARGET_CHANGED", function(params, args)
    local target, defstrings = "player", "_,+,R+,B,R"
    local strings

    if params then
      local split = strsplit(" ", params)
      target = split[1] or target
      strings = strsplit(",", (split[2] or defstrings))
    end

    local elite = UnitClassification(target)

    if elite == "elite" then
      return strings[2] == "_" and "" or strings[2]
    elseif elite == "rareelite" then
      return strings[3] == "_" and "" or strings[3]
    elseif elite == "worldboss" then
      return strings[4] == "_" and "" or strings[4]
    elseif elite == "rare" then
      return strings[5] == "_" and "" or strings[5]
    else
      return strings[1] == "_" and "" or strings[1]
    end
  end },
  ["{health(.-)}"] = { "UNIT_HEALTH:PLAYER_TARGET_CHANGED", function(params)
    return UnitHealth((params or "player")) or ""
  end },
  ["{maxhealth(.-)}"] = { "UNIT_HEALTH:PLAYER_TARGET_CHANGED", function(params)
    return UnitHealthMax((params or "player")) or ""
  end },
  ["{mana(.-)}"] = { "UNIT_MANA:PLAYER_TARGET_CHANGED", function(params)
    return UnitMana((params or "player")) or ""
  end },
  ["{maxmana(.-)}"] = { "UNIT_MANA:PLAYER_TARGET_CHANGED", function(params)
    return UnitManaMax((params or "player")) or ""
  end },
  ["{armor(.-)}"] = { "TIMER:PLAYER_TARGET_CHANGED", function(params)
    return UnitArmor((params or "player")) or ""
  end },
  ["{mindmg(.-)}"] = { "TIMER:PLAYER_TARGET_CHANGED", function(params)
    local mindmg, maxdmg = UnitDamage((params or "player"))
    return string.format("%.0f", mindmg) or 0
  end },
  ["{maxdmg(.-)}"] = { "TIMER:PLAYER_TARGET_CHANGED", function(params)
    local mindmg, maxdmg = UnitDamage((params or "player"))
    return string.format("%.0f", maxdmg) or 0
  end },
  ["{gold(.-)}"] = { "PLAYER_MONEY", function(params)
    return floor(GetMoney() / 100 / 100)
  end },
  ["{silver(.-)}"] = { "PLAYER_MONEY", function(params)
    return floor(mod((GetMoney() / 100), 100))
  end },
  ["{copper(.-)}"] = { "PLAYER_MONEY", function(params)
    return floor(mod(GetMoney(), 100))
  end },
  ["{realm(.-)}"] = { "PLAYER_ENTERING_WORLD", function(params)
    return GetRealmName()
  end },
  ["{fps(.-)}"] = { "TIMER", function(params)
    return ceil(GetFramerate())
  end },
  ["{ping(.-)}"] = { "TIMER", function(params)
    local _, _, ping = GetNetStats()
    return ping
  end },
  ["{up(.-)}"] = { "TIMER", function(params)
    local _, up, _ = GetNetStats()
    return round(up, 2)
  end },
  ["{down(.-)}"] = { "TIMER", function(params)
    local down, _, _ = GetNetStats()
    return round(down, 2)
  end },
  ["{mem(.-)}"] = { "TIMER", function(params)
    local memkb, gckb = gcinfo()
    local memmb = memkb and memkb > 0 and round((memkb or 0) / 1000, 2) or UNAVAILABLE
    return memmb
  end },
  ["{memkb(.-)}"] = { "TIMER", function(params)
    local memkb, gckb = gcinfo()
    return memkb
  end },
  ["{serverh(.-)}"] = { "TIMER", function(params)
    local h, _ = GetGameTime()
    return string.format("%.2d", h)
  end },
  ["{serverm(.-)}"] = { "TIMER", function(params)
    local _, m = GetGameTime()
    return string.format("%.2d", m)
  end },
  ["{itemcount(.-)}"] = { "BAG_UPDATE", function(params)
    local icount, ilink, item, match, _
    local count = 0
    for bag = 4, 0, -1 do
      for slot = 1, GetContainerNumSlots(bag) do
        _, icount = GetContainerItemInfo(bag, slot)
        if icount then
          ilink = GetContainerItemLink(bag, slot)
          _, _, item = strfind(ilink, "(%d+):")
          match = GetItemInfo(item)
          if match and match ~= "" and match == params then
            count = count + icount
          end
        end
      end
    end

    return count
  end },
  ["{zone(.-)}"] = { "ZONE_CHANGED", function(params)
    local zoneName = GetRealZoneText()
    return zoneName
  end },
  ["{subzone(.-)}"] = { "ZONE_CHANGED", function(params)
    local subzone = GetSubZoneText()
    return subzone
  end },
}

local exists, params, _
local ParseConfig = function(input)
  -- use cache where available
  if varcache[input] and varcache[input][2] then
    return varcache[input][2]
  end

  -- scan for known captures and replace
  for capture, data in pairs(captures) do
    exists, _, params = string.find(input, capture)

    if exists then -- capture found
      params = params and string.gsub(params, "^%s*(.-)%s*$", "%1")
      params = params and string.len(params) > 0 and params or nil

      -- cache received input and its events
      varcache[input] = varcache[input] or {}
      varcache[input][1] = data[1]
      varcache[input][2] = data[2](params)

      -- register new element and enable its events
      if not elements[capture] then
        elements[capture] = true
        for i, event in pairs(strsplit(":", data[1])) do
          if event and not events[event] then
            events[event] = true
            updater:RegisterEvent(event)
          end
        end
      end

      return varcache[input][2]
    end
  end

  -- return and skip unknown captures next round
  if varcache[input] then
    varcache[input][1] = "NEVER"
    varcache[input][2] = input
    return varcache[input][2]
  end
end

-- add to core
ShaguWidget.ParseConfig = ParseConfig
