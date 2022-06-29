module("i18n", package.seeall)
const = {
  ["LOG_\232\166\139\227\130\139"] = {
    "Uootoy\227\130\146\232\166\139\227\130\139",
    ":i18n:01_01:"
  },
  ["LOG_\231\164\186\227\129\153"] = {
    "Uootoy\227\130\146\231\164\186\227\129\153",
    ":i18n:01_02:"
  },
  ["LOG_\227\130\186\227\131\188\227\131\160"] = {
    "Uootoy\227\129\171\227\130\186\227\131\188\227\131\160",
    ":i18n:01_03:"
  },
  ["LOG_\239\188\184\231\183\154"] = {
    "Uootoy\227\129\171\239\188\184\231\183\154",
    ":i18n:01_04:"
  },
  ["LOG_\231\162\186\232\170\141"] = {
    "Uootoy\227\130\146\231\162\186\232\170\141",
    ":i18n:01_05:"
  }
}
local useSystemLanguage = false
function SetSystemLanugage(b)
  useSystemLanguage = b
  Game.RootResources.useSystemLanguage = b
end
function GetSystemLanugage()
  return useSystemLanguage
end
local function GetLanguage(label)
  if label and (label[3] == "system" or useSystemLanguage) then
    return RootResources.systemLanguage
  end
  return RootResources.textLanguage
end
function GetTextRaw(label, mes, LANG)
  if LANG == nil then
    LANG = RootResources.textLanguage
  end
  local mes = "?!#"
  local m, id = string.match(label, ":([^:]*):(.*):")
  if m and id then
    
    local mod = string.format("%s-%s", m, LANG)
    require(string.format("i18n/%s/%s-%s", LANG, m, LANG))
    if _G[mod] and _G[mod].text[id] then
      mes = _G[mod].text[id]
      mes = string.gsub(mes, "&quot;", "\"")
    else
      print(label)
    end
  else
    local mod = string.format("movie-%s", LANG)
    require(string.format("i18n/%s/movie-%s", LANG, LANG))
    if _G[mod] and _G[mod].text[label] then
      mes = _G[mod].text[label]
      mes = string.gsub(mes, "&quot;", "\"")
    else
      print("----", label)
    end
  end
  return mes
end
function GetText(mes, label, LANG)
  if LANG == nil then
    LANG = GetLanguage(mes)
  end
  if type(mes) == "table" and label == nil then
    if LANG == "jp" then
      return mes[1]
    end
    return GetText(mes[1], mes[2], LANG)
  end
  if (label == nil or LANG == "jp") and mes ~= nil then
    return mes
  end
  if mes == nil and label == nil then
    return nil
  end
  return GetTextRaw(label, nil, LANG)
end
function GetSpeaker(label)
  local LANG = GetLanguage(label)
  local m, id = string.match(label, ":([^:]*):(.*):")
  mod = string.format("movie-%s", LANG)
  require(string.format("i18n/%s/movie-%s", LANG, LANG))
  if _G[mod] and _G[mod].text[label] then
    mes = _G[mod].speaker[label]
  else
    print("----", label)
  end
  return mes
end
function GetLabel(label)
  if type(label) == "string" then
    return label
  end
  if type(label) == "table" then
    return label[2]
  end
  printerror("label error")
end
function SetFont(text, kind)
  local language = RootResources.textLanguage
  if kind == "somnium" then
    text.text.font = root.RootResources[language].somnium
  elseif kind == "narration" then
    text.text.font = root.RootResources[language].narration
  elseif kind == "ui" then
    text.text.font = root.RootResources[language].ui
  elseif kind == "tutorial" then
    text.text.font = root.RootResources[language].tutorial
  else
    text.text.font = root.RootResources[language].investigation
  end
end
