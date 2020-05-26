local gfind = string.gmatch or string.gfind

local function round(input, places)
  if not places then places = 0 end
  if type(input) == "number" and type(places) == "number" then
    local pow = 1
    for i = 1, places do pow = pow * 10 end
    return floor(input * pow + 0.5) / pow
  end
end

local ParseConfig = function(input)
  if string.find(input, "{date") then
    local _, _, format = string.find(input, "{date (.-)}")
    if format then
      return date(format)
    else
      return date()
    end
  elseif string.find(input, "{name") then
    local _, _, format = string.find(input, "{name (.-)}")
    if format then
      return UnitName(format) or ""
    else
      return UnitName("player") or ""
    end
  elseif string.find(input, "{level") then
    local _, _, format = string.find(input, "{level (.-)}")
    if format then
      return UnitLevel(format) or ""
    else
      return UnitLevel("player") or ""
    end
  elseif string.find(input, "{health") then
    local _, _, format = string.find(input, "{health (.-)}")
    if format then
      return UnitHealth(format) or ""
    else
      return UnitHealth("player") or ""
    end
  elseif string.find(input, "{maxhealth") then
    local _, _, format = string.find(input, "{maxhealth (.-)}")
    if format then
      return UnitHealthMax(format) or ""
    else
      return UnitHealthMax("player") or ""
    end
  elseif string.find(input, "{mana") then
    local _, _, format = string.find(input, "{mana (.-)}")
    if format then
      return UnitMana(format) or ""
    else
      return UnitMana("player") or ""
    end
  elseif string.find(input, "{maxmana") then
    local _, _, format = string.find(input, "{maxmana (.-)}")
    if format then
      return UnitManaMax(format) or ""
    else
      return UnitManaMax("player") or ""
    end
  elseif string.find(input, "{gold}") then
    return floor(GetMoney()/ 100 / 100)
  elseif string.find(input, "{silver}") then
    return floor(mod((GetMoney()/100),100))
  elseif string.find(input, "{copper}") then
    return floor(mod(GetMoney(),100))
  elseif string.find(input, "{fps}") then
    return ceil(GetFramerate())
  elseif string.find(input, "{ping}") then
    local _, _, ping = GetNetStats()
    return ping
  elseif string.find(input, "{up}") then
    local _, up, _ = GetNetStats()
    return round(up,2)
  elseif string.find(input, "{down}") then
    local down, _, _ = GetNetStats()
    return round(down,2)
  elseif string.find(input, "{mem}") then
    local memkb, gckb = gcinfo()
    local memmb = memkb and memkb > 0 and round((memkb or 0)/1000, 2) .. " MB" or UNAVAILABLE
    return memmb
  elseif string.find(input, "{memkb}") then
    local memkb, gckb = gcinfo()
    return memkb
  elseif string.find(input, "{serverh}") then
    local h, _ = GetGameTime()
    return h
  elseif string.find(input, "{serverm}") then
    local _, m = GetGameTime()
    return m
  elseif string.find(input, "{color") then
    local _, _, color = string.find(input, "{color (.-)}")
    if color then
      return "|cff" .. color
    else
      return "|r"
    end
  else
    return input
  end
end

-- add to core
ShaguWidget.ParseConfig = ParseConfig
