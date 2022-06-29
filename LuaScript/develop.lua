module("develop", package.seeall)-- translation copied by timo654
if BUILD_RELEASE ~= 1 then
  initialized = false
  local task = CreateTask()
  local first = true
  local update_flag = true
  local currentLuaFile, currentLine
  local outputdir = Application.dataPath .. "/../outputs"
  local AddShortcut = function(kind, file, func)
    for _, v in ipairs(savedata.data_debug.Shortcuts) do
      if v.kind == kind and v.file == file and v.func == func then
        return
      end
    end
    table.insert(savedata.data_debug.Shortcuts, 1, {
      kind = kind,
      file = file,
      func = func
    })
    savedata.data_debug.Shortcuts[8] = nil
    savedata.save()
  end
  local LoadLuaFile = function(name)
    local funcs = {}
    table.insert(funcs, "        START")
    local fn = GetLuaFileName(name)
    require(fn)
    local r, mes = pcall(function()
    end)
    if r == false then
      print(mes)
      return nil
    end
    local tags = {}
    local tag = "_"
    local incs = {}
    for line in Slua.iter(ScriptManager.instance:GetLuaFile(fn)) do
      local match = Regex.Match(line, "include[(]\\s*'(.*)'\\s*[)]")
      if match.Success then
        table.insert(incs, match.Groups:getItem(1).Value)
      end
      local func, tail = string.match(line, "function[ \t]+(.+)[(][)][ \t]*(.*)")
      local num
      if func then
        if tail then
          local tag_
          tag_, num = string.match(tail, "[[]([^0-9]+)([0-9]*)[]]")
          if tag_ then
            tag = tag_
          end
        end
        if tag == nil then
          tag = cur
        end
        if tags[tag] == nil then
          tags[tag] = 0
        end
        if num ~= nil and num ~= "" then
          num = tonumber(num)
          tags[tag] = num
        else
          num = tags[tag] + 1
          tags[tag] = num
        end
        table.insert(funcs, string.format("<color=orange>[%s:%03d]</color> %s", tag, num, func))
      end
    end
    table.sort(funcs)
    return funcs, incs
  end
  local function CreateTopMenu()
    local topmenu = {}
    local win_level = 0
    local submits = {}
    local windows = {}
    local background = FindObjectInScene(CurrentScene, "DebugImage")
    local stickSubmit = false
    local stickCancel = false
    function background.trigger.onPointerClick()
      win_level = 1
      for i = #windows, 2, -1 do
        windows[i]:Destroy()
        windows[i] = nil
      end
      windows[1]:SetFocus(true)
    end
    local function Serialize()
      local t = {}
      for i = 1, win_level - 1 do
        table.insert(t, submits[i])
      end
      savedata.data_debug.topmenu.submits = t
      savedata.save()
    end
    local function Deserialize()
      local t = savedata.data_debug.topmenu.submits
      for i, v in ipairs(t) do
        if windows[i] then
        end
      end
    end
    local rootGo = FindObjectInScene(CurrentScene, "TopWindows")
    FocusGameObject(rootGo.gameObject)
    local wins = {}
    for i = 0, rootGo.transform.childCount - 1 do
      local child = rootGo.transform:GetChild(i)
      child.gameObject:SetActive(false)
      table.insert(wins, child)
    end
    local function CreateWindow(name, menu)
      local obj
      if wins[1] then
        obj = SetObject(wins[1].gameObject, true)
        obj.gameObject:SetActive(true)
        obj.transform:SetAsLastSibling()
        table.remove(wins, 1)
      else
        obj = Instantiate(PrefabWin.gameObject, rootGo, true)
      end
      local content = obj.Mask.Viewport.Content
      local viewport = obj.Mask.Viewport
      local mask = obj.Mask
      obj.vars.focus = false
      obj.Title.Text.text.text = name
      local y = 0
      local no = 1
      local sel
      local current = 1
      local click = false
      local enter = false
      local drag = Time.realtimeSinceStartup
      local ty = 0
      local cy = 0
      local height
      function obj:Destroy()
        table.insert(wins, obj.transform)
        obj.gameObject:SetActive(false)
      end
      function obj:OnScroll(data)
        local scroll_dy = data.scrollDelta.y
        if scroll_dy ~= nil then
          local dy = -scroll_dy * height
          local yy = mask.scrollRect.content.anchoredPosition.y + dy
          yy = math.max(yy, 0)
          yy = math.min(yy, math.max(content.transform.rect.height - viewport.transform.rect.height, 0))
          mask.scrollRect.content.anchoredPosition = Vector2(0, yy)
        end
        local mousePosition = ES.vars.inputModule:GetMousePosition()
        local pointerEventData = EventSystems.PointerEventData()
        pointerEventData.position = mousePosition
        local result = ListRaycastResult()
        Canvas.graphicRaycaster:Raycast(pointerEventData, result)
        for v in Slua.iter(result) do
          local comp = v.gameObject:GetComponent(LuaEventTrigger)
          if comp and comp.onPointerEnter then
            comp.onPointerEnter()
          end
        end
      end
      function mask.trigger.onScroll(data)
        obj:OnScroll(data)
      end
      function mask.trigger.onPointerDown()
        if obj.vars.focus ~= true then
          for i, v in pairs(windows) do
            if v.level ~= nil and v.level > obj.vars.level then
              v:Destroy()
              windows[i] = nil
            end
          end
          obj:SetFocus(true)
          win_level = obj.vars.level
          sel = nil
        end
      end
      local buttons = {}
      obj.SetFocus_ = obj.SetFocus
      function obj:SetFocus(b)
        obj.vars.focus = b
        if b then
          SetAnimationTrigger(obj, "Highlighted")
        else
          SetAnimationTrigger(obj, "Normal")
        end
        if b then
        end
        sel = nil
      end
      local items = {}
      function obj:Open(folder_name)
        submits[win_level] = foldre_name
        if items[folder_name] then
          sel = items[folder_name].no
          current = sel
          cy = current * height
          ty = cy
          items[folder_name].func()
        end
      end
      local children = {}
      for i = 0, content.transform.childCount - 1 do
        local child = content.transform:GetChild(i)
        if child.name ~= "Image" then
          child.gameObject:SetActive(false)
          table.insert(children, child)
        end
      end
      function obj:Add(res)
        local item
        if children[1] then
          item = SetObject(children[1].gameObject)
          item.gameObject:SetActive(true)
          table.remove(children, 1)
        else
          item = Instantiate(PrefabStartItem.gameObject, content)
        end
        item.Text = FindObject(item, "Text")
        local str = i18n.GetText(res.name)
        if res.format then
          str = res.format(str)
        end
        item.Text.text.text = str
        item.transform.anchoredPosition = Vector2(0, -y)
        item.Text.text.color = _q_(res.func ~= nil, Color(1, 1, 1), Color(0.5, 0.5, 0.5))
        y = y + item.transform.rect.height + 2
        height = item.transform.rect.height + 2
        content.transform.sizeDelta = Vector2(0, y)
        item.vars.no = no
        items[i18n.GetLabel(res.name)] = {
          func = res.func,
          no = no
        }
        function item.trigger.onPointerClick()
          if Time.realtimeSinceStartup - drag > 0.1 then
            current = item.vars.no
            click = true
          end
        end
        function item.trigger.onBeginDrag(data)
          obj.Mask.scrollRect:OnBeginDrag(data)
        end
        function item.trigger.onDrag(data)
          drag = Time.realtimeSinceStartup
          obj.Mask.scrollRect:OnDrag(data)
        end
        function item.trigger.onEndDrag(data)
          drag = Time.realtimeSinceStartup
          obj.Mask.scrollRect:OnEndDrag(data)
        end
        function item.trigger.onScroll(data)
          obj:OnScroll(data)
        end
        function item.trigger.onPointerEnter(data)
          if Time.realtimeSinceStartup - drag > 0.1 then
            current = item.vars.no
            enter = true
            if obj.vars.focus == true then
            end
          end
        end
        function item.trigger.onPointerExit(data)
          enter = false
        end
        function item.OnSubmit()
          if res ~= nil then
            submits[win_level] = i18n.GetLabel(res.name)
            SE:Play("SE/SE_SYS_CLICK")
            sel = item.vars.no
            if res.func then
              res.func()
            end
            Serialize()
          end
        end
        function item.OnCancel()
          if win_level ~= 1 then
            win_level = win_level - 1
            for i, v in pairs(windows) do
              if v.vars.level > win_level then
                v:Destroy()
                windows[i] = nil
                break
              end
            end
            for _, v in ipairs(windows) do
              if v.vars.level == win_level then
                v:SetFocus(true)
              end
            end
            Serialize()
            sel = nil
          end
        end
        no = no + 1
        table.insert(buttons, item)
        return item
      end
      function obj:SetText(i, text)
        local item = buttons[i]
        item.Text.text.color = Color(1, 1, 1)
        item.Text.text.text = text
      end
      for _, v in ipairs(menu) do
        obj:Add(v)
      end
      for _, v in ipairs(windows) do
        v:SetFocus(false)
      end
      obj.transform.anchoredPosition = Vector2(280 * win_level + 50, -40 * win_level - 50)
      windows[win_level + 1] = obj
      obj:SetFocus(true)
      win_level = win_level + 1
      obj.vars.level = win_level
      local repeatInput = CreateRepeatKey(AXIS_DPAD_VERTICAL)
      function obj:Proc()
        local sel = buttons[current]
        if enter == false and obj.vars.focus == true then
          if obj.proc then
            obj.proc()
          end
          local dy = repeatInput:Update()
          if dy ~= 0 then
            local old = current
            if current == nil then
              current = 1
            elseif dy < 0 then
              current = math.min(current + 1, no - 1)
            else
              current = math.max(current - 1, 1)
            end
            if old ~= current then
            end
          end
          if stickSubmit then
            click = true
            stickSubmit = false
          end
          if stickCancel then
            sel.OnCancel()
            stickCancel = false
          end
        end
        if click == true then
          for i, v in pairs(windows) do
            if v.vars.level > obj.vars.level then
              v:Destroy()
              windows[i] = nil
            end
          end
          obj:SetFocus(true)
          win_level = obj.vars.level
          sel.OnSubmit()
        end
        click = false
        ty = -sel.transform.anchoredPosition.y
        cy = cy + (ty - cy) * math.min(Time.deltaTime * 30, 1)
        content.Image.transform.anchoredPosition = Vector2(0, -cy)
        if cy + height > viewport.transform.rect.height + content.transform.anchoredPosition.y then
          content.transform.anchoredPosition = Vector2(0, cy + height - viewport.transform.rect.height)
        end
        if cy < content.transform.anchoredPosition.y then
          content.transform.anchoredPosition = Vector2(0, cy)
        end
      end
      return obj
    end
    local function Func(name)
      local FlowchartSavedataUtil = optionmenu_util.CreateFlowchartSavedataUtil()
      FlowchartSavedataUtil:Open(RootResources.startScript)
      FlowchartSavedataUtil:Play(RootResources.startScript)
      name = string.match(name, ".* (.*)")
      Utility.sceneFunc = name
      ShowDebugMenu(false)
      root.Fade:Black()
      AddShortcut("investigation", RootResources.startScript, Utility.sceneFunc)
      root.ModeActivate("Investigation")
    end
    local function Script(name)
      RootResources.startScript = name
      Utility.sceneFunc = ""
      local funcs = LoadLuaFile(name)
      if funcs then
        local menu = {}
        for _, w in ipairs(funcs) do
          if not string.find(w, "_movie_") and not string.find(w, "Enter") and not string.find(w, "Update") and not string.find(w, "FlagCheck") then
            local item = {}
            item.name = w
            function item.func()
              Func(w)
            end
            table.insert(menu, item)
          end
        end
        local title = name
        local a, b, c = string.match(name, "(.+)-([^_-]+)_([^_-]+)")
        if a and b and c then
          title = a .. "-" .. b .. "_" .. c
        end
        CreateWindow(title, menu)
      end
    end
    local function Investigation(dir)
      local files = {}
      do
        local function Add(dirName)
          for _, fi in ipairs(GetFiles(string.format("%s/%s", LUA_TEXT_BASE_DIR, dirName))) do
            name = string.match(fi, "(.+)[.]lua")
            if name == nil then
              name = fi
            end
            table.insert(files, name)
          end
        end
        if dir == "test" then
          Add("test/")
        else
          Add("investigation/" .. dir)
        end
      end
      local menu = {}
      for _, f in ipairs(files) do
        if not string.find(f, "Hanyou") and not string.find(f, "Clue") then
          local item = {}
          item.name = f
          function item.func()
            Script(f)
          end
          table.insert(menu, item)
        end
      end
      CreateWindow({
        "Investigation",
        ":develop:01_02:"
      }, menu)
    end
    local function InvestigationFolder()
      local files = {}
      do
        local function Add(name)
          for _, n in ipairs(GetDirectories(LUA_TEXT_BASE_DIR .. "/" .. name)) do
            table.insert(files, n)
          end
        end
        table.insert(files, "test")
        Add("investigation")
      end
      local menu = {}
      for _, f in ipairs(files) do
        local item = {}
        item.name = f
        function item.func()
          Investigation(f)
        end
        table.insert(menu, item)
      end
      CreateWindow({
        "Investigation Folder",
        ":develop:01_03:"
      }, menu)
    end
    local function TextLanguage()
      local Select = function(language)
        SAVEDATA.language.Text = language
        RootResources.textLanguage = language
        print(language)
        savedata.save()
        root.Reset()
      end
      local menu = {
        {
          name = {
            "Japanese",
            ":develop:01_04:"
          },
          func = function()
            Select("jp")
          end
        },
        {
          name = {
            "English",
            ":develop:01_05:"
          },
          func = function()
            Select("us")
          end
        },
        {
          name = {
            "Traditional Chinese",
            ":develop:01_07:"
          },
          func = function()
            Select("zh_tw")
          end
        }
      }
      CreateWindow({
        "Language",
        ":develop:01_08:"
      }, menu)
    end
    local function VoiceLanguage()
      local Select = function(language)
        print(language)
        savedata.system_data.options.language = language == "jp"
        _G.SystemSave.Start()
        root.Reset()
      end
      local menu = {
        {
          name = {
            "Japanese",
            ":develop:01_09:"
          },
          func = function()
            Select("jp")
          end
        },
        {
          name = {
            "English",
            ":develop:01_10:"
          },
          func = function()
            Select("us")
          end
        }
      }
      CreateWindow({
        "Language",
        ":develop:01_11:"
      }, menu)
    end
    local function SystemLanguage()
      local Select = function(language)
        RootResources.systemLanguage = language
        root.Reset()
      end
      local menu = {
        {
          name = {
            "Japanese",
            ":develop:01_04:"
          },
          func = function()
            Select("jp")
          end
        },
        {
          name = {
            "English",
            ":develop:01_05:"
          },
          func = function()
            Select("us")
          end
        },
        {
          name = {
            "Traditional Chinese",
            ":develop:01_07:"
          },
          func = function()
            Select("zh_tw")
          end
        }
      }
      CreateWindow({
        "Language",
        ":develop:01_08:"
      }, menu)
    end
    local function PseudoPlatform()
      local Select = function(platform)
        RootResources.platform = platform
        SAVEDATA.platform = platform
        savedata.save()
        root.Reset()
      end
      local menu = {
        {
          name = {
            "Steam",
            ":develop:01_12:"
          },
          func = function()
            Select(Platform._Steam)
          end
        },
        {
          name = {
            "PS4",
            ":develop:01_13:"
          },
          func = function()
            Select(Platform._PS4)
          end
        },
        {
          name = {
            "XBOX",
            ":develop:01_14:"
          },
          func = function()
            Select(Platform._XBOX)
          end
        },
        {
          name = {
            "SWITCH",
            ":develop:01_15:"
          },
          func = function()
            Select(Platform._SWITCH)
          end
        }
      }
      CreateWindow({
        "Language",
        ":develop:01_16:"
      }, menu)
    end
    local FormatPlatfomr = function(str)
      local pn = ""
      if RootResources.platform == Platform._Steam then
        pn = "Steam"
      end
      if RootResources.platform == Platform._PS4 then
        pn = "PS4"
      end
      if RootResources.platform == Platform._XBOX then
        pn = "XBOX"
      end
      if RootResources.platform == Platform._SWITCH then
        pn = "SWITCH"
      end
      str = str .. string.format(" [%s]", pn)
      return str
    end
    local function UI()
      local CityMap = function()
        root.Fade:Black()
        ShowDebugMenu(false)
        RootResources.startScript = "script_sample"
        Utility.sceneFunc = "test_Map"
        root.ModeActivate("Investigation")
      end
      local Goto = function(scene)
        ShowDebugMenu(false)
        root.ModeActivate(scene)
        GLOBAL.currentScene = scene
      end
      local menu = {
        {
          name = {
            "City Map",
            ":develop:01_17:"
          },
          func = function()
            CityMap()
          end
        },
        {
          name = {
            "File",
            ":develop:01_18:"
          },
          func = function()
            Goto("file")
          end
        },
        {
          name = {
            "Relationship Diagram",
            ":develop:01_19:"
          },
          func = function()
            Goto("diagram")
          end
        },
        {
          name = {
            "Options",
            ":develop:01_20:"
          },
          func = function()
            Goto("options")
          end
        },
        {
          name = {
            "Save",
            ":develop:01_21:"
          },
          func = function()
            Goto("save")
          end
        },
        {
          name = {
            "Flowchart",
            ":develop:01_22:"
          },
          func = function()
            Goto("flowchart")
          end
        }
      }
      CreateWindow({
        "Language",
        ":develop:01_23:"
      }, menu)
    end
    local Start = function()
      local proc = function()
        RootResources.startScript = nil
        Utility.sceneFunc = nil
        ShowDebugMenu(false)
        root.Fade.Black()
        if DEVELOP_MODE then
          root.ModeActivate("Title", true)
        else
          root.ModeActivate("Logo")
        end
      end
      proc()
    end
    local function Somnium(fileName)
      RootResources.startScript = fileName
      local FlowchartSavedataUtil = optionmenu_util.CreateFlowchartSavedataUtil()
      FlowchartSavedataUtil:Open(RootResources.startScript)
      FlowchartSavedataUtil:Play(RootResources.startScript)
      root.Fade:Black()
      ShowDebugMenu(false)
      AddShortcut("somnium", fileName, "")
      Game.Profile.Begin("Somnium")
      root.ModeActivate("Somnium")
    end
    local function SomniumList()
      local menu = {}
      for _, fi in ipairs(GetFiles(string.format("%s/somnium", LUA_TEXT_BASE_DIR))) do
        local name = string.match(fi, "(.+)[.]lua")
        if name == nil then
          name = fi
        end
        local item = {}
        item.name = name
        function item.func()
          Somnium(name)
        end
        table.insert(menu, item)
      end
      CreateWindow({
        "Somnium",
        ":develop:01_24:"
      }, menu)
    end
    local StaffRoll = function()
      root.Fade:Black()
      ShowDebugMenu(false)
      root.ModeActivate("staffroll")
    end
    function Pause()
    end
    local Aging = function()
      root.Fade:Black()
      ShowDebugMenu(false)
      DEBUG:SetAgingMode(true)
      RootResources.startScript = "A1-begin10_10_Bloom-Pk_Boss"
      root.ModeActivate("Investigation")
    end
    local BGViewer = function()
      GLOBAL.viewer4Record = false
      SetBGViewer()
      root.Fade:Black()
      ShowDebugMenu(false)
      RootResources.startScript = "Z0-BGViewer"
      Utility.sceneFunc = nil
      root.ModeActivate("Investigation")
    end
    local BGRecordViewer = function()
      SetBGViewer()
      root.Fade:Black()
      ShowDebugMenu(false)
      RootResources.startScript = "Z0-BGViewer4Record"
      Utility.sceneFunc = nil
      root.ModeActivate("Investigation")
    end
    local Recorder = function()
      GLOBAL.viewer4Record = false
      SetBGViewer()
      root.Fade:Black()
      ShowDebugMenu(false)
      RootResources.startScript = "Z0-recorder"
      Utility.sceneFunc = nil
      root.ModeActivate("Investigation")
    end
    local Dance = function()
      root.Fade:Black()
      ShowDebugMenu(false)
      root.ModeActivate("Dance")
    end
    local function Milestone()
      local Goto = function(name)
        FLAG["\239\188\145\230\156\136\230\156\171\227\131\158\227\130\164\227\131\171\227\130\185\227\131\136\227\131\179\231\162\186\232\170\141\233\160\133\231\155\174"] = true
        if name == nil then
          RootResources.startScript = "A2_01"
          root.Fade:Black()
          ShowDebugMenu(false)
          root.ModeActivate("Somnium")
        else
          RootResources.startScript = name
          Utility.sceneFunc = nil
          ShowDebugMenu(false)
          root.Fade:Black()
          root.ModeActivate("Investigation")
        end
      end
      local menu = {
        {
          name = {
            "Somnium",
            ":develop:01_25:"
          },
          func = function()
            Goto()
          end
        },
        {
          name = {
            "Begin Scenario",
            ":develop:01_29:"
          },
          func = function()
            Goto("A0-open_10_10_Bloom-Pk_OpeningMovie")
          end
        }
      }
      CreateWindow({
        "Language",
        ":develop:01_30:"
      }, menu)
    end
    local function Joypad()
      local axis = {
        "xAxis",
        "yAxis",
        "3rdAxis",
        "4thAxis",
        "5thAxis",
        "6thAxis",
        "7thAxis",
        "8thAxis"
      }
      local menu = {}
      for _, v in ipairs(axis) do
        table.insert(menu, {name = v})
      end
      for i = 0, 11 do
        table.insert(menu, {name = "??"})
      end
      local win = CreateWindow({
        "Joypad",
        ":develop:01_31:"
      }, menu)
      function win.proc()
        for i, v in ipairs(axis) do
          win:SetText(i, string.format("%s %f", v, Input_.GetAxisRaw(v)))
        end
        for i = 0, 11 do
          local code = KeyCode[string.format("JoystickButton%d", i)]
          local b = Input_.GetKey(code)
          win:SetText(i + 9, string.format("button%d %d", i, _q_(b, 1, 0)))
        end
      end
    end
    local ClearSkipFlag = function()
      SAVEDATA.Investigation.SkipFlag = {}
      savedata.save()
    end
    function ExtractFlag()
      local flags = {}
      local function Check(name)
        local fn = GetLuaFileName(name)
        local f = io.open(string.format("%s/%s.lua", LUA_TEXT_BASE_DIR, fn), "rt")
        local no = 0
        for l in f:lines() do
          l = string.gsub(l, "[-][-].*$", "")
          l = string.gsub(l, "[ \t]", "")
          if l ~= "" then
            for f in string.gmatch(l, "FLAG[.][^ =~]+") do
              if flags[f] == nil then
                flags[f] = {}
              end
              flags[f][fn] = true
            end
          end
        end
        f:close()
      end
      local function CheckDir(dirName)
        if dirName ~= "test" then
          for _, f in ipairs(GetFiles(string.format("%s/Investigation/%s", LUA_TEXT_BASE_DIR, dirName))) do
            if string.match(f, "^[A-Z]") then
              Check(f)
            end
          end
        end
      end
      for _, dirName in ipairs(GetDirectories(LUA_TEXT_BASE_DIR .. "/Investigation")) do
        CheckDir(dirName)
      end
      for _, f in ipairs(GetFiles(string.format("%s/Somnium", LUA_TEXT_BASE_DIR, dirName))) do
        if string.match(f, "^[A-Z]") then
          Check(f)
        end
      end
      fo = io.open(Application.dataPath .. "../../../Temp/flag.txt", "wt")
      for f, t in pairs(flags) do
        count = 0
        for i, v in pairs(t) do
          count = count + 1
        end
        if count > 1 then
          fo:write(f .. "\n")
          for i, v in pairs(t) do
            fo:write("\t" .. i .. ".lua\n")
          end
        end
      end
      fo:close()
    end
    local padview_task
    local function PadView()
      local PadView = FindObjectInScene(CurrentScene, "PadView")
      if padview_task ~= nil then
        padview_task:Stop()
      end
      padview_task = nil
      if not PadView.gameObject.activeSelf then
        PadView.gameObject:SetActive(true)
      else
        PadView.gameObject:SetActive(false)
        return
      end
      local Text = FindObject(PadView, "Text")
      local function proc()
        local makeColoredStr = function(src_str, color_str)
          return "<color=#" .. color_str .. ">" .. src_str .. "</color>"
        end
        local buttons = {
          "L1",
          "R1",
          "L2",
          "R2",
          "X",
          "Y",
          "LTRT",
          "Skip",
          "Submit",
          "BUTTON_SUBMIT_L2",
          "Cancel",
          "OPTIONS",
          "Button11",
          "BUTTON_LOG",
          "BUTTON_MAP",
          "BUTTON_AUTO",
          "BUTTON_RETRY",
          "BUTTON_DPAD_UP",
          "BUTTON_DPAD_DOWN",
          "BUTTON_DPAD_LEFT",
          "BUTTON_DPAD_RIGHT",
          "BUTTON_LSTICK_UP",
          "BUTTON_LSTICK_DOWN",
          "BUTTON_LSTICK_LEFT",
          "BUTTON_LSTICK_RIGHT",
          "BUTTON_RSTICK_UP",
          "BUTTON_RSTICK_DOWN",
          "BUTTON_RSTICK_LEFT",
          "BUTTON_RSTICK_RIGHT",
          "BUTTON_FAST",
          "BUTTON_CUT",
          "BUTTON_LSTICK",
          "BUTTON_RSTICK",
          "BUTTON_WASD_STICK_DPAD_LEFT",
          "BUTTON_WASD_STICK_DPAD_RIGHT",
          "BUTTON_WASD_STICK_DPAD_UP",
          "BUTTON_WASD_STICK_DPAD_DOWN",
          "BUTTON_WASD_DPAD_LEFT",
          "BUTTON_WASD_DPAD_RIGHT",
          "BUTTON_WASD_DPAD_UP",
          "BUTTON_WASD_DPAD_DOWN",
          "BUTTON_ARROW_STICK_LEFT",
          "BUTTON_ARROW_STICK_RIGHT",
          "BUTTON_ARROW_STICK_UP",
          "BUTTON_ARROW_STICK_DOWN"
        }
        local makeButtonString = function(button_name)
          local button = Input.GetButton(button_name)
          local buttonDown = Input.GetButtonDown(button_name)
          local buttonLongPress = Input.GetButtonLongPress(button_name)
          colors = {}
          colors[true] = "<color=#ff0000>%s</color>"
          colors[false] = "<color=#ffffff>%s</color>"
          local button_str = string.format(colors[button], "B:" .. tostring(button))
          local buttonDown_str = string.format(colors[buttonDown], "B:" .. tostring(buttonDown))
          local buttonLongPress_str = string.format(colors[buttonLongPress], "B:" .. tostring(buttonLongPress))
          local s = string.format("%-32s %s %s %s\n", button_name, button_str, buttonDown_str, buttonLongPress_str)
          return s
        end
        local function makeButtonStrings()
          local total = ""
          for i, button in pairs(buttons) do
            local s = makeButtonString(button)
            total = total .. s
          end
          return total
        end
        local axises = {
          "Horizontal",
          "Vertical",
          "Mouse Wheel",
          "3rdAxis",
          "AXIS_HORIZONTAL",
          "AXIS_VERTICAL",
          "AXIS_MOUSE_WHEEL",
          "AXIS_HORIZONTAL3",
          "AXIS_DPAD_HORIZONTAL",
          "AXIS_DPAD_VERTICAL",
          "AXIS_LSTICK_HORIZONTAL",
          "AXIS_LSTICK_VERTICAL",
          "AXIS_RSTICK_HORIZONTAL",
          "AXIS_RSTICK_VERTICAL",
          "AXIS_DPAD_LSTICK_HORIZONTAL",
          "AXIS_DPAD_LSTICK_VERTICAL"
        }
        local makeAxisString = function(name)
          local axis = Input.GetAxis(name)
          colors = {}
          colors[true] = "%-32s <color=#ff0000>AXIS:%f</color>\n"
          colors[false] = "%-32s <color=#ffffff>AXIS:%f</color>\n"
          local s = string.format(colors[axis ~= 0], name, axis)
          return s
        end
        local function makeAxisStrings()
          local total = ""
          for i, axis in pairs(axises) do
            local s = makeAxisString(axis)
            total = total .. s
          end
          return total
        end
        local lastPosition = Vector2(0, 0)
        local function makePointerStrings()
          colors = {}
          colors[true] = "%-16s <color=#ff0000>%f</color>"
          colors[false] = "%-16s <color=#ffffff>%f</color>"
          local total = ""
          local mousePosition = ES.vars.inputModule:GetMousePosition()
          local sx = string.format(colors[mousePosition.x ~= lastPosition.x], "MOUSE X", mousePosition.x)
          local sy = string.format(colors[mousePosition.y ~= lastPosition.y], "MOUSE Y", mousePosition.y)
          lastPosition = mousePosition
          total = total .. sx .. "  " .. sy
          return total
        end
        while true do
          local s = makeButtonStrings()
          s = s .. "\n"
          s = s .. makeAxisStrings()
          s = s .. "\n"
          s = s .. makePointerStrings()
          Text.text.text = s
          coroutine.yield()
        end
        print("PadView:dowork\tEND")
      end
      padview_task = task.Create(proc)
    end
    local function FlowchartDebug()
      local list = {}
      local function Add(find)
        for key, id in pairs(flowchart_ID.ID) do
          if find == nil or string.find(id.name, find) ~= nil then
            data = {key = key, id = id}
            table.insert(list, data)
          end
        end
      end
      Add(nil)
      local all_enable = {key = "all_enable"}
      local all_enable_full = {
        key = "all_enable_full"
      }
      local all_disable = {
        key = "all_disable"
      }
      table.insert(list, all_enable)
      table.insert(list, all_enable_full)
      table.insert(list, all_disable)
      local lock_begin = {key = "lock_begin"}
      local lock_now = {key = "lock_now"}
      local lock_end = {key = "lock_end"}
      table.insert(list, lock_begin)
      table.insert(list, lock_now)
      table.insert(list, lock_end)
      local pri = {
        all_enable = 1,
        all_enable_full = 2,
        all_disable = 3,
        lock_begin = 4,
        lock_now = 5,
        lock_end = 6
      }
      local function sorting(a, b)
        local pri_A = pri[a.key]
        local pri_B = pri[b.key]
        if pri_A ~= nil and pri_B ~= nil then
          return pri_A < pri_B
        elseif pri_A ~= nil then
          return true
        elseif pri_B ~= nil then
          return false
        end
        return a.key < b.key
      end
      table.sort(list, sorting)
      local colors = {}
      colors.disable = "<color=#888888>%s</color>"
      colors.unreach = "<color=#44FF44>%s</color>"
      colors.enable = "<color=#ffff88>%s</color>"
      colors.enable_full = "<color=#ffffff>%s</color>"
      colors.all_disable = "<color=#ff4444>%s</color>"
      colors.all_enable = "<color=#ffff88>%s</color>"
      colors.all_enable_full = "<color=#88ffff>%s</color>"
      colors.lock_begin = "<color=#FF88FF>%s</color>"
      colors.lock_now = colors.lock_begin
      colors.lock_end = colors.lock_begin
      local ChangeStatus = function(saveblock, scene_param, status, flag, termination)
        saveblock.status = status
        for index, param in ipairs(scene_param) do
          local process = saveblock.process[index]
          if param.group ~= nil and param.group == "termination" then
            process.played = termination
            process.cleared = termination
          else
            process.played = flag
            process.cleared = flag
          end
        end
        if status == FLOWCHART_STATUS.ENABLE then
          local process = saveblock.process[1]
          process.played = true
        end
        if saveblock.lockedanim then
          saveblock.lockedanim[1] = false
          saveblock.lockedanim[2] = false
        end
      end
      local function ChangeStatusAll(status, flag, termination)
        for key, data in ipairs(list) do
          local id = flowchart_ID.ID[data.key]
          if id ~= nil then
            local scene_param = id.scene_param
            local saveblock = _G.SAVEDATA.flowchart[data.key]
            if saveblock ~= nil then
              ChangeStatus(saveblock, scene_param, status, flag, termination)
            end
          end
        end
      end
      local function Return()
        background.trigger.onPointerClick()
      end
      local menu = {}
      for key, data in ipairs(list) do
        local item = {}
        if data.key == "all_disable" then
          item.name = string.format(colors[data.key], data.key)
          function item.func()
            ChangeStatusAll(FLOWCHART_STATUS.DISABLE, false, false)
            _G.SAVEDATA.flowchart.flowchart00.status = FLOWCHART_STATUS.ENABLE
            Return()
          end
        elseif data.key == "all_enable" then
          item.name = string.format(colors[data.key], data.key)
          function item.func()
            ChangeStatusAll(FLOWCHART_STATUS.ENABLE, true, false)
            Return()
          end
        elseif data.key == "all_enable_full" then
          item.name = string.format(colors[data.key], data.key)
          function item.func()
            ChangeStatusAll(FLOWCHART_STATUS.ENABLE, true, true)
            Return()
          end
        elseif data.key == "lock_begin" then
          item.name = string.format(colors[data.key], data.key)
          function item.func()
            ChangeStatusAll(FLOWCHART_STATUS.ENABLE, true, false)
            local scene_param = flowchart_ID.ID.flowchart23.scene_param
            local saveblock = _G.SAVEDATA.flowchart.flowchart23
            ChangeStatus(saveblock, scene_param, FLOWCHART_STATUS.ENABLE, false, false)
            saveblock.lockedanim[1] = true
            saveblock.lockedanim[2] = false
            local scene_param = flowchart_ID.ID.flowchart24.scene_param
            local saveblock = _G.SAVEDATA.flowchart.flowchart24
            ChangeStatus(saveblock, scene_param, FLOWCHART_STATUS.DISABLE, false, false)
            local scene_param = flowchart_ID.ID.flowchart25.scene_param
            local saveblock = _G.SAVEDATA.flowchart.flowchart25
            ChangeStatus(saveblock, scene_param, FLOWCHART_STATUS.DISABLE, false, false)
            local scene_param = flowchart_ID.ID.flowchart39.scene_param
            local saveblock = _G.SAVEDATA.flowchart.flowchart39
            ChangeStatus(saveblock, scene_param, FLOWCHART_STATUS.DISABLE, false, false)
            Return()
          end
        elseif data.key == "lock_now" then
          item.name = string.format(colors[data.key], data.key)
          function item.func()
            ChangeStatusAll(FLOWCHART_STATUS.ENABLE, true, false)
            local scene_param = flowchart_ID.ID.flowchart23.scene_param
            local saveblock = _G.SAVEDATA.flowchart.flowchart23
            ChangeStatus(saveblock, scene_param, FLOWCHART_STATUS.ENABLE, false, false)
            saveblock.lockedanim[1] = false
            saveblock.lockedanim[2] = true
            local scene_param = flowchart_ID.ID.flowchart24.scene_param
            local saveblock = _G.SAVEDATA.flowchart.flowchart24
            ChangeStatus(saveblock, scene_param, FLOWCHART_STATUS.DISABLE, false, false)
            local scene_param = flowchart_ID.ID.flowchart25.scene_param
            local saveblock = _G.SAVEDATA.flowchart.flowchart25
            ChangeStatus(saveblock, scene_param, FLOWCHART_STATUS.DISABLE, false, false)
            local scene_param = flowchart_ID.ID.flowchart39.scene_param
            local saveblock = _G.SAVEDATA.flowchart.flowchart39
            ChangeStatus(saveblock, scene_param, FLOWCHART_STATUS.DISABLE, false, false)
            Return()
          end
        elseif data.key == "lock_end" then
          item.name = string.format(colors[data.key], data.key)
          function item.func()
            ChangeStatusAll(FLOWCHART_STATUS.ENABLE, true, false)
            local scene_param = flowchart_ID.ID.flowchart23.scene_param
            local saveblock = _G.SAVEDATA.flowchart.flowchart23
            ChangeStatus(saveblock, scene_param, FLOWCHART_STATUS.ENABLE, false, false)
            saveblock.lockedanim[1] = false
            saveblock.lockedanim[2] = true
            local scene_param = flowchart_ID.ID.flowchart24.scene_param
            local saveblock = _G.SAVEDATA.flowchart.flowchart24
            ChangeStatus(saveblock, scene_param, FLOWCHART_STATUS.DISABLE, false, false)
            local scene_param = flowchart_ID.ID.flowchart25.scene_param
            local saveblock = _G.SAVEDATA.flowchart.flowchart25
            ChangeStatus(saveblock, scene_param, FLOWCHART_STATUS.DISABLE, false, false)
            local scene_param = flowchart_ID.ID.flowchart39.scene_param
            local saveblock = _G.SAVEDATA.flowchart.flowchart39
            ChangeStatus(saveblock, scene_param, FLOWCHART_STATUS.ENABLE, true, true)
            Return()
          end
        else
          local scene_param = flowchart_ID.ID[data.key].scene_param
          local saveblock = _G.SAVEDATA.flowchart[data.key]
          local txt_color = "disable"
          if saveblock.status == FLOWCHART_STATUS.ENABLE then
            txt_color = "enable"
            for index, param in ipairs(scene_param) do
              local process = saveblock.process[index]
              if param.group ~= nil and param.group == "termination" and process.cleared == true then
                txt_color = "enable_full"
                break
              end
            end
          elseif saveblock.status == FLOWCHART_STATUS.UNREACHED then
            txt_color = "unreach"
          end
          item.name = string.format(colors[txt_color], data.id.name)
          local isEnable = saveblock.status == FLOWCHART_STATUS.ENABLE
          if txt_color == "disable" then
            function item.func()
              ChangeStatus(saveblock, scene_param, FLOWCHART_STATUS.UNREACHED, false, false)
              Return()
            end
          elseif txt_color == "unreach" then
            function item.func()
              ChangeStatus(saveblock, scene_param, FLOWCHART_STATUS.ENABLE, false, false)
              Return()
            end
          elseif txt_color == "enable" then
            function item.func()
              ChangeStatus(saveblock, scene_param, FLOWCHART_STATUS.ENABLE, true, true)
              Return()
            end
          else
            function item.func()
              ChangeStatus(saveblock, scene_param, FLOWCHART_STATUS.DISABLE, false, false)
              Return()
            end
          end
        end
        table.insert(menu, item)
      end
      CreateWindow({
        "Flowchart Debug",
        ":develop:900_01:"
      }, menu)
    end
    local function FileDebug()
      local list = {}
      local function Add(ids)
        for key, id in pairs(ids) do
          data = {key = key, id = id}
          table.insert(list, data)
        end
      end
      Add(file_album_ID.ID)
      Add(file_characters_ID.ID)
      Add(file_supporting_ID.ID)
      local all_enable = {key = "all_enable"}
      local all_enable_viewed = {
        key = "all_enable_viewed"
      }
      local all_disable = {
        key = "all_disable"
      }
      local special_89 = {
        key = "FilesIG_J_0400",
        id = file_characters_ID.ID.FilesIG_J_0190
      }
      local special_aiball = {
        key = "FilesIG_J_0390",
        id = file_characters_ID.ID.FilesIG_J_0020
      }
      table.insert(list, all_enable)
      table.insert(list, all_enable_viewed)
      table.insert(list, all_disable)
      table.insert(list, special_89)
      table.insert(list, special_aiball)
      local pri = {
        all_enable = 1,
        all_enable_viewed = 2,
        all_disable = 3
      }
      local function sorting(a, b)
        local pri_A = pri[a.key]
        local pri_B = pri[b.key]
        if pri_A ~= nil and pri_B ~= nil then
          return pri_A < pri_B
        elseif pri_A ~= nil then
          return true
        elseif pri_B ~= nil then
          return false
        end
        return a.key < b.key
      end
      table.sort(list, sorting)
      local colors = {}
      colors.disable = "<color=#888888>%s</color>"
      colors.enable = "<color=#ffff88>%s</color>"
      colors.enable_viewed = "<color=#ffffff>%s</color>"
      colors.all_disable = "<color=#ff4444>%s</color>"
      colors.all_enable = "<color=#ffff88>%s</color>"
      colors.all_enable_viewed = "<color=#88ffff>%s</color>"
      local ChangeStatusFull = function(saveblock, status1, status2)
        saveblock.status[1] = status1
        saveblock.status[2] = status2
      end
      local function ChangeStatusFullAll(status1, status2)
        for key, data in ipairs(list) do
          local saveblock = _G.SAVEDATA.file[data.key]
          if saveblock ~= nil then
            ChangeStatusFull(saveblock, status1, status2)
          end
        end
      end
      local function Return()
        background.trigger.onPointerClick()
      end
      local menu = {}
      for key, data in ipairs(list) do
        local saveblock = _G.SAVEDATA.file[data.key]
        local item = {}
        if data.key == "all_disable" then
          item.name = string.format(colors[data.key], data.key)
          function item.func()
            ChangeStatusFullAll(FILE_STATUS.Disable, FILE_STATUS.Disable)
            Return()
          end
        elseif data.key == "all_enable" then
          item.name = string.format(colors[data.key], data.key)
          function item.func()
            ChangeStatusFullAll(FILE_STATUS.Enable, FILE_STATUS.Disable)
            Return()
          end
        elseif data.key == "all_enable_viewed" then
          item.name = string.format(colors[data.key], data.key)
          function item.func()
            ChangeStatusFullAll(FILE_STATUS.Enable, FILE_STATUS.Enable)
            Return()
          end
        else
          local isEnable = saveblock.status[1] == FILE_STATUS.Enable
          local txt_color = "disable"
          if saveblock.status[1] == FILE_STATUS.Enable and saveblock.status[2] == FILE_STATUS.Enable then
            txt_color = "enable_viewed"
          elseif saveblock.status[1] == FILE_STATUS.Enable then
            txt_color = "enable"
          end
          local str = i18n.GetText(data.id.title.text)
          item.name = string.format(colors[txt_color], str)
          if isEnable then
            function item.func()
              ChangeStatusFull(saveblock, FILE_STATUS.Disable, FILE_STATUS.Disable)
              Return()
            end
          else
            function item.func()
              ChangeStatusFull(saveblock, FILE_STATUS.Enable, FILE_STATUS.Disable)
              Return()
            end
          end
        end
        table.insert(menu, item)
      end
      CreateWindow({
        "File Debug",
        ":develop:900_02:"
      }, menu)
    end
    local function TrophyDebug()
      local list = {}
      local function Add(ids)
        for key, id in pairs(ids) do
          data = {key = key, id = id}
          table.insert(list, data)
        end
      end
      Add(trophy_ID.ID)
      local all_lock = {key = "all_lock"}
      local all_unlock = {key = "all_unlock"}
      table.insert(list, all_lock)
      table.insert(list, all_unlock)
      local pri = {all_lock = 1, all_unlock = 2}
      local function sorting(a, b)
        local pri_A = pri[a.key]
        local pri_B = pri[b.key]
        if pri_A ~= nil and pri_B ~= nil then
          return pri_A < pri_B
        elseif pri_A ~= nil then
          return true
        elseif pri_B ~= nil then
          return false
        end
        return a.key < b.key
      end
      table.sort(list, sorting)
      local colors = {}
      colors.lock = "<color=#888888>%s</color>"
      colors.unlock = "<color=#ffff88>%s</color>"
      colors.all_lock = "<color=#ffff88>%s</color>"
      colors.all_unlock = "<color=#88ffff>%s</color>"
      local platform = "STEAM"
      if UNITY_SWITCH == 1 then
        platform = "SWITCH"
      elseif UNITY_PS4 == 1 then
        platform = "PS4"
      elseif UNITY_XBOXONE == 1 then
        platform = "XBOX"
      end
      local Lock = function(key)
        print("Requested TrophyLock\t:\t", key)
        Game.TrophyManager.instance:Abandon(key)
      end
      local UnLock = function(key)
        print("Requested TrophyUnLock\t:\t", key)
        Game.TrophyManager.instance:Acquire(key)
      end
      local IsUnLocked = function(key)
        return Game.TrophyManager.instance:IsAcquired(key)
      end
      local function AllLock()
        for key, data in ipairs(list) do
          if data.id ~= nil then
            Lock(data.key)
          end
        end
      end
      local function AllUnLock()
        for key, data in ipairs(list) do
          if data.id ~= nil and data.id.isPlatinum ~= true then
            UnLock(data.key)
          end
        end
      end
      local function Return()
        background.trigger.onPointerClick()
      end
      local menu = {}
      for key, data in ipairs(list) do
        local item = {}
        if data.key == "all_lock" then
          item.name = string.format(colors[data.key], data.key)
          function item.func()
            AllLock()
            Return()
          end
        elseif data.key == "all_unlock" then
          item.name = string.format(colors[data.key], data.key)
          function item.func()
            AllUnLock()
            Return()
          end
        else
          local txt_color = "lock"
          if IsUnLocked(data.key) then
            txt_color = "unlock"
          end
          local str = data.key
          if data.id.platinum == true then
            str = str .. " [PLATINUM]"
          end
          item.name = string.format(colors[txt_color], str)
          if txt_color == "lock" then
            function item.func()
              UnLock(data.key)
              Return()
            end
          else
            function item.func()
              Lock(data.key)
              Return()
            end
          end
        end
        table.insert(menu, item)
      end
      CreateWindow({
        "Trophy Debug",
        ":develop:900_03:"
      }, menu)
    end
    local function FlowchartDebug2()
      local list = {
        {
          title = "C5-begin Lock by C4-wrap_20_10_BossRoom_AiBall",
          clears = {
            {part = "A1-begin"},
            {part = "A1-psync"},
            {part = "A2-begin"},
            {part = "A2-psync"},
            {part = "A2-wrap"},
            {part = "A3-begin"},
            {part = "A3-psync"},
            {part = "C3-wrap"},
            {part = "C4-begin"},
            {part = "C4-psync"},
            {part = "C4-wrap", pre = true}
          }
        },
        {
          title = "B5-begin Lock by E4-wrap_45_10_FreezeWH_AiBall",
          clears = {
            {part = "A1-begin"},
            {part = "A1-psync"},
            {part = "A2-begin"},
            {part = "A2-psync"},
            {part = "D2-wrap"},
            {part = "D3-begin"},
            {part = "D3-psync"},
            {part = "D3-wrap"},
            {part = "D4-begin"},
            {part = "D4-psync"},
            {part = "E4-wrap", pre = true}
          }
        },
        {
          title = "C5-begin & B5-begin Lock by C4-wrap_20_10_BossRoom_AiBall or E4-wrap_45_10_FreezeWH_AiBall",
          clears = {
            {part = "A1-begin"},
            {part = "A1-psync"},
            {part = "A2-begin"},
            {part = "A2-psync"},
            {part = "A2-wrap"},
            {part = "A3-begin"},
            {part = "A3-psync"},
            {part = "C3-wrap"},
            {part = "C4-begin"},
            {part = "C4-psync"},
            {part = "C4-wrap", pre = true},
            {part = "D2-wrap"},
            {part = "D3-begin"},
            {part = "D3-psync"},
            {part = "D3-wrap"},
            {part = "D4-begin"},
            {part = "D4-psync"},
            {part = "E4-wrap", pre = true}
          }
        },
        {
          title = "E5-begin UnLock by D5-wrap_10_10_SaitoAgt_Iris",
          clears = {
            {part = "A1-begin"},
            {part = "A1-psync"},
            {part = "A2-begin"},
            {part = "A2-psync"},
            {part = "A2-wrap"},
            {part = "A3-begin"},
            {part = "A3-psync"},
            {part = "C3-wrap"},
            {part = "C4-begin"},
            {part = "C4-psync"},
            {part = "C4-wrap"},
            {part = "D2-wrap"},
            {part = "D3-begin"},
            {part = "D3-psync"},
            {part = "D3-wrap"},
            {part = "D4-begin"},
            {part = "D4-psync"},
            {part = "E4-wrap"},
            {part = "A3-wrap"},
            {part = "A4-begin"},
            {part = "A4-psync"},
            {part = "A4-wrap"},
            {part = "A5-begin"},
            {part = "A5-psync"},
            {part = "A5-wrap"},
            {part = "B4-wrap"},
            {part = "B5-begin"},
            {part = "B6-begin"},
            {part = "B6-psync"},
            {part = "B6-wrap"},
            {part = "D4-wrap"},
            {part = "D5-begin"},
            {part = "D5-psync"},
            {part = "D5-wrap", pre = true},
            {part = "E5-begin", lock = true},
            {part = "C5-begin", lock = true}
          }
        },
        {
          title = "E6-begin Lock and C5-begin UnLock by E5-wrap_80_10_SaitoAgt_Hitomi",
          clears = {
            {part = "A1-begin"},
            {part = "A1-psync"},
            {part = "A2-begin"},
            {part = "A2-psync"},
            {part = "A2-wrap"},
            {part = "A3-begin"},
            {part = "A3-psync"},
            {part = "C3-wrap"},
            {part = "C4-begin"},
            {part = "C4-psync"},
            {part = "C4-wrap"},
            {part = "D2-wrap"},
            {part = "D3-begin"},
            {part = "D3-psync"},
            {part = "D3-wrap"},
            {part = "D4-begin"},
            {part = "D4-psync"},
            {part = "E4-wrap"},
            {part = "A3-wrap"},
            {part = "A4-begin"},
            {part = "A4-psync"},
            {part = "A4-wrap"},
            {part = "A5-begin"},
            {part = "A5-psync"},
            {part = "A5-wrap"},
            {part = "B4-wrap"},
            {part = "B5-begin"},
            {part = "B6-begin"},
            {part = "B6-psync"},
            {part = "B6-wrap"},
            {part = "D4-wrap"},
            {part = "D5-begin"},
            {part = "D5-psync"},
            {part = "D5-wrap"},
            {part = "E5-begin"},
            {part = "E5-psync"},
            {part = "E5-wrap", pre = true},
            {part = "C5-begin", lock = true}
          }
        },
        {
          title = "E6-begin UnLock by C5-wrap_20_10_Psync-Rm_Boss",
          clears = {
            {part = "A1-begin"},
            {part = "A1-psync"},
            {part = "A2-begin"},
            {part = "A2-psync"},
            {part = "A2-wrap"},
            {part = "A3-begin"},
            {part = "A3-psync"},
            {part = "C3-wrap"},
            {part = "C4-begin"},
            {part = "C4-psync"},
            {part = "C4-wrap"},
            {part = "D2-wrap"},
            {part = "D3-begin"},
            {part = "D3-psync"},
            {part = "D3-wrap"},
            {part = "D4-begin"},
            {part = "D4-psync"},
            {part = "E4-wrap"},
            {part = "A3-wrap"},
            {part = "A4-begin"},
            {part = "A4-psync"},
            {part = "A4-wrap"},
            {part = "A5-begin"},
            {part = "A5-psync"},
            {part = "A5-wrap"},
            {part = "B4-wrap"},
            {part = "B5-begin"},
            {part = "B6-begin"},
            {part = "B6-psync"},
            {part = "B6-wrap"},
            {part = "D4-wrap"},
            {part = "D5-begin"},
            {part = "D5-psync"},
            {part = "D5-wrap"},
            {part = "E5-begin"},
            {part = "E5-psync"},
            {part = "E5-wrap"},
            {part = "C5-begin"},
            {part = "C5-psync"},
            {part = "C5-wrap", pre = true},
            {part = "E6-begin", lock = true}
          }
        },
        {
          title = "A2-wrap UNREACH & D2-wrap REACH",
          clears = {
            {part = "A1-begin"},
            {part = "A1-psync"},
            {part = "A2-begin"},
            {part = "A2-psync"},
            {part = "A2-wrap", unreach = true},
            {part = "D2-wrap", pre = true}
          }
        },
        {
          title = "SpChun_BOSS reappear",
          clears = {
            {part = "A1-begin"},
            {part = "A1-psync"},
            {part = "A2-begin"},
            {part = "A2-psync"},
            {part = "A2-wrap"},
            {part = "A3-begin"},
            {part = "A3-psync"},
            {part = "A3-wrap"},
            {part = "A4-begin"},
            {part = "A4-psync"},
            {part = "A4-wrap"},
            {part = "A5-begin"},
            {part = "A5-psync"},
            {part = "A5-wrap"},
            {part = "B4-wrap"},
            {part = "B5-begin"},
            {part = "C3-wrap"},
            {part = "C4-begin"},
            {part = "C4-psync"},
            {part = "C4-wrap"},
            {part = "D2-wrap"},
            {part = "D3-begin"},
            {part = "D3-psync"},
            {part = "D3-wrap"},
            {part = "D4-begin"},
            {part = "D4-psync"},
            {part = "D4-wrap"},
            {part = "D5-begin"},
            {part = "D5-psync"},
            {part = "D5-wrap", pre = true},
            {part = "E4-wrap"},
            {part = "E5-begin", lock = true},
            {part = "C5-begin", lock = true}
          }
        }
      }
      local colors = {}
      colors.disable = "<color=#888888>%s</color>"
      colors.unreach = "<color=#44FF44>%s</color>"
      colors.enable = "<color=#ffff88>%s</color>"
      local FlowchartSavedataUtil = optionmenu_util.CreateFlowchartSavedataUtil()
      local function Edit(script, isClear)
        FlowchartSavedataUtil:Open(script)
        FlowchartSavedataUtil:Play(script)
        if isClear then
          FlowchartSavedataUtil:Clear(script)
        end
      end
      local function Return()
        background.trigger.onPointerClick()
      end
      local menu = {}
      for key, data in ipairs(list) do
        local item = {}
        item.name = data.title
        function item.func()
          for ii, clear in ipairs(data.clears) do
            local id, key = optionmenu_util.GetFlowchartIDByPartName(clear.part)
            if clear.lock then
              local SAVEDATA_LOCK = _G.SAVEDATA.flowchart[key]
              SAVEDATA_LOCK.status = FLOWCHART_STATUS.ENABLE
              SAVEDATA_LOCK.lockedanim[1] = false
              SAVEDATA_LOCK.lockedanim[2] = true
            elseif clear.unreach then
              local SAVEDATA_LOCK = _G.SAVEDATA.flowchart[key]
              SAVEDATA_LOCK.status = FLOWCHART_STATUS.UNREACHED
            else
              for i, process in ipairs(id.scene_param) do
                if process.lua then
                  local script = process.lua
                  if string.find(clear.part, "-psync") then
                    script = script .. "_somnium"
                  end
                  local isClear = true
                  if clear.pre and i == #id.scene_param then
                    isClear = false
                  end
                  Edit(script, isClear)
                end
              end
            end
          end
          Return()
        end
        table.insert(menu, item)
      end
      CreateWindow({
        "Flowchart Debug 2",
        ":develop:900_08:"
      }, menu)
    end
    local top_menu = {
      {
        name = {
          "Start game",
          ":develop:01_32:"
        },
        func = Start
      },
      {
        name = {
          "Investigation",
          ":develop:01_34:"
        },
        func = InvestigationFolder
      },
      {
        name = {
          "Somnium",
          ":develop:01_35:"
        },
        func = SomniumList
      },
      {
        name = {
          "Staff Roll",
          ":develop:01_37:"
        },
        func = StaffRoll
      },
      {
        name = {
          "BG Viewer",
          ":develop:01_38:"
        },
        func = BGViewer
      },
      {
        name = {
          "BG Viewer (Recording)",
          ":develop:01_91:"
        },
        func = BGRecordViewer
      },
      {
        name = {
          "Recording",
          ":develop:01_92:"
        },
        func = Recorder
      },
      {
        name = {
          "Dance",
          ":develop:01_93:"
        },
        func = Dance
      },
      {
        name = {
          "Text Language",
          ":develop:01_40:"
        },
        func = TextLanguage
      },
      {
        name = {
          "Voice Language",
          ":develop:01_41:"
        },
        func = VoiceLanguage
      },
      {
        name = {
          "System Language",
          ":develop:01_40:"
        },
        func = SystemLanguage
      },
      {
        name = {
          "Platform Settings",
          ":develop:01_42:"
        },
        format = FormatPlatfomr,
        func = PseudoPlatform
      },
      {
        name = {
          "UI check",
          ":develop:01_43:"
        },
        func = UI
      },
      {
        name = {
          "Time Set",
          ":develop:01_44:"
        },
        func = Aging
      },
      {
        name = {
          "Set Flag",
          ":develop:01_45:"
        },
        func = ClearSkipFlag
      },
      {
        name = {
          "Joypad",
          ":develop:01_46:"
        },
        func = Joypad
      },
      {
        name = {
          "Remove Flags",
          ":develop:01_47:"
        },
        func = ExtractFlag
      },
      {
        name = {
          "April Milestone Check",
          ":develop:01_48:"
        },
        func = Milestone
      },
      {
        name = {
          "Pad View",
          ":develop:900_04:"
        },
        func = PadView
      },
      {
        name = {
          "Flowchart Debug",
          ":develop:900_05:"
        },
        func = FlowchartDebug
      },
      {
        name = {
          "File Debug",
          ":develop:900_06:"
        },
        func = FileDebug
      },
      {
        name = {
          "Trophy Debug",
          ":develop:900_07:"
        },
        func = TrophyDebug
      },
      {
        name = {
          "Flowchart Debug 2",
          ":develop:900_08:"
        },
        func = FlowchartDebug2
      }
    }
    function topmenu:Debug()
      if UNITY_PS4 == 1 then
      end
    end
    local base = FindObjectInScene(CurrentScene, "DebugMenu")
    local update_task
    local function proc()
      while true do
        if base.gameObject.activeInHierarchy == false then
          update_task:Stop()
          return
        end
        if Input.GetButtonDown(BUTTON_SUBMIT) or Input.GetButtonDown(BUTTON_L2) then
          stickSubmit = true
        end
        if Input.GetButtonDown(BUTTON_CANCEL) or Input.GetButtonDown(BUTTON_DPAD_LEFT) then
          stickCancel = true
        end
        for _, win in pairs(windows) do
          win:Proc()
        end
        coroutine.yield()
      end
    end
    update_task = task.Create(proc):SetParent(obj)
    CreateWindow("Top", top_menu)
    Deserialize()
    return topmenu
  end
  local function CreateListWindow(obj, menu)
    local viewport = FindObject(obj, "Viewport")
    local contents = FindObject(obj, "Contents")
    local decide = FindObject(obj, "Decide")
    local cursor = FindObject(obj, "Cursor")
    local scrollRect = viewport.scrollRect
    local info = FindObject(obj, "Info", true)
    local y = 0
    local no = 0
    local current = 0
    local enter = false
    local update_task
    local drag = Time.realtimeSinceStartup
    local force = false
    local cursor_cy = 0
    local cursor_ty = 0
    local cy = 0
    local ty = 0
    local sy = 0
    local list = {}
    local lines = {}
    local enter_enable = true
    local persist
    decide:SetCanvasGroupActive(false)
    contents.transform.anchoredPosition = Vector2(0, 0)
    local children = GetGameObjectPool(contents, "@DebugItem")
    local text_height = PrefabItem.transform.rect.height
    local item_num = math.modf(viewport.transform.rect.height / text_height) + 3
    local items = {}
    local GetFullName = function(content)
      local full_name = content.name
      local cur = content
      while cur.parent ~= nil do
        cur = cur.parent
        full_name = cur.name .. "/" .. full_name
      end
      return full_name
    end
    local function GetItem(i)
      if items[i] then
        return items[i]
      end
      local item = InstantiatePool(children, PrefabItem.gameObject, contents, true)
      item.gameObject:SetActive(true)
      function item.Base.trigger.onBeginDrag(data)
        obj:Focus(true)
        scrollRect:OnBeginDrag(data)
      end
      function item.Base.trigger.onDrag(data)
        drag = Time.realtimeSinceStartup
        scrollRect:OnDrag(data)
      end
      function item.Base.trigger.onEndDrag(data)
        drag = Time.realtimeSinceStartup
        scrollRect:OnEndDrag(data)
      end
      function item.Base.trigger.onPointerDown()
        obj:Focus(true)
      end
      function item.Base.trigger.onPointerClick(data)
        obj:Focus(true)
        if Time.realtimeSinceStartup - drag > 0.1 then
          local content = item.vars.content
          if data == nil or data.button == 0 then
            if persist then
              persist.y = contents.transform.anchoredPosition.y
            end
            savedata.save()
            if content.children then
              content.open = not content.open
              if content.exec ~= nil then
                content:exec()
                content.exec = nil
              else
                obj:ShowList()
              end
              local full_name = GetFullName(content)
              if persist then
                if content.open then
                  persist[full_name] = true
                else
                  persist[full_name] = nil
                end
                savedata.save()
              end
              decide:SetCanvasGroupActive(false)
            else
              if content.value ~= nil then
                content.value = not content.value
                item.Checkbox.Image.Image:SetCanvasGroupActive(content.value == true)
                if content.onValueChanged ~= nil then
                  content:onValueChanged(content.value)
                end
              end
              if content.exec ~= nil then
                decide:SetCanvasGroupActive(true)
                decide.transform.anchoredPosition = item.gameObject.transform.anchoredPosition
                content:exec()
              end
            end
          elseif content.execR ~= nil and content:execR() == false then
            content.open = not content.open
            obj:ShowList()
            decide:SetCanvasGroupActive(false)
          end
        end
      end
      if enter_enable then
        function item.Base.trigger.onPointerEnter(data)
          if Time.realtimeSinceStartup - drag > 0.1 and item.content then
            current = item.content.no
            enter = true
          end
        end
        function item.Base.trigger.onPointerExit(data)
          enter = false
        end
      end
      function item.Base.trigger.onScroll(data)
        obj:OnScroll(data)
      end
      function item.Checkbox.Image.trigger.onPointerClick(data)
        obj:Focus(true)
        if persist then
          persist.y = contents.transform.anchoredPosition.y
          savedata.save()
        end
        local content = item.vars.content
        content.value = not content.value
        item.Checkbox.Image.Image:SetCanvasGroupActive(content.value == true)
        if content.onValueChanged ~= nil then
          content:onValueChanged(content.value)
        end
      end
      function item.InputField.InputField.luaInputField.onValueChanged()
        local content = item.vars.content
        if content.onValueChanged then
          content:onValueChanged(item.InputField.InputField.tMP_InputField.text)
        end
      end
      function item.InputField.InputField.luaInputField.onEndEdit()
        local content = item.vars.content
        if content.onEndEdit then
          content:onEndEdit(item.InputField.InputField.tMP_InputField.text)
        end
      end
      item:SetCanvasGroupActive(false)
      items[i] = item
      return item
    end
    function info.trigger.onPointerDown(data)
      obj:Focus(true)
    end
    function viewport.trigger.onPointerDown(data)
      obj:Focus(true)
    end
    function viewport.trigger.onPointerClick()
      local content = lines[current + 1]
      if content then
        if content.children then
          content.open = not content.open
          obj:ShowList()
          decide:SetCanvasGroupActive(false)
        end
        if content.value ~= nil then
          content.value = not content.value
          local item = content.item
          if item then
            item.Checkbox.Image.Image:SetCanvasGroupActive(content.value == true)
            if content.onValueChanged ~= nil then
              content:onValueChanged(content.value)
            end
          end
        end
        if content.exec ~= nil then
          SE:Play("SE/SE_SYS_CLICK")
          decide:SetCanvasGroupActive(true)
          local item = content.item
          if item then
            decide.transform.anchoredPosition = item.gameObject.transform.anchoredPosition
          end
          content:exec()
        end
      end
    end
    function obj:Focus(b)
      cursor.image.enabled = b and #lines ~= 0
      if b then
        info.image.color = Color(0.2, 0.4, 0.4)
      else
        info.image.color = Color(0.2, 0.1, 0.1)
      end
      obj.vars.focus = b
      if b then
        EventSystems.EventSystem.current:SetSelectedGameObject(viewport.gameObject)
        for _, v in ipairs(obj.vars.group) do
          if v.gameObject ~= obj.gameObject then
            v:Focus(false)
          end
        end
      end
    end
    function obj:onDestroy()
      update_task:Stop()
    end
    function obj:OnScroll(data)
      local scroll_dy = data.scrollDelta.y
      if scroll_dy ~= nil then
        local dy = -scroll_dy * text_height
        local yy = contents.transform.anchoredPosition.y + dy
        yy = math.max(yy, 0)
        yy = math.min(yy, math.max(contents.transform.rect.height - viewport.transform.rect.height, 0))
        contents.transform.anchoredPosition = Vector2(0, yy)
      end
      local mousePosition = ES.vars.inputModule:GetMousePosition()
      local pointerEventData = EventSystems.PointerEventData()
      pointerEventData.position = mousePosition
      local result = ListRaycastResult()
      Canvas.graphicRaycaster:Raycast(pointerEventData, result)
      for v in Slua.iter(result) do
        local comp = v.gameObject:GetComponent(LuaEventTrigger)
        if comp and comp.onPointerEnter then
          comp.onPointerEnter()
        end
      end
    end
    function viewport.trigger.onScroll(data)
      obj:OnScroll(data)
    end
    local buttons = {}
    function obj:AddItem(res)
      local item = Instantiate(PrefabItem.gameObject, true)
      item.transform:SetParent(contents.transform, false)
      item.Text.text.text = res.name
      item.transform.anchoredPosition = Vector2(0, -y)
      item.Text.text.color = _q_(res.func ~= nil, Color(1, 1, 1), Color(0.5, 0.5, 0.5))
      y = y + item.transform.rect.height + 2
      height = item.transform.rect.height + 2
      contents.transform.sizeDelta = Vector2(0, y)
      item.vars.no = no
      function item.trigger.onCancel()
        if win_level ~= 1 then
          for i, v in pairs(windows) do
            if v.level == win_level then
              v:Destroy()
              windows[i] = nil
            end
          end
          win_level = win_level - 1
          for _, v in ipairs(windows) do
            if v.level == win_level then
              v:SetFocus(true)
            end
          end
          Serialize()
        end
      end
      no = no + 1
      table.insert(buttons, item)
      return item
    end
    local viewport_height = viewport.transform.rect.height
    local repeatInput = CreateRepeatKey(AXIS_DPAD_VERTICAL, AXIS_RSTICK_VERTICAL, true)
    local function proc()
      if not enter_enable then
      end
      if obj ~= ConsoleViewer and obj ~= ScriptViewer and Input.GetButtonDown(BUTTON_SUBMIT, true) then
        local content = lines[current + 1]
        if content then
          local item = content.item
          if item then
            item.Base.trigger.onPointerClick()
          end
        end
      end
      if #list ~= 0 and enter == false and obj.vars.focus == true then
        local dy = repeatInput:Update()
        if dy ~= 0 then
          if current == nil then
            current = 1
          elseif dy < 0 then
            current = math.min(current + 1, #lines - 1)
          else
            current = math.max(current - 1, 0)
          end
        end
      end
      cursor_ty = current * text_height
      cursor_cy = cursor_cy + (cursor_ty - cursor_cy) * math.min(Time.smoothDeltaTime * 30, 1)
      cursor.transform.anchoredPosition = Vector2(0, -cursor_cy - 24)
      if cursor_cy + text_height > viewport_height + ty then
        ty = cursor_cy + text_height - viewport_height
      end
      if cursor_cy < ty then
        ty = cursor_cy
      end
      if ty ~= cy then
        if math.abs(ty - cy) >= 0.1 then
          if math.abs(ty - cy) >= text_height * 10 then
            cy = ty
          else
            cy = cy + (ty - cy) * math.min(Time.smoothDeltaTime * 10, 1)
          end
        else
          cy = ty
        end
        contents.transform.anchoredPosition = Vector3(0, cy, 0)
      end
      local l = math.modf(contents.transform.anchoredPosition.y / text_height)
      if (l ~= sy or force == true) and lines ~= nil then
        force = false
        sy = l
        for i = 1, item_num do
          local l0 = i + sy
          local content = lines[l0]
          local ll = math.modf(l0 % item_num)
          local item = GetItem(ll + 1)
          item.vars.content = content
          if content == nil then
            item:SetCanvasGroupActive(false)
          else
            content.item = item
            item:SetCanvasGroupActive(true)
            local yy = (l0 - 1) * text_height
            item.transform.anchoredPosition = Vector2(0, -yy)
            item.Base.Rect.transform.anchoredPosition = Vector2(content.level * 20, 0)
            item.Base.Rect.Text.text.text = content.name
            item.Base.Rect.Folder.image.enabled = content.children ~= nil
            item.Base.Rect.Folder.transform.eulerAngles = Vector3(0, 0, _q_(content.open, -90, 0))
            item.vars.content = content
            item.Button.gameObject:SetActive(false)
            if type(content.value) == "boolean" then
              item.Checkbox.gameObject:SetActive(true)
              item.Checkbox.Image.Image:SetCanvasGroupActive(content.value == true)
            else
              item.Checkbox.gameObject:SetActive(false)
            end
            if type(content.value) == "number" or type(content.value) == "string" then
              item.InputField.gameObject:SetActive(true)
              item.InputField.InputField.tMP_InputField.text = tostring(content.value)
            else
              item.InputField.gameObject:SetActive(false)
            end
          end
        end
      end
    end
    update_task = task.CreateLoop(proc):SetParent(obj)
    function obj:ShowList()
      local function sub(l)
        for i, v in pairs(l) do
          v.no = #lines
          table.insert(lines, v)
          if v.children and v.open == true then
            sub(v.children)
          end
        end
      end
      lines = {}
      sub(list)
      contents.transform.sizeDelta = Vector2(contents.transform.sizeDelta.x, #lines * text_height)
      force = true
    end
    function obj:SetOffset(oy, dy, jump_flag)
      ty = oy * text_height
      if jump_flag then
        cy = ty
        contents.transform.anchoredPosition = Vector3(0, cy, 0)
      end
      current = oy
      cursor_ty = dy * text_height
      cursor_cy = dy * text_height
      decide:SetCanvasGroupActive(true)
      decide.transform.anchoredPosition = Vector2(0, -dy * text_height)
    end
    local function SetListSub(_list, parent, level)
      for i, v in ipairs(_list) do
        v.level = level
        v.parent = parent
        if v.children then
          if persist then
            local full_name = GetFullName(v)
            if persist[full_name] then
              v.open = true
              if v.exec ~= nil then
                v:exec()
                v.exec = nil
              end
            end
            if v.open == nil then
              v.open = false
            end
          end
          SetListSub(v.children, v, level + 1)
        end
      end
    end
    function obj:SetList(src)
      list = src
      SetListSub(src, nil, 0)
      obj:ShowList()
    end
    function obj:SetTitle(name, right_name)
      info.Func.text.text = name or ""
      info.FileName.text.text = right_name or ""
    end
    function obj:SetPersist(p)
      persist = p
      if persist.y then
        scrollRect.content.anchoredPosition = Vector2(0, persist.y)
      end
    end
    function obj:SetEnterEnable(b)
      enter_enable = b
    end
    obj:Focus(false)
    return obj
  end
  local function CreateScriptViewer()
    local obj = FindObjectInScene(CurrentScene, "ScriptViewer")
    obj.Func = FindObject(obj, "Func")
    obj.FileName = FindObject(obj, "FileName")
    CreateListWindow(obj, "script")
    obj:SetTitle("Script")
    local lists = {}
    local last = {}
    function obj:Show(module_name, func_name, line)
      if obj.gameObject.activeInHierarchy then
        local lines = source_manager.luaFiles[module_name]
        if lines == nil and module_name ~= "inc_script_func" and module_name ~= "movie" then
          source_manager.LoadLua(GetLuaFileName(module_name))
          lines = source_manager.luaFiles[module_name]
        end
        if lines and (last.module_name ~= module_name or last.func_name ~= func_name or last.lines ~= lines or last.line ~= line) then
          currentLuaFile = module_name
          currentLine = line
          obj:SetTitle(func_name, module_name)
          obj:SetEnterEnable(false)
          if lists[module_name] == nil then
            local list = {}
            for i, l in ipairs(lines) do
              l = source_manager.Colorlize(l)
              l = string.format("<color=green>%04d:</color>%s", i, l)
              local content = {}
              content.name = l
              content.linenum = i
              table.insert(list, content)
            end
            lists[module_name] = list
          end
          list = lists[module_name]
          obj:SetList(list)
          obj:SetOffset(line - 4, line - 1, last.module_name ~= module_name or last.func_name ~= func_name or last.lines ~= lines)
          last.module_name = module_name
          last.func_name = func_name
          last.lines = lines
          last.line = line
        end
      end
    end
    return obj
  end
  local function CreateSoundTest()
    local obj = FindObjectInScene(CurrentScene, "SoundTest")
    CreateListWindow(obj, "sound")
    obj:SetTitle("Sound")
    local stopButton = FindObject(obj, "StopButton")
    function stopButton.trigger.onPointerClick()
      BGM:StopAll(0.1)
      SE:StopAll(0.1)
    end
    local list = {}
    local play = function(_self)
      local fn = _self.base .. "/" .. _self.name
      fn = string.gsub(fn, "^/", "")
      if string.find(fn, "BGM/") == 1 then
        BGM:StopAll(0.1)
        BGM:Play(fn, SOUND_VOL_MID)
        Utility.CopyClipboard(string.format("BGM:Play('%s', SOUND_VOL_MID)", fn))
      elseif string.find(fn, "SE/") == 1 then
        SE:Play(fn, SOUND_VOL_MID)
        Utility.CopyClipboard(string.format("SE:Play('%s', SOUND_VOL_MID)", fn))
      else
        SE:Play(fn, SOUND_VOL_MID)
        Utility.CopyClipboard(string.format("SE:Play('%s', SOUND_VOL_MID)", fn))
      end
    end
    local function set(l, base)
      local function open(_self)
        _self.exec = nil
        base = _self.base .. "/" .. _self.name
        set(_self.children, base)
        obj:SetList(list)
      end
      for _, fi in ipairs(GetDirectories("Audio" .. base)) do
        local content = {}
        content.name = fi
        content.exec = open
        content.base = base
        content.children = {}
        table.insert(l, content)
      end
      for _, fi in ipairs(GetFiles("Audio" .. base)) do
        local content = {}
        content.name = fi
        content.base = base
        content.exec = play
        table.insert(l, content)
      end
    end
    function obj:OnCreate()
      set(list, "")
      obj:SetPersist(savedata.data_debug.SoundTest.persist)
      obj:SetList(list)
    end
    return obj
  end
  local function CreateEventCall()
    local obj = FindObjectInScene(CurrentScene, "EventCall")
    CreateListWindow(obj, "event")
    obj:SetTitle("Event")
    local exec = function(_self)
      if somnium then
        somnium.TestEvent(_self.name)
      end
    end
    local exec_investigation = function(_self)
      if investigation then
        investigation.TestEvent(_self.name)
      end
    end
    local function set(list, funcs)
      for i, v in ipairs(funcs) do
        local tag, fn = string.match(v, "[[](.*):.*[]].* (.*)")
        if tag and fn ~= "Initialize" and fn ~= "Update" and fn ~= "Enter" and fn ~= "FlagCheck" and fn ~= "City" and fn ~= "_movie_" then
          local content = {}
          content.name = fn
          content.exec = exec_investigation
          table.insert(list, content)
        end
      end
    end
    local list = {}
    function obj:Show(name)
      list = {}
      local funcs = LoadLuaFile(name)
      for i, v in ipairs(funcs) do
        local tag, fn = string.match(v, "[[](.*):.*[]].* (.*)")
        if tag == "EVENT" and fn ~= "Initialize" and fn ~= "main" then
          local content = {}
          content.name = fn
          content.exec = exec
          table.insert(list, content)
        end
      end
      obj:SetList(list)
    end
    function obj:ShowInvestigation(name)
      list = {}
      local funcs, incs = LoadLuaFile(name)
      set(list, funcs)
      for _, v in ipairs(incs) do
        local content = {}
        local children = {}
        content.name = v
        content.children = children
        local sub_funcs = LoadLuaFile(v)
        set(children, sub_funcs)
        table.insert(list, content)
      end
      obj:SetList(list)
    end
    return obj
  end
  local function CreateBGViewer()
    local obj = FindObjectInScene(CurrentScene, "BGViewer")
    CreateListWindow(obj, "bg")
    obj:SetTitle("BG")
    local list = {}
    local open = function(_self)
      Utility.CopyClipboard(string.format([[
BG:Load("%s")
BG:SetRight("%s")]], _self.name, _self.name))
      if investigation then
        investigation.TestLoadBG(_self.name)
      end
    end
    local function set(l, base)
      local ids = {}
      local section = {}
      for id, v in pairs(bgset.ID) do
        local s = string.match(id, "^(..)_")
        if s == nil then
          s = string.match(id, "^([^_]*)_")
        end
        if s then
          if section[s] == nil then
            section[s] = {}
          end
          table.insert(section[s], id)
        else
          table.insert(ids, id)
        end
      end
      table.sort(ids)
      local keys = {}
      for s, _ in pairs(section) do
        table.insert(keys, s)
      end
      table.sort(keys)
      for _, key in ipairs(keys) do
        local sec = section[key]
        local children = {}
        table.sort(sec)
        for _, id in ipairs(sec) do
          local content = {}
          content.name = id
          content.exec = open
          table.insert(children, content)
        end
        local content = {}
        content.name = key
        content.children = children
        table.insert(l, content)
      end
      for _, id in ipairs(ids) do
        local content = {}
        content.name = id
        content.exec = open
        table.insert(l, content)
      end
    end
    function obj:OnCreate()
      set(list, "")
      obj:SetPersist(savedata.data_debug.BGViewer.persist)
      obj:SetList(list)
    end
    return obj
  end
  local function CreateBustShotViewer()
    local obj = FindObjectInScene(CurrentScene, "BustShotViewer")
    CreateListWindow(obj, "bustShot")
    obj:SetTitle("BustShot")
    local list = {}
    local function open(_self)
      local function proc()
        local chara = _self.chara
        if type(chara) == "table" then
          chara = chara[1]
        end
        if investigation then
          investigation.Chara:SetFaceWeight(chara, 1)
          investigation.Face:Set(chara, _self.motion)
          investigation.Talk(chara, _self.id, ":A1-begin10_10:17_01:")
        end
        if somnium then
          somnium.Chara:SetFaceWeight(chara, 1)
          somnium.Face:Set(chara, _self.motion)
          somnium.Talk(chara, _self.id, ":A1-begin10_10:15_13:")
        end
      end
      task.Create(proc)
      prefix = ""
      if Input_.GetKey(KeyCode.RightShift) or Input_.GetKey(KeyCode.LeftShift) then
        prefix = "Left."
      end
      if Input_.GetKey(KeyCode.P) then
        prefix = "Phone."
      end
      Utility.CopyClipboard(string.format("%sFace:Set(\"%s\", \"%s\")", prefix, _self.chara, _self.motion))
    end
    local function set(l, base)
      local charas = {}
      for id, v in pairs(CharaSet) do
        table.insert(charas, id)
      end
      table.sort(charas)
      for _, key in ipairs(charas) do
        local sec = CharaSet[key].bust_animation
        if sec then
          local children = {}
          local keys = {}
          local emos = {}
          for emo, motion in pairs(sec) do
            table.insert(keys, motion)
            emos[motion] = emo
          end
          table.sort(keys)
          for _, id in ipairs(keys) do
            local content = {}
            content.chara = key
            content.name = string.format("%s:%s", string.gsub(id, "mo.*face_", ""), emos[id])
            content.motion = id
            content.id = emos[id]
            content.exec = open
            table.insert(children, content)
          end
          local content = {}
          content.name = key
          content.children = children
          table.insert(l, content)
        end
      end
    end
    function obj:OnCreate()
      set(list, "")
      obj:SetPersist(savedata.data_debug.BustShotViewer.persist)
      obj:SetList(list)
    end
    return obj
  end
  local function CreateFlagViewer()
    local obj = FindObjectInScene(CurrentScene, "FlagViewer")
    CreateListWindow(obj, "flag")
    obj:SetTitle("Flag")
    local OnValueChanged = function(_self, value)
      if _self.name == "\227\130\172\227\130\164\227\131\137\232\161\168\231\164\186\239\188\187DEBUG\239\188\189" and root.CaptureGuide then
        root.CaptureGuide.gameObject:SetActive(value)
      end
      if _self.type == "number" then
        value = tonumber(value)
      end
      if _self.type == "boolean" then
        value = value == true
      end
      flag[_self.name] = value
      if string.match(_self.name, "\239\188\187DEBUG\239\188\189") then
        savedata.save()
      end
    end
    local function create(name)
      local content = {}
      content.name = name
      content.value = flag[name]
      content.type = type(flag[name])
      content.onValueChanged = OnValueChanged
      return content
    end
    local function set(list, base)
      local flags = {}
      for i, v in pairs(flag) do
        if i ~= "_M" and i ~= "_NAME" and i ~= "_PACKAGE" and type(v) ~= "function" and type(v) ~= "table" then
          local f1, f2 = string.match(i, "(.*)(\239\188\187.*\239\188\189)")
          if f1 and f2 then
            if flags[f2] == nil then
              flags[f2] = {}
            end
            table.insert(flags[f2], i)
          else
            table.insert(list, create(i))
          end
        end
      end
      local keys = {}
      for i, v in pairs(flags) do
        table.insert(keys, i)
      end
      table.sort(keys)
      for _, i in pairs(keys) do
        local v = flags[i]
        local content = {}
        content.name = i
        local children = {}
        for _, c in ipairs(v) do
          table.insert(children, create(c))
        end
        content.children = children
        table.insert(list, content)
      end
    end
    local list = {}
    local create_flag = false
    function obj:Set(index, value)
      if create_flag == true then
        list = {}
        set(list, "")
        obj:SetList(list)
      end
    end
    function obj:OnCreate()
      create_flag = true
      set(list, "")
      obj:SetPersist(savedata.data_debug.FlagViewer.persist)
      obj:SetList(list)
    end
    return obj
  end
  local function CreateDebugViewer()
    local obj = FindObjectInScene(CurrentScene, "DebugViewer")
    CreateListWindow(obj, "debug")
    obj:SetTitle("Debug")
    local create_flag = false
    local hitGameObject = "none"
    local hitID = "none"
    local focus = "none"
    local val0 = "none"
    local val1 = "none"
    local bug = "none"
    local assetBundles = {}
    local function set(list, base)
      do
        local content = {}
        content.name = string.format("Hit GameObject : %s", hitGameObject)
        table.insert(list, content)
      end
      do
        local content = {}
        content.name = string.format("Hit ID : %s", hitID)
        table.insert(list, content)
      end
      do
        local content = {}
        content.name = string.format("Focus : %s", focus)
        table.insert(list, content)
      end
      do
        local content = {}
        content.name = string.format("val0 : %s", val0)
        table.insert(list, content)
      end
      do
        local content = {}
        content.name = string.format("val1 : %s", val1)
        table.insert(list, content)
      end
      do
        local content = {}
        content.name = string.format("bug : %s", bug)
        table.insert(list, content)
      end
      do
        local content = {}
        content.name = "somnium time"
        content.value = 360
        function content:onEndEdit(value)
          if type(value) == "string" then
            value = tonumber(value)
          end
          if type(value) == "number" then
            GLOBAL.Somnium.time = value
          end
        end
        table.insert(list, content)
      end
      do
        local content = {}
        content.name = "assetBundle " .. #assetBundles
        content.open = true
        local children = {}
        content.children = children
        for _, name in ipairs(assetBundles) do
          local child = {}
          child.name = name
          table.insert(children, child)
        end
        table.insert(list, content)
      end
      obj:SetList(list)
    end
    function obj:SetHitGameObject(name)
      if obj.gameObject.activeInHierarchy and hitGameObject ~= name and create_flag == true then
        hitGameObject = name
        list = {}
        set(list, "")
        obj:SetList(list)
      end
    end
    function obj:SetHitID(name)
      if obj.gameObject.activeInHierarchy and hitID ~= name and create_flag == true then
        hitID = name
        list = {}
        set(list, "")
        obj:SetList(list)
      end
    end
    function obj:ShowAssetBundles()
      if obj.gameObject.activeInHierarchy then
        assetBundles = {}
        for name in Slua.iter(AssetBundles.AssetBundleManager.GetAssetBundles()) do
          table.insert(assetBundles, name)
        end
        table.sort(assetBundles)
        list = {}
        set(list, "")
        obj:SetList(list)
      end
    end
    function obj:SetBug(name)
      if obj.gameObject.activeInHierarchy and bug ~= name and create_flag == true then
        bug = name
        list = {}
        set(list, "")
        obj:SetList(list)
      end
    end
    function obj:SetFocus(name)
      if focus ~= name and create_flag == true then
        focus = name
        list = {}
        set(list, "")
        obj:SetList(list)
      end
    end
    function obj:SetVal0(name)
      if obj.gameObject.activeInHierarchy and focus ~= name and create_flag == true then
        val0 = name
        list = {}
        set(list, "")
        obj:SetList(list)
      end
    end
    function obj:SetVal1(name)
      if obj.gameObject.activeInHierarchy and focus ~= name and create_flag == true then
        val1 = name
        list = {}
        set(list, "")
        obj:SetList(list)
      end
    end
    function obj:OnCreate()
      local list = {}
      create_flag = true
      set(list, "")
      obj:SetList(list)
    end
    return obj
  end
  local function CreateAnimationViewer()
    local obj = FindObjectInScene(CurrentScene, "AnimationViewer")
    CreateListWindow(obj, "animation")
    obj:SetTitle("Animation")
    local list = {}
    for _, v in ipairs({"\227\131\161\227\130\164\227\131\179", "\229\183\166"}) do
      local content = {}
      content.name = v
      table.insert(list, content)
    end
    local exec = function(_self)
      local leftFlag = false
      local parent = _self
      while true do
        if parent.parent == nil then
          break
        end
        parent = parent.parent
      end
      if parent.name == "\229\183\166" then
        leftFlag = true
      end
      if investigation then
        investigation.TestAnimation(_self.chara, _self.name, leftFlag)
      end
      if _self.parent and _self.parent.name == "face" then
        Utility.CopyClipboard(string.format("%sFace:Set('%s', '%s')", _q_(leftFlag, "Left.", ""), _self.chara, _self.name))
      else
        Utility.CopyClipboard(string.format("%sChara:Play('%s', '%s')", _q_(leftFlag, "Left.", ""), _self.chara, _self.name))
      end
    end
    local function add(cid, dir, name, children)
      for _, fn in ipairs(GetFiles(string.format("Graphic/3d/chara/motion/mot_%s_00%s", cid, dir))) do
        local animation_name, suffix = string.match(fn, "^(.*)_(..)$")
        if animation_name == nil or suffix ~= "lp" and suffix ~= "ed" and suffix ~= "st" then
          animation_name = fn
        end
        if suffix ~= "lp" and suffix ~= "ed" then
          local child = {}
          child.name = animation_name
          child.exec = exec
          child.chara = name
          table.insert(children, child)
        end
      end
    end
    local function open(_self)
      _self.exec = nil
      local cid = string.match(_self.acname, "^md_(c..)")
      if cid then
        local child = {}
        child.name = "face"
        child.chara = name
        child.children = {}
        add(cid, "/face", _self.name, child.children)
        table.insert(_self.children, child)
        add(cid, "", _self.name, _self.children)
      end
      obj:SetList(list)
    end
    function obj:Set(sceneName, components, nodes, tag)
      listsub = {}
      for _, ac in ipairs(components) do
        repeat
          break -- pseudo-goto
        until true
        if ac.gameObject.activeInHierarchy then
          local content = {}
          local acname = ac.transform.name
          if ac.transform.parent then
            acname = ac.transform.parent.name
          end
          local cid = string.match(acname, "^md_(c..)")
          if cid == nil then
            if ac.transform.parent and ac.transform.parent.parent then
              acname = ac.transform.parent.parent.name
            end
            cid = string.match(acname, "^md_(c..)")
          end
          local chara = acname
          if nodes ~= nil and nodes[chara] then
            chara = nodes[chara]
          end
          if cid then
            content.name = chara
            content.acname = acname
            local dirs = GetFiles(string.format("Graphic/3d/chara/motion/mot_%s_00", cid))
            if dirs ~= nil and 0 < #dirs then
              content.children = {}
              content.exec = open
            end
            table.insert(listsub, content)
          end
        end
      end
      obj:SetPersist(savedata.data_debug.AnimationViewer.persist)
      for _, v in ipairs(list) do
        if v.name == tag then
          v.children = listsub
        end
      end
      obj:SetList(list)
    end
    return obj
  end
  local function CreateConsoleViewer()
    local obj = FindObjectInScene(CurrentScene, "ConsoleViewer")
    CreateListWindow(obj, "console")
    obj:SetTitle("Console")
    local list = {}
    local execR = function(_self)
      local file, line = string.match(_self.name, "^([^:]*):([^:]+):")
      if file and line then
        source_namager.EditorJump(file, line)
        return true
      end
      return false
    end
    local function proc()
      while 30 < #list do
        table.remove(list, 15)
      end
      local logs = Utility.GetGameController().logs
      if logs.Count ~= 0 then
        for log in Slua.iter(logs) do
          local content = {}
          if log.type == 0 then
          end
          local ls = Split(log.mes, "\n")
          content.name = ls[1]
          content.execR = execR
          local children = {}
          if log.type == 0 then
            printerror2(ls[1])
          end
          if #ls ~= 1 then
            for j = 2, #ls do
              local child = {}
              local name = ls[j]
              child.name = name
              child.execR = execR
              table.insert(children, child)
            end
          end
          if #children == 0 then
            local ls1 = Split(log.stacktrace, "\n")
            for j = 1, #ls1 do
              local child = {}
              child.name = ls1[j]
              child.execR = execR
              table.insert(children, child)
            end
          end
          if #children ~= 0 then
            content.children = children
          end
          table.insert(list, content)
        end
        logs:Clear()
        obj:SetList(list)
      end
    end
    task.CreateLoop(proc):SetParent(obj)
    return obj
  end
  local CreateTabButton = function(name, pane, tab_group)
    local obj = FindObjectInScene(CurrentScene, name)
    pane.vars.button = obj
    function obj.trigger.onPointerClick()
      savedata.data_debug.right.focusWindow = pane.gameObject.name
      savedata.save()
      pane.transform:SetAsLastSibling()
      for _, v in ipairs(tab_group) do
        SetPaneActive(v, v == pane)
        SetAnimationTrigger(v.vars.button, _q_(v == pane, "Selected", "Unselected"))
      end
    end
    return obj
  end
  local ProcMouse = function()
    local pointerEventData = EventSystems.PointerEventData()
    local result = ListRaycastResult()
    while true do
      if ES == nil then
        return
      end
      result:Clear()
      if Input.GetMouseButtonDown(0) == true then
        local mousePosition = ES.vars.inputModule:GetMousePosition()
        pointerEventData.position = mousePosition
        UICanvas.graphicRaycaster:Raycast(pointerEventData, result)
        for v in Slua.iter(result) do
          return
        end
        for _, v in ipairs(Group) do
          v:Focus(false)
        end
      end
      coroutine.yield()
    end
  end
  function SetPaneActive(obj, active)
    obj.gameObject:SetActive(active)
    if active and obj.OnCreate then
      obj:OnCreate()
      obj.OnCreate = nil
    end
  end
  function init()
    task.Create(initProc)
  end
  function initProc()
    CurrentScene = SceneController.instance:GetScene("Root")
    UICanvas = FindObjectInScene(CurrentScene, "Canvas")
    UICanvas.gameObject:SetActive(false)
    UICamera = FindObjectInScene(CurrentScene, "Main Camera")
    UICamera.gameObject:SetActive(true)
    UICamera.camera.clearFlags = CameraClearFlags.SolidColor
    UICamera.camera.backgroundColor = Color(0, 0, 0, 1)
    GLOBAL.viewer4Record = false
    while root.initialized == false do
      coroutine.yield()
    end
    UICanvas.gameObject:SetActive(true)
    task.Create(ProcMouse)
    ES.vars.inputModule:EnableVirtualMode(false)
    SceneController.instance:SetStartScene("Root")
    PrefabStartItem = FindPrefabInScene(CurrentScene, "@Item")
    PrefabWin = FindPrefabInScene(CurrentScene, "@Window")
    PrefabItem = FindPrefabInScene(CurrentScene, "@DebugItem")
    DebugText = cmd.FindObjectInScene(CurrentScene, "DebugText")
    DebugText.gameObject:SetActive(false)
    error_handler.init()
    DebugMenu = FindObjectInScene(CurrentScene, "DebugMenu")
    Background = FindObjectInScene(CurrentScene, "DebugImage")
    Canvas = FindObjectInScene(CurrentScene, "Canvas")
    DebugMenu.gameObject:SetActive(true)
    Background.gameObject:SetActive(true)
    local WindowRoot = FindObjectInScene(CurrentScene, "TopWindows")
    DebugWindow = CreateTopMenu()
    Lot = {}
    for i = 1, 4 do
      Lot[i] = FindObjectInScene(CurrentScene, "Lot" .. i)
      Lot[i].gameObject:SetActive(false)
    end
    AnimationViewer = CreateAnimationViewer()
    ConsoleViewer = CreateConsoleViewer()
    FlagViewer = CreateFlagViewer()
    DebugViewer = CreateDebugViewer()
    SoundTest = CreateSoundTest()
    ScriptViewer = CreateScriptViewer()
    EventCall = CreateEventCall()
    BGViewer = CreateBGViewer()
    BustShotViewer = CreateBustShotViewer()
    Group = {
      ScriptViewer,
      AnimationViewer,
      ConsoleViewer,
      SoundTest,
      FlagViewer,
      DebugViewer,
      EventCall,
      BGViewer,
      BustShotViewer
    }
    for _, v in ipairs(Group) do
      v.vars.group = Group
    end
    local tab_group = {
      AnimationViewer,
      SoundTest,
      DebugViewer,
      FlagViewer,
      EventCall,
      BGViewer,
      BustShotViewer
    }
    AnimationViewerButton = CreateTabButton("Animation", AnimationViewer, tab_group)
    SoundTestButton = CreateTabButton("Music", SoundTest, tab_group)
    DebugViewerButton = CreateTabButton("Debug", DebugViewer, tab_group)
    FlagViewerButton = CreateTabButton("Flag", FlagViewer, tab_group)
    EventCallButton = CreateTabButton("Event", EventCall, tab_group)
    BGViewerButton = CreateTabButton("BG", BGViewer, tab_group)
    BustShotViewerButton = CreateTabButton("BustShot", BustShotViewer, tab_group)
    local hit = false
    for _, v in ipairs(tab_group) do
      local active = v.gameObject.name == savedata.data_debug.right.focusWindow
      hit = hit or active
      SetPaneActive(v, active)
      SetAnimationTrigger(v.vars.button, _q_(active, "Selected", "Unselected"))
      v:Focus(active)
    end
    if hit == false then
      SetPaneActive(tab_group[1], true)
      SetAnimationTrigger(tab_group[1].vars.button, "Selected")
      tab_group[1]:Focus(true)
    end
    function TabChange(dx)
      local no = 1
      for i, v in ipairs(tab_group) do
        if v.gameObject.activeSelf then
          no = i
          break
        end
      end
      no = circulate(no, #tab_group, dx)
      for i, v in ipairs(tab_group) do
        local active = i == no
        SetPaneActive(v, active)
        SetAnimationTrigger(v.vars.button, _q_(active, "Selected", "Unselected"))
        v:Focus(active)
      end
    end
    function SetBGViewer()
      BGViewerButton.trigger.onPointerClick()
      Settings.settings.debug.display = true
      Settings:Save()
      InGameMenu.gameObject:SetActive(Settings.settings.debug.display)
    end
    PrefabShortcutButton = FindPrefabInScene(CurrentScene, "@ShotcutButton")
    Shortcut = FindObjectInScene(CurrentScene, "Shortcut")
    local children = GetGameObjectPool(Shortcut)
    for i, v in ipairs(savedata.data_debug.Shortcuts) do
      local item = InstantiatePool(children, PrefabShortcutButton.gameObject, Shortcut)
      item.Text = FindObject(item, "Text")
      item.Text.text.text = string.format([[
%s
%s]], v.file, v.func)
      function item.trigger.onPointerClick()
        if v.kind == "investigation" then
          RootResources.startScript = v.file
          Utility.sceneFunc = v.func
          ShowDebugMenu(false)
          root.Fade:Black()
          root.ModeActivate("Investigation")
        end
        if v.kind == "somnium" then
          RootResources.startScript = v.file
          root.Fade:Black()
          ShowDebugMenu(false)
          root.ModeActivate("Somnium")
        end
      end
      item.gameObject:SetActive(true)
    end
    function ToggleDebugInfo(b)
      if b ~= nil then
        Settings.settings.debug.display = b
      else
        Settings.settings.debug.display = not Settings.settings.debug.display
      end
      Settings:Save()
      InGameMenu.gameObject:SetActive(Settings.settings.debug.display)
    end
    InGameMenu = FindObjectInScene(CurrentScene, "InGameMenu")
    InGameMenu.gameObject:SetActive(Settings.settings.debug.display)
    DebugInfoButton = FindObjectInScene(CurrentScene, "DebugInfoButton")
    EditorButton = FindObjectInScene(CurrentScene, "EditorButton")
    TopButtons = FindObjectInScene(CurrentScene, "TopButtons")
    TopButtons.gameObject:SetActive(true)
    if UNITY_EDITOR == 1 or UNITY_STANDALONE_WIN == 1 then
      function DebugInfoButton.trigger.onPointerClick()
        ToggleDebugInfo()
      end
      function EditorButton.trigger.onPointerClick()
        if currentLuaFile ~= nil then
          local file = currentLuaFile
          if string.sub(file, 1, 1) == "@" then
            file = string.gsub(file, "@.*/(.*)", "%1.lua")
          else
            file = file .. ".lua"
          end
          source_manager.EditorJump(file, currentLine)
        end
      end
    else
      DebugInfoButton.gameObject:SetActive(false)
      EditorButton.gameObject:SetActive(false)
    end
    if SceneManager.GetActiveScene().name == SCENE_NAME_ROOT then
      root.Fade:FadeIn(0.2)
      ShowDebugMenu(true)
    else
      ShowDebugMenu(false)
    end
    if UNITY_STANDALONE_WIN == 1 then
      local fileName = outputdir .. "/flag_change.txt"
      if System.IO.File.Exists(fileName) == true then
        System.IO.File.Delete(fileName)
      end
    end
    initialized = true
  end
  function ShowDebugMenu(b)
    DebugMenu.gameObject:SetActive(b)
    if b then
      UICamera.camera.clearFlags = CameraClearFlags.SolidColor
    else
      UICamera.camera.clearFlags = CameraClearFlags.Nothing
    end
  end
  function SetFlag(index, value)
    if UNITY_STANDALONE_WIN == 1 and flag[index] ~= value then
      local debugInfo = debug.getinfo(3)
      if debugInfo then
        local fn = debugInfo.source:match("[^@/]*$")
        local line = debugInfo.currentline
        if fn ~= "savedata" and fn ~= "somnium" and fn ~= "investigation" then
          Utility.WriteFlagChange(outputdir, string.format("%s:%d %s %s -> %s\n", fn, line, index, tostring(flag[index]), tostring(value)))
        end
      end
    end
    if FlagViewer then
      FlagViewer:Set(index, value)
    end
  end
  local tt = 0
  function update()
    if initialized then
      if Input.GetButtonDown(BUTTON_SUBMIT) and Input.GetButton(BUTTON_R1) and Input.GetButton(BUTTON_L1) then
        TopButtons.gameObject:SetActive(not TopButtons.gameObject.activeSelf)
      end
      if Input.GetButtonDown(BUTTON_CANCEL) and Input.GetButton(BUTTON_R1) and Input.GetButton(BUTTON_L1) then
        DEBUG:SetAgingMode(false)
      end
      if first then
        first = false
        DebugWindow:Debug()
      end
      if Input.GetButton(BUTTON_DPAD_DOWN) and Input.GetButtonDown(BUTTON_L2) then
        local b = Game.RootResources.debugCaptureMode
        Game.RootResources.debugCaptureMode = not b
        if investigation then
          investigation.Show(b)
        end
        if somnium then
          somnium.Show(b)
        end
        root.Show(b)
        TopButtons.gameObject:SetActive(b)
        if b == false then
          ToggleDebugInfo(b)
        end
      end
      if Input.GetButton(BUTTON_OPTIONS, true) then
        if Input.GetButtonDown(BUTTON_X, true) then
          ToggleDebugInfo()
        end
        if Input.GetButtonDown(BUTTON_Y, true) then
          root.Reset()
        end
        if Input.GetButtonDown(BUTTON_CANCEL, true) then
          root.ScriptReload()
        end
        if Input.GetButtonDown(BUTTON_L1, true) then
          TabChange(-1)
        end
        if Input.GetButtonDown(BUTTON_R1, true) then
          TabChange(1)
        end
      end
      if UNITY_STANDALONE_WIN == 1 and Input_.GetKeyDown(KeyCode.Alpha9) then
        if System.IO.Directory.Exists(outputdir) == false then
          System.IO.Directory.CreateDirectory(outputdir)
        end
        local all = ListString()
        do
          local flags = {}
          for i, v in pairs(flag) do
            if i ~= "_M" and i ~= "_NAME" and i ~= "_PACKAGE" and type(v) ~= "function" and type(v) ~= "table" then
              local f1, f2 = string.match(i, "(.*)(\239\188\187.*\239\188\189)")
              if f1 and f2 then
                if flags[f2] == nil then
                  flags[f2] = {}
                end
                table.insert(flags[f2], i)
              end
            end
          end
          local keys = {}
          for i, v in pairs(flags) do
            table.insert(keys, i)
          end
          table.sort(keys)
          for _, i in pairs(keys) do
            local v = flags[i]
            local content = {}
            content.name = i
            local children = {}
            for _, c in ipairs(v) do
              all:Add(string.format("%s = %s", c, flag[c]))
            end
          end
        end
        local dtNow = System.DateTime.Now
        local fileName = dtNow:ToString()
        fileName = string.gsub(fileName, "/", " ")
        fileName = string.gsub(fileName, ":", " ")
        fileName = outputdir .. "/flag snapshot " .. fileName .. ".txt"
        System.IO.File.WriteAllLines(fileName, all:ToArray())
      end
    end
    if update_flag then
      task.Update()
    end
    if tt == 0 or Time.realtimeSinceStartup - tt > 0.03333333333333333 then
    end
    tt = Time.realtimeSinceStartup
  end
end
