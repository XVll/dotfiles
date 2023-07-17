local hyper = hs.hotkey.modal.new({}, nil)

hyper.pressed = function()
  hyper:enter()
end
hyper.released = function()
  hyper:exit()
end

hs.hotkey.bind({}, "F18", hyper.pressed, hyper.released)

hyper.bindFn = function(mods, key, fn)
  if type(fn) ~= "function" then
    print("Not a function: " .. key)
  end
  hyper:bind(mods, key, fn)
end

return hyper