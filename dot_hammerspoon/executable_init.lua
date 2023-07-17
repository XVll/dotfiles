local window = require('hs.window')
local screen = require('hs.screen')
local grid = require('hs.grid')
local hotkey = require('hs.hotkey')
local spaces = require('hs.spaces')
local hyperKey = require('hyper-key')
local appKey = require('app-key')

hs.window.animationDuration = 0.2
hs.loadSpoon('SpoonInstall')
spoon.SpoonInstall:andUse("EmmyLua")
spoon.SpoonInstall:andUse('ReloadConfiguration', { start = true })
spoon.SpoonInstall:andUse("RoundedCorners", { start = true, config = { radius = 8 } })
-- Window
grid.setMargins('15,15')
grid.setGrid('6x2')
local positions = {
    ["Space"] = { x = 0, y = 0, w = 6, h = 2 },
    ["E"] = { x = 0, y = 0, w = 6, h = 1 },
    ["C"] = { x = 0, y = 1, w = 6, h = 1 },
    ["S"] = { x = 0, y = 0, w = 3, h = 2 },
    ["F"] = { x = 3, y = 0, w = 3, h = 2 },
    ["A"] = { x = 0, y = 0, w = 2, h = 2 },
    ["D"] = { x = 2, y = 0, w = 2, h = 2 },
    ["G"] = { x = 4, y = 0, w = 2, h = 2 },
    ["W"] = { x = 0, y = 0, w = 3, h = 1 },
    ["X"] = { x = 0, y = 1, w = 3, h = 1 },
    ["R"] = { x = 3, y = 0, w = 3, h = 1 },
    ["V"] = { x = 3, y = 1, w = 3, h = 1 },
}

local swapWindows = function(targetPos)
    local currentWindow = window.focusedWindow()
    for _, win in pairs(window.orderedWindows()) do
        local targetWindowPos = grid.get(win)

        if targetWindowPos.x == targetPos.x and targetWindowPos.y == targetPos.y and targetWindowPos.w == targetPos.w and targetWindowPos.h == targetPos.h then
            -- Move window at target position to current window position
            grid.set(win, grid.get(currentWindow), screen)
            break
        end
    end
    -- Move current window to target position
    grid.set(currentWindow, targetPos, screen)
end

for key, pos in pairs(positions) do
    hyperKey.bindFn({}, key, function() swapWindows(pos) end)
end
--for key, pos in pairs(positions) do
--    hyperKey.bindFn({}, key, function()
--        local f_w = window.focusedWindow()
--        grid.set(f_w, pos, f_w:screen())
--    end)
--end
-- Spaces
function moveWindowToSpace(space)
    local win = window.focusedWindow()
    local uuid = win:screen():getUUID()
    local spaceID = spaces.allSpaces()[uuid][space]
    print(spaces.allSpaces())
    print(spaceID)
    spaces.moveWindowToSpace(win, spaceID)
    spaces.gotoSpace(spaceID)
end

for key, space in pairs({ ["1"] = 1, ["2"] = 2, ["3"] = 3, ["4"] = 4, ["5"] = 5, ["6"] = 6, ["7"] = 7, ["8"] = 8, ["9"] = 9, ["0"] = 10 }) 
do
    hotkey.bind({ "shift", "alt", "cmd", "ctrl" }, key, function()
        moveWindowToSpace(space)
    end)
end

-- Focus
hotkey.bind({ "shift", "alt", "cmd", "ctrl" }, 's', function() window.focusedWindow():focusWindowWest() end)
hotkey.bind({ "shift", "alt", "cmd", "ctrl" }, 'd', function() window.focusedWindow():focusWindowSouth() end)
hotkey.bind({ "shift", "alt", "cmd", "ctrl" }, 'e', function() window.focusedWindow():focusWindowNorth() end)
hotkey.bind({ "shift", "alt", "cmd", "ctrl" }, 'f', function() window.focusedWindow():focusWindowEast() end)
-- Display
hyperKey.bindFn({ "shift", "alt", "cmd", "ctrl" }, 'n', function() local win = window.focusedWindow() local next = win:screen():next() win:moveToScreen(next) end)
hyperKey.bindFn({ "shift", "alt", "cmd", "ctrl" }, 'p', function() local win = window.focusedWindow() local prev = win:screen():previous() win:moveToScreen(prev) end)

-- Apps (Safari, Iterm, VSCode, Chrome, Music, Finder, Notion, Transmission, Rider, IINA)
appKey.bindApp({}, 'y', function() hs.execute('qlmanage -p ~/.assets/cheat_sheet.pdf') end)
appKey.bindApp({}, 'c', 'Google Chrome')
appKey.bindApp({}, 's', 'Safari')
appKey.bindApp({}, 't', 'iTerm')
appKey.bindApp({}, 'v', 'Visual Studio Code')
appKey.bindApp({}, 'm', 'Music')
appKey.bindApp({}, 'f', 'Finder')
appKey.bindApp({}, 'n', 'Notion')
appKey.bindApp({}, 'r', 'Rider')
appKey.bindApp({}, 'i', 'IINA')
appKey.bindApp({}, 'e', 'Spark')
appKey.bindApp({}, 'g', 'Telegram')

