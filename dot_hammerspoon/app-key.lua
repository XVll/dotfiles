local appKey = hs.hotkey.modal.new({}, nil)

appKey.pressed = function()
    appKey:enter()
end
appKey.released = function()
    appKey:exit()
end

hs.hotkey.bind({}, "F17", appKey.pressed, appKey.released)

appKey.bindApp = function(mods, key, app)
  local fn = function()
    hs.application.launchOrFocus(app)
  end
  if type(app) == "function" then
    fn = app
  end
  appKey:bind(mods, key, fn)
end

return appKey