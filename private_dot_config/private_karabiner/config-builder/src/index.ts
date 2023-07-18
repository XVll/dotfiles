import {
    duoLayer,
    hyperLayer,
    ifVar,
    layer,
    map,
    NumberKeyValue,
    rule,
    simlayer,
    SimultaneousOptions,
    withMapper,
    writeToProfile,
} from 'karabiner.ts'

let simOptions: SimultaneousOptions = {
    detect_key_down_uninterruptedly: true,
    key_down_order: 'insensitive',
    key_up_order: 'insensitive',
    key_up_when: 'any',
};

// (Profile Name : --dry-run print the config json into console)
// ['⌘', '⌥', '⌃', '⇧']  ['←', '→', '↑', '↓', '␣', '⏎', '⇥', '⎋', '⌫', '⌦', '⇪']
writeToProfile('Default', [
    simlayer(',', 'hammer-fn-mode', 100).description("Hammer Fn Mode").options(simOptions).manipulators([ map(".").to("f18"), ]),

    rule("Hyper + HJKL -> Arrow Keys").manipulators([
        map("h",'Hyper').to("←"),
        map("j",'Hyper').to("↓"),
        map("k",'Hyper').to("↑"),
        map("l",'Hyper').to("→"),
    ]),
    rule('Hammer App Mode').manipulators([map('>⌥').to('f17')]),
    rule('Slash -> Hyper').manipulators([map('/').toHyper().toIfAlone('/'),]),
    rule('Tilde -> Hyper').manipulators([map('`', 'optionalAny').toHyper(),]),

    rule('Caps Lock -> Control + Escape').manipulators([map('⇪', '??').to('left_control').toIfAlone('⎋'),]),
    rule('Spotlight -> Raycast').manipulators([map('␣', '⌘').to('␣', '⌥')]),
    rule('Non us backslash -> Tilde').manipulators([map('non_us_backslash', 'optionalAny').to('`'),])

], {
    "basic.to_if_alone_timeout_milliseconds": 1000,
    "basic.to_if_held_down_threshold_milliseconds": 500,
    "basic.to_delayed_action_delay_milliseconds": 500,
    "basic.simultaneous_threshold_milliseconds": 50,
    "mouse_motion_to_scroll.speed": 100
})

