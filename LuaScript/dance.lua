module("dance", package.seeall)
local mode = "practice"
local task
local exitFlag = false
local guide
local menuVisible = true
local loopFlag = true
local userInputEnable = true
local all, controller, CurrentScene, info
local visibles = {}
local lipdata
local deltaX = 0
local rightClick = false
local rightDoubleClick = false
local leftClick = false
local leftDoubleClick = false
local master_vol = 1
local charaRoot
local models = {}
local chara_names = {
  "md_c01_00","md_c01_00_som","md_c01_01","md_c01_02","md_c01_03","md_c01_04","md_c01_06","md_c01_10","md_c03_00","md_c03_00_som","md_c03_01","md_c03_02_car","md_c03_10","md_c03_11","md_c03_12","md_c04_00","md_c04_01","md_c04_02","md_c04_03","md_c05_00","md_c05_01","md_c05_02","md_c05_03","md_c05_10","md_c06_00","md_c06_01","md_c06_02","md_c06_10","md_c07_00","md_c07_00_som","md_c07_00_somin","md_c07_01","md_c07_02","md_c07_03","md_c07_04","md_c07_05","md_c07_10","md_c08_00","md_c08_01","md_c08_02","md_c09_00","md_c09_01","md_c10_00","md_c10_01","md_c10_02","md_c10_03","md_c11_00","md_c11_01","md_c12_00","md_c12_02","md_c14_00","md_c14_01","md_c14_02","md_c14_04","md_c14_05","md_c15_00","md_c15_01","md_c15_02","md_c15_03","md_c16_00","md_c16_01","md_c17_00","md_c17_01","md_c18_00","md_c19_00","md_c19_01","md_c51_00","md_c51_01","md_c52_00","md_c52_01","md_c53_00","md_c54_00","md_c55_00","md_c56_00","md_c57_00","md_c58_00","md_c58_01","md_c58_02","md_c58_10","md_c59_00","md_c59_01","md_c59_02","md_c60_00","md_c60_01","md_c60_02","md_c60_03","md_c61_00","md_c61_01","md_c61_02","md_c61_03","md_c62_00","md_c62_01","md_c62_02","md_c62_03","md_c63_00","md_c64_00","md_c65_00","md_c65_01","md_c66_00","md_c66_01","md_c67_00","md_c68_00","md_c68_01","md_c69_00","md_c70_00","md_c77_00","md_c78_00","md_c78_00_fade","md_c80_00","md_c80_01","md_c80_02","md_c81_10"
}
local function CreateLyrics(data)
  local obj = {}
  local lyricsBase = FindObjectInScene(CurrentScene, "Lyrics")
  local lyrics = FindObjectInScene(CurrentScene, "Text[lyrics]")
  local lt = 0
  local ldata = {}
  local lyricsVisible = true
  lyricsBase.gameObject:SetActive(lyricsVisible)
  for _, l in ipairs(Split(data.text, "\n")) do
    local d = {}
    l = string.gsub(l, "[[]", "<")
    l = string.gsub(l, "[]]", ">")
    local t1, t2, t3 = string.match(l, "^<(..):(..):(..)>")
    d.s = tonumber(t1) * 60 + tonumber(t2) + tonumber(t3) / 100
    local t1, t2, t3 = string.match(l, "<(..):(..):(..)>[^<]*$")
    d.e = tonumber(t1) * 60 + tonumber(t2) + tonumber(t3) / 100
    d.text = string.gsub(l, "<(..):(..):(..)>", "")
    local no = 0
    local glyph = {}
    local text = ""
    for t1, t2, t3, m in string.gmatch(l, "<(..):(..):(..)>([^<]+)") do
      local t = tonumber(t1) * 60 + tonumber(t2) + tonumber(t3) / 100
      local len = string.utf8len(m)
      table.insert(glyph, {
        t,
        no,
        len
      })
      text = text .. m
      no = no + len
    end
    d.text = text
    d.text = string.gsub(d.text, "[\n\r]", "")
    d.glyph = glyph
    table.insert(ldata, d)
  end
  lyrics.text.text = ""
  local lastlyrics
  function obj:Update(t)
    local no
    for i, d in ipairs(ldata) do
      if t >= d.s - 0.1 and t <= d.e + 1 then
        no = i
      end
    end
    lyrics.vertexScaler.speed = pitch == 1 and 8 or pitch == 0.5 and 4 or 16
    if no then
      if lastlyrics ~= no then
        lyrics.text.enabled = true
        lyrics.text.text = ldata[no].text
        lyrics.vertexScaler:Reset()
        lyrics.vertexScaler.size = 0.25
      end
      local v2
      for i, v in ipairs(ldata[no].glyph) do
        if lt < v[1] and t >= v[1] then
          for j = 0, v[3] - 1 do
            lyrics.vertexScaler:AnimeStart(v[2] + j)
          end
        end
        if t <= v[1] and v[1] < lt and v2 then
          for j = 0, v2[3] - 1 do
            lyrics.vertexScaler:AnimeStart(v2[2] + j)
          end
        end
        v2 = v
      end
    else
      lyrics.text.enabled = false
      lyrics.vertexScaler:Reset()
    end
    lastlyrics = no
    lt = t
  end
  function obj:KeyProc()
    if Input.GetButtonDown(BUTTON_SUBMIT) or Input_.GetKeyDown(KeyCode.Keypad4) then
      lyricsVisible = not lyricsVisible
      lyricsBase.gameObject:SetActive(lyricsVisible)
    end
  end
  return obj
end
local function CheckExitProc()
  if Input.GetButtonDown(BUTTON_OPTIONS, nil, true) or Input_.GetMouseButtonDown(2) then
    userInputEnable = false
    local function proc()
      if ConfirmationWindow:Start(sysmes.DANCE_DIALOG) then
        exitFlag = true
        loopFlag = false
      else
        userInputEnable = true
      end
    end
    task.Create(proc)
  end
end
local function MenuInit(menu)
  menuVisible = true
  SetAnimationState(menu, "Appear")
  guide:Disappear()
end
local function MenuProc(menu)
  if Input.GetButtonDown(BUTTON_LSTICK) or rightClick then
    menuVisible = not menuVisible
    if menuVisible then
      SetAnimationTrigger(menu, "Appear")
      guide:Disappear()
    else
      SetAnimationTrigger(menu, "Disappear")
      guide:Appear()
    end
  end
end
local function CreateGuide()
  local guide = FindObjectInScene(CurrentScene, "GuideButton")
  function guide:Appear()
    SetAnimationTrigger(guide, "Appear")
  end
  function guide:Disappear()
    if guideTask ~= nil then
      guideTask:Stop()
      guideTask = nil
    end
    SetAnimationTrigger(guide, "Disappear")
  end
  return guide
end
local function Practice()
  root.Fade:Black()
  local obj = FindObjectInScene(CurrentScene, "DanceController")
  local canvas = FindObjectInScene(CurrentScene, "UICanvas")
  canvas.gameObject:SetActive(true)
  local menu1 = FindObjectInScene(CurrentScene, "Practice")
  local lastScenes
  menu1.gameObject:SetActive(true)
  MenuInit(menu1)
  local menu2 = FindObjectInScene(CurrentScene, "GrandFinale")
  menu2.gameObject:SetActive(false)
  userInputEnable = true
  all.gameObject:SetActive(true)
  local camera = FindObjectInScene(CurrentScene, "Camera")
  local luaCameraController = AddComponent(camera, LuaCameraController)
  camera.danceMirror.enabled = false
  local lyrics = CreateLyrics(info.lyrics)
  local cameraControl = FindObjectInScene(CurrentScene, "Camera01")
  cameraControl.gameObject:SetActive(false)
  local copySkeletalAnimation = obj.gameObject:AddComponent(Game.CopySkeletalAnimation)
  local no = 1
  local loading = false
  local charaAll_mat_set
  local function LoadProc()
    root.Loading:Start()
    BG:WaitAll()
    Resources.UnloadUnusedAssets()
    local info = DANCD_BG_PROP[GLOBAL.Dance.bgindex]
    local sceneName = info.name
    BG:Load2(sceneName)
    while BG:IsLoading() do
      coroutine.yield()
    end
    coroutine.yield()
    local bg = BG:GetBG(sceneName)
    luaCameraController:Clear()
    local c = FindObjectInScene(bg.scenes, "Chara")
    if c then
      c.gameObject:SetActive(false)
    end
    local c = FindObjectInScene(bg.scenes, info.camera)
    if c and c.postProcessingBehaviour then
      camera.postProcessingBehaviour.profile = c.postProcessingBehaviour.profile
    else
      camera.postProcessingBehaviour.profile = nil
    end
    FocusGameObject(camera.gameObject)
    if lastScenes then
      for _, s in ipairs(lastScenes) do
        for camera in Slua.iter(bg.sceneSet.cameras) do
          camera.enabled = false
        end
        s:SetActive(false)
      end
    end
    for _, s in ipairs(bg.scenes) do
      for camera in Slua.iter(bg.sceneSet.cameras) do
        camera.enabled = false
      end
      s:SetActive(true)
      s.rootNode.transform.localPosition = info.pos
      s.rootNode.transform.localEulerAngles = info.rot
      luaCameraController:AddScene(s)
    end
    lastScenes = bg.scenes
    luaCameraController:AddScene(CurrentScene)
    local components = GetComponentsInScene(bg.scenes, CharaAll_mat_set)
    if 0 < #components then
      charaAll_mat_set = components[1]
      charaAll_mat_set:Set(charaRoot.gameObject)
    else
      charaAll_mat_set = nil
    end
    loading = false
    local j = GLOBAL.Dance.bgindex
    for i = 1, #DANCD_BG_PROP do
      local d = math.min(math.abs(i - j), math.abs(i - j - #DANCD_BG_PROP))
      if 1 < d then
        local info = DANCD_BG_PROP[i]
        BG:UnloadReal(nil, info.name)
      end
    end
    root.Loading:End()
  end
  local cameraZoom = 0
  local cameraZoomTarget = 0
  local cameraRotateTarget = 0
  local cameraRotate = Quaternion.Euler(-10, 0, 0)
  local function CameraControl()
    local dx = 0
    if userInputEnable then
      dx = Input.GetAxis(AXIS_LSTICK_HORIZONTAL_STICK)
      if dx == 0 then
        dx = Input.GetAxis(AXIS_LSTICK_VERTICAL_KEY)
      end
      if dx == 0 then
        dx = Input.GetAxis(AXIS_MOUSE_WHEEL) * 100
      end
    end
    cameraZoomTarget = math.min(math.max(cameraZoomTarget + dx * Time.deltaTime, 0), 1)
    cameraZoom = cameraZoom + (cameraZoomTarget - cameraZoom) * math.min(Time.deltaTime * 10, 1)
    cameraControl.transform.localPosition = Vector3.Lerp(Vector3(0, 0.72, 3.5), Vector3(0, 1.4, 1.2), cameraZoom)
    if userInputEnable then
      if Input.GetButtonDown(BUTTON_RSTICK_LEFT) or Input_.GetKeyDown(KeyCode.A) then
        cameraRotateTarget = cameraRotateTarget + 90
      elseif Input.GetButtonDown(BUTTON_RSTICK_RIGHT) or Input_.GetKeyDown(KeyCode.D) then
        cameraRotateTarget = cameraRotateTarget - 90
      elseif 100 < deltaX then
        cameraRotateTarget = cameraRotateTarget + 90
        deltaX = 0
      elseif deltaX < -100 then
        cameraRotateTarget = cameraRotateTarget - 90
        deltaX = 0
      end
      while 180 < cameraRotateTarget do
        cameraRotateTarget = cameraRotateTarget - 360
      end
      while cameraRotateTarget < -180 do
        cameraRotateTarget = cameraRotateTarget + 360
      end
    end
    cameraRotate = Quaternion.Slerp(cameraRotate, Quaternion.Euler(-10, cameraRotateTarget, 0), math.min(Time.deltaTime * 10, 1))
    cameraControl.transform.parent.localRotation = cameraRotate
  end
  loading = true
  task.Create(LoadProc)
  while loading do
    coroutine.yield()
  end
  cameraControl.gameObject:SetActive(true)
  local source = SE:PlayClip(info.audioClip, 0)
  source:Hold()
  local audio = source:GetComponent()
  local source = SE:PlayClip(info.audioClipFast, 0)
  source:Hold()
  local audioFast = source:GetComponent()
  local source = SE:PlayClip(info.audioClipSlow, 0)
  source:Hold()
  local audioSlow = source:GetComponent()
  local source = SE:PlayClip(info.audioClipFastReverse, 0)
  source:Hold()
  local audioFastReverse = source:GetComponent()
  local length = info.audioClipFastReverse.length
  local vol = 1
  local lt = 0
  local pause = false
  local pitch = 0
  local t = 0
  coroutine.yield()
  SetAnimationState(guide, "Disappear")
  local function CheckLoop(audio)
    if audio.isPlaying == false and audio.time == 0 and pause == false then
      audio.time = 0
      audio:Play()
      if menuVisible == false then
        guide:Appear()
      end
    end
  end
  local function Show(model, b)
    if b == true then
      for c in Slua.iter(model.gameObject:GetComponentsInChildren(RogoDigital.Lipsync.LipSync)) do
        c.enabled = false
      end
    end
    for renderer in Slua.iter(model.gameObject:GetComponentsInChildren(Renderer)) do
      if visibles[renderer] == nil then
        visibles[renderer] = renderer.gameObject.layer
      end
      if b == false then
        renderer.gameObject.layer = 31
      else
        renderer.gameObject.layer = visibles[renderer]
      end
    end
  end
  repeat
    do break end -- pseudo-goto
    for i, name in ipairs(chara_names) do
      local model = FindObjectInScene(CurrentScene, name)
      if model then
        local timelineAsset = ScriptableObject.CreateInstance(Timeline.TimelineAsset)
        local track = timelineAsset:CreateTrack(Timeline.AnimationTrack, nil, "dance")
        track:CreateClip(controller.danceController.animationClip)
        local playable = AddComponent(model, Playables.PlayableDirector)
        playable.playableAsset = timelineAsset
        playable:SetGenericBinding(track, model.gameObject)
        playable:Play()
        Show(model, no == i)
        model.transform.parent.localPosition = Vector3(0, 0, 0)
      end
    end
  until true
  local chara_task
  local function CharaLoadProc(no)
    local name = chara_names[no]
    local model
    if models[name] == nil then
      local assetBundleName = "chara_" .. name
      local assetName = name .. "_fix"
      if name == "md_c70_00" then
        assetName = "md_c70_00_fix_dnc"
      end
      model = LoadGameObject2(assetBundleName, assetName, false)
      model = SetObject(GameObject.Instantiate(model, charaRoot.transform))
      model.vars.renderers = model.gameObject:GetComponentsInChildren(Renderer)
      for renderer in Slua.iter(model.vars.renderers) do
        visibles[renderer] = renderer.gameObject.layer
        renderer.gameObject.layer = 31
      end
      model.animator.cullingMode = AnimatorCullingMode.AlwaysAnimate
      local timelineAsset = controller.danceController.timelineAsset
      local track = timelineAsset:GetRootTrack(0)
      local playable = AddComponent(model, Playables.PlayableDirector)
      playable.playableAsset = timelineAsset
      playable:SetGenericBinding(track, model.gameObject)
      playable:Play()
      model.vars.renderers = model.gameObject:GetComponentsInChildren(Renderer)
      model.vars.no = no
      model.vars.visible = false
      models[name] = model
      if model.lipSync then
        model.lipSync.enabled = false
      end
      if model.eyeController then
        model.eyeController.enabled = false
      end
      if model.eyeMove then
        model.eyeMove.enabled = false
      end
      model.gameObject:SetActive(true)
      if charaAll_mat_set then
        charaAll_mat_set:Set(model.gameObject)
      end
    else
      model = models[name]
    end
    for n, model in pairs(models) do
      local b = n == name
      if b ~= model.vars.visible then
        for renderer in Slua.iter(model.vars.renderers) do
          if b then
            renderer.gameObject.layer = visibles[renderer]
          else
            renderer.gameObject.layer = 31
          end
        end
        model.animator.cullingMode = AnimatorCullingMode.AlwaysAnimate
        model.vars.visible = b
      end
    end
    for _, model in pairs(models) do
      local j = model.vars.no
      local d = math.min(math.abs(no - j), math.abs(no - j - #DANCD_BG_PROP))
      if 2 <= d then
        model.vars.playing = false
        model.playableDirector:Pause()
        model.gameObject:SetActive(false)
      else
        model.vars.playing = true
        model.playableDirector:Play()
        model.gameObject:SetActive(true)
      end
    end
    chara_task = nil
  end
  CharaLoadProc(no)
  root.Fade:FadeIn(1)
  audio.time = 0
  audio.volume = 1 * master_vol
  loopFlag = true
  while loopFlag do
    if userInputEnable then
      if chara_task == nil then
        local lastno = no
        if Input.GetButtonDown(BUTTON_DANCE_L2) then
          no = no - 1
          if no <= 0 then
            no = #chara_names
          end
        elseif Input.GetButtonDown(BUTTON_DANCE_R2) then
          no = no + 1
          if no > #chara_names then
            no = 1
          end
        end
        if no ~= lastno then
          chara_task = task.Create(CharaLoadProc, no)
          lastno = no
        end
      end
      if loading == false then
        local old = GLOBAL.Dance.bgindex
        if Input.GetButtonDown(BUTTON_DANCE_L1) or Input_.GetKeyDown(KeyCode.Alpha1) then
          GLOBAL.Dance.bgindex = GLOBAL.Dance.bgindex - 1
          if 0 >= GLOBAL.Dance.bgindex then
            GLOBAL.Dance.bgindex = #DANCD_BG_PROP
          end
        elseif Input.GetButtonDown(BUTTON_DANCE_R1) or Input_.GetKeyDown(KeyCode.Alpha2) then
          GLOBAL.Dance.bgindex = GLOBAL.Dance.bgindex + 1
          if GLOBAL.Dance.bgindex > #DANCD_BG_PROP then
            GLOBAL.Dance.bgindex = 1
          end
        end
        if old ~= GLOBAL.Dance.bgindex then
          loading = true
          task.Create(LoadProc)
        end
      end
      if Input.GetButtonDown(BUTTON_Y) then
        audio.time = 0
        lt = 0
      end
      MenuProc(menu1)
      lyrics:KeyProc()
      if Input.GetButtonDown(BUTTON_CANCEL) or leftClick then
        pause = not pause
        if pause then
          audio:Pause()
          audioFast:Pause()
          audioSlow:Pause()
          audioFastReverse:Pause()
          for _, model in pairs(models) do
            model.playableDirector:Pause()
          end
        else
          audio:UnPause()
          audioFast:UnPause()
          audioSlow:UnPause()
          audioFastReverse:UnPause()
          for _, model in pairs(models) do
            model.playableDirector:Play()
          end
        end
      end
      CheckExitProc()
      if Input.GetButtonDown(BUTTON_RETRY, nil, true) or leftDoubleClick then
        loopFlag = false
        mode = "finale"
      end
      if Input.GetButtonDown(BUTTON_X) then
        camera.danceMirror.enabled = not camera.danceMirror.enabled
      end
      if Input.GetButtonDown(BUTTON_RSTICK) or rightDoubleClick then
        collectgarbage("collect")
        cameraZoomTarget = 0
        cameraRotateTarget = 0
      end
      if pause == false then
        if Input.GetButtonDown(BUTTON_DPAD_RIGHT_DANCE) then
          if pitch ~= 5 then
            audio.volume = 0
            audioFast.volume = 1 * master_vol
            audioSlow.volume = 0 * master_vol
            audioFastReverse.volume = 0 * master_vol
            audioFast.time = t / 5
            audioFast:Play()
            pitch = 5
          else
            pitch = 0
          end
        elseif Input.GetButtonDown(BUTTON_DPAD_LEFT_DANCE) then
          if pitch ~= -5 then
            audio.volume = 0 * master_vol
            audioFast.volume = 0 * master_vol
            audioSlow.volume = 0 * master_vol
            audioFastReverse.volume = 1 * master_vol
            audioFastReverse.time = math.max(length - t / 5, 0)
            audioFastReverse:Play()
            pitch = -5
          else
            pitch = 0
          end
        elseif Input.GetButtonDown(BUTTON_DPAD_DOWN_DANCE) then
          if pitch ~= 0.5 then
            audio.volume = 0 * master_vol
            audioFast.volume = 0 * master_vol
            audioSlow.volume = 1 * master_vol
            audioFastReverse.volume = 0 * master_vol
            audioSlow.time = t * 2
            audioSlow:Play()
            pitch = 0.5
          else
            pitch = 0
          end
        elseif Input.GetButtonDown(BUTTON_DPAD_UP_DANCE) and pitch ~= 0 then
          pitch = 0
        end
        if pitch == 0 then
          audio.volume = 1 * master_vol
          audioFast.volume = 0 * master_vol
          audioSlow.volume = 0 * master_vol
          audioFastReverse.volume = 0 * master_vol
          audio.time = t
          audio:Play()
          pitch = 1
        end
      end
    end
    CameraControl()
    if pause == false then
      if pitch == 1 then
        CheckLoop(audio)
        t = audio.time
      elseif pitch == 5 then
        CheckLoop(audioFast)
        t = audioFast.time * 5
      elseif pitch == -5 then
        if audioFastReverse.isPlaying then
          t = math.max((length - audioFastReverse.time) * 5, 0)
        else
          t = 0
        end
      elseif pitch == 0.5 then
        CheckLoop(audioSlow)
        t = audioSlow.time * 0.5
      end
    end
    lyrics:Update(t)
    for _, model in pairs(models) do
      if model.vars.playing == true then
        model.playableDirector.time = 3.0833 + t
      end
    end
    coroutine.yield()
  end
  SE:StopClip(info.audioClip, 0.5)
  SE:StopClip(info.audioClipFast, 0.5)
  SE:StopClip(info.audioClipSlow, 0.5)
  SE:StopClip(info.audioClipFastReverse, 0.5)
end
local function Finale()
  local lyrics = CreateLyrics(info.lyricsFinale)
  root.Fade:Black()
  userInputEnable = true
  local pause = false
  local menu1 = FindObjectInScene(CurrentScene, "Practice")
  menu1.gameObject:SetActive(false)
  local menu2 = FindObjectInScene(CurrentScene, "GrandFinale")
  menu2.gameObject:SetActive(true)
  MenuInit(menu2)
  all.gameObject:SetActive(false)
  local video = CreateVideoPlayer(CurrentScene, task, 2)
  local language = "jp"
  if RootResources.systemLanguage == "us" then
    language = "en"
  end
  video:SetVolume(master_vol)
  video:Play("Video_Dance_" .. language, false, false, true)
  root.Fade:FadeIn(1)
  loopFlag = true
  local pause = false
  while loopFlag do
    if userInputEnable then
      if Input.GetButtonDown(BUTTON_RETRY, nil, true) or leftDoubleClick then
        loopFlag = false
        mode = "practice"
      end
      if Input.GetButtonDown(BUTTON_CANCEL) or leftClick then
        pause = not pause
        video:Pause(pause)
      end
      if Input.GetButtonDown(BUTTON_MAP) then
        pause = false
        video:Stop()
        video:Play("Video_Dance_" .. language, false, false, true)
      end
      MenuProc(menu2)
      CheckExitProc()
      lyrics:KeyProc()
    end
    if pause == false then
      lyrics:Update(video:GetTime() - 4.65)
    end
    coroutine.yield()
  end
  video:Stop()
end
function init()
  GLOBAL.disableLoadingAnimation = false
  root.Fade.Black()
  CurrentScene = SceneController.instance:GetScene("Dance")
  task = CreateTask()
  LoadManager.Open()
  LoadManager.Close()
  master_vol = savedata.system_data.options.volume_bgm / 10
  charaRoot = FindObjectInScene(CurrentScene, "Chara")
  DestroyAllChildren(charaRoot.gameObject)
  local function proc()
    controller = FindObjectInScene(CurrentScene, "DanceController")
    if RootResources.systemLanguage == "us" then
      info = controller.danceController.en
    elseif RootResources.systemLanguage == "zh_tw" then
      info = controller.danceController.zh_tw
    else
      info = controller.danceController.jp
    end
    guide = CreateGuide()
    all = FindObjectInScene(CurrentScene, "ALL_pos")
    while exitFlag == false do
      if mode == "practice" then
        Practice()
      elseif mode == "finale" then
        Finale()
      end
      root.Fade:FadeOutWait(1)
    end
    root.ModeActivate("Title", true)
  end
  task.Create(proc)
end
local function CreateDoubleClick(no)
  local last = false
  local obj = {}
  local lastPos = Input_.mousePosition
  local doubleClickPosition = Vector2(0, 0)
  local doubleClickPositionP = Vector2(0, 0)
  local doubleClickTime = 0
  local rigitMouseButtonDown0 = false
  function obj:Update()
    local click = false
    local doubleClick = false
    local down = Input_.GetMouseButton(no)
    rigitMouseButtonDown = false
    if down == true and last == false then
      doubleClickPositionP = Input_.mousePosition
    end
    if down == false and last == true then
      if Time.realtimeSinceStartup - doubleClickTime < 0.8 and (doubleClickPosition - Input_.mousePosition).magnitude < 10 then
        rigitMouseButtonDown0 = true
        doubleClickTime0 = Time.realtimeSinceStartup
        doubleClick = true
        rigitMouseButtonDown0 = false
      else
        rigitMouseButtonDown0 = true
      end
      doubleClickPosition = Input_.mousePosition
      doubleClickTime = Time.realtimeSinceStartup
    end
    if down == false and rigitMouseButtonDown0 and Time.realtimeSinceStartup - doubleClickTime > 0.2 and (doubleClickPositionP - Input_.mousePosition).magnitude < 10 then
      rigitMouseButtonDown0 = false
      click = true
      doubleClickTime = 0
    end
    if no == 1 then
      if down then
        deltaX = deltaX + (Input_.mousePosition.x - lastPos.x)
      else
        deltaX = 0
      end
    end
    lastPos = Input_.mousePosition
    last = down
    return click, doubleClick
  end
  return obj
end
local L = CreateDoubleClick(0)
local R = CreateDoubleClick(1)
function update()
  leftClick, leftDoubleClick = L:Update()
  rightClick, rightDoubleClick = R:Update()
  task.Update()
  return true
end
