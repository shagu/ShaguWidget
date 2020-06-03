local gfind = string.gmatch or string.gfind

local function round(input, places)
  if not places then places = 0 end
  if type(input) == "number" and type(places) == "number" then
    local pow = 1
    for i = 1, places do pow = pow * 10 end
    return floor(input * pow + 0.5) / pow
  end
end

local varcache = {}
local updater = CreateFrame("Frame", "ShaguWidgetUpdater", WorldFrame)
updater:SetScript("OnUpdate", function()
  -- invalidate all varcache each .2 seconds
  if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + .2 end
  for capture in pairs(varcache) do varcache[capture] = nil end
end)

local captures = {
  ["{color(.-)}"] = { "TIMER", function(params)
    return string.len(params) > 0 and "|cff" .. params or "|r"
  end },
  ["{date(.-)}"] = { "TIMER", function(params)
    return date((string.len(params) > 0 and params)) or ""
  end },
  ["{name(.-)}"] = { "TIMER", function(params)
    return UnitName((string.len(params) > 0 and params or "player")) or ""
  end },
  ["{level(.-)}"] = { "TIMER", function(params)
    return UnitLevel((string.len(params) > 0 and params or "player")) or ""
  end },
  ["{health(.-)}"] = { "TIMER", function(params)
    return UnitHealth((string.len(params) > 0 and params or "player")) or ""
  end },
  ["{maxhealth(.-)}"] = { "TIMER", function(params)
    return UnitHealthMax((string.len(params) > 0 and params or "player")) or ""
  end },
  ["{mana(.-)}"] = { "TIMER", function(params)
    return UnitMana((string.len(params) > 0 and params or "player")) or ""
  end },
  ["{maxmana(.-)}"] = { "TIMER", function(params)
    return UnitManaMax((string.len(params) > 0 and params or "player")) or ""
  end },
  ["{gold(.-)}"] = { "TIMER", function(params)
    return floor(GetMoney()/ 100 / 100)
  end },
  ["{silver(.-)}"] = { "TIMER", function(params)
    return floor(mod((GetMoney()/100),100))
  end },
  ["{copper(.-)}"] = { "TIMER", function(params)
    return floor(mod(GetMoney(),100))
  end },
  ["{realm(.-)}"] = { "TIMER", function(params)
    return GetRealmName()
  end },
  ["{fps(.-)}"] = { "TIMER", function(params)
    return ceil(GetFramerate())
  end },
  ["{ping(.-)}"] = { "TIMER", function(params)
    local _, _, ping = GetNetStats()
    return ping
  end },
  ["{up}"] = { "TIMER", function(params)
    local _, up, _ = GetNetStats()
    return round(up,2)
  end },
  ["{down}"] = { "TIMER", function(params)
    local down, _, _ = GetNetStats()
    return round(down,2)
  end },
  ["{mem}"] = { "TIMER", function(params)
    local memkb, gckb = gcinfo()
    local memmb = memkb and memkb > 0 and round((memkb or 0)/1000, 2) or UNAVAILABLE
    return memmb
  end },
  ["{memkb}"] = { "TIMER", function(params)
    local memkb, gckb = gcinfo()
    return memkb
  end },
  ["{serverh}"] = { "TIMER", function(params)
    local h, _ = GetGameTime()
    return string.format("%.2d", h)
  end },
  ["{serverm}"] = { "TIMER", function(params)
    local _, m = GetGameTime()
    return string.format("%.2d", m)
  end },
}

local exists, params, _
local ParseConfig = function(input)
  -- use cache where available
  if varcache[input] then return varcache[input] end

  -- scan for known captures and replace
  for capture, data in pairs(captures) do
    exists, _, params = string.find(input, capture)

    if exists then -- capture found
      params = params and string.gsub(params, "%s+", "") or ""
      varcache[input] = data[2](params)
      return varcache[input]
    end
  end

  -- return and skip unknown captures next round
  varcache[input] = input
  return varcache[input]
end

-- add to core
ShaguWidget.ParseConfig = ParseConfig
