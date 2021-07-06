-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

--  qa+R % E{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

-- local nice = require("nice")
-- nice()

-- Variable definitions
modkey = "Mod4"
terminal = "st"

-- Table of layouts
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.corner.nw,
    awful.layout.suit.fair,
    awful.layout.suit.floating
}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

awful.screen.connect_for_each_screen(function(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout,
            wibox.widget.systray(),
            mytextclock,
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}


-- {{{ Autostart 

-- Wallpaper
awful.spawn.with_shell("feh --bg-scale ~/Pictures/Wallpapers/pape.jpg")
-- Gaps
beautiful.useless_gap = 7
-- Internet
awful.spawn.with_shell("nm-applet")
-- Compositor
awful.spawn.with_shell("picom")
-- Keyboard layouy (default Albanian (Plisi))
awful.spawn.with_shell("setxkbmap -layout al -variant plisi")
-- }}}


-- {{{ Key bindings

globalkeys = gears.table.join(

    --- App startup
    awful.key({ modkey, "Shift"   }, "f", function () awful.spawn("firefox") end),
    awful.key({ modkey, "Shift"   }, "t", function () awful.spawn("telegram-desktop") end),
    awful.key({ modkey, "Shift"   }, "v", function () awful.spawn("vscodium") end),
    awful.key({ modkey, "Shift"   }, "w", function () awful.spawn("whatsdesk") end),
    awful.key({ modkey, "Shift"   }, "s", function () awful.spawn("spotify") end),
    awful.key({ modkey, "Shift"   }, "x", function () awful.spawn("xournalpp") end),
    awful.key({ modkey, "Shift"   }, "n", function () awful.spawn("nautilus") end),
    awful.key({ modkey, "Shift"   }, "d", function () awful.spawn("discord") end),
    awful.key({ modkey, "Shift"   }, "b", function () awful.spawn("blueberry") end),
    awful.key({ modkey, "Shift"   }, "r", function () awful.spawn("st -e ranger") end),
    -- Keyboard layout shortcuts
    awful.key({ modkey,           }, "a", function () awful.spawn("setxkbmap -layout al -variant plisi") end),
    awful.key({ modkey,           }, "e", function () awful.spawn("setxkbmap -layout us,us") end),
    awful.key({ modkey,           }, "d", function () awful.spawn("setxkbmap -layout de") end),
    -- Wacom setup
    awful.key({ modkey,           }, "w", function () awful.spawn(".screenlayout/wacom.sh") end),
    -- Multi monitor layouts
    awful.key({ modkey, "Shift", "Control" }, "n", function () awful.spawn(".screenlayout/normal.sh") end, awesome.restart),
    awful.key({ modkey, "Shift", "Control" }, "h", function () awful.spawn(".screenlayout/home.sh") end, awesome.restart),
    awful.key({ modkey, "Shift", "Control" }, "b", function () awful.spawn(".screenlayout/bibliothek_1080.Zsh") end, awesome.restart),
    awful.key({ modkey, "Shift", "Control" }, "c", function () awful.spawn(".screenlayout/cootie.sh") end, awesome.restart),
    -- Lock screen with i3lock
    awful.key({ modkey,           }, "x", function () awful.spawn("i3lock-fancy-multimonitor -n -b=0x8") end),
    -- Volume controls
    awful.key({}, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer -D pulse sset Master 5%+", false) end),
    awful.key({}, "XF86AudioLowerVolume", function () awful.util.spawn("amixer -D pulse sset Master 5%-", false) end),
    awful.key({}, "XF86AudioMute", function () awful.util.spawn("amixer -D pulse sset Master toggle", false) end),
    -- Brightness
    awful.key({ }, "XF86MonBrightnessDown", function () awful.util.spawn("xbacklight -dec 15") end),
    awful.key({ }, "XF86MonBrightnessUp", function () awful.util.spawn("xbacklight -inc 15") end),
    -- help hotkey,
    awful.key({modkey}, "s",      hotkeys_popup.show_help),
    -- previous tag
    awful.key({modkey}, "Left",   awful.tag.viewprev),
    -- next tag
    awful.key({modkey}, "Right",  awful.tag.viewnext),
    -- last tag
    awful.key({modkey}, "Escape", awful.tag.history.restore),
    -- focus next window
    awful.key({modkey}, "j", function () awful.client.focus.byidx( 1) end),
    -- focus previous window
    awful.key({modkey}, "k", function () awful.client.focus.byidx(-1) end),
    -- swap with next window
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1) end),
    -- swap with previous window
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1) end),
    -- focus next screen
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    -- focus previous screen
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    -- jump to urgent client
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    -- go back
    awful.key({ modkey,           }, "Tab",
        function () awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),
    -- terminal
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end),
    -- restart
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    -- quit
    awful.key({ modkey, "Shift"   }, "z", awesome.quit),
    -- increase master width factor
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.01)          end),
    -- decrease master width factor
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.01)          end),
    -- increase number of master clinets
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end),
    -- decrease number of master clinets
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end),
    -- increase the number of columns
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end),
    -- decrease the number of columns
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end),
    -- select next
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end),
    -- select previous
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end),
    -- restore minimized
    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  if c then
                    c:emit_signal("request::activate", "key.unminimize", {raise = true})
                  end
              end,
              {description = "restore minimized", group = "client"}),
    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey,           }, "q",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)