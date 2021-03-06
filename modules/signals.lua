-- This Module is required by taglist widget
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local awesome = awesome
local client = client

-- Toggle titlebar on or off depending on s. Creates titlebar if it doesn't exist
local function setTitlebar(c, s)
    if s then
        awful.titlebar.show(c)
    else
        awful.titlebar.hide(c)
    end
end

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
    if awful.layout.suit.floating or c.floating then
        awful.placement.centered(c)
    end
    setTitlebar(c, c.first_tag.layout == awful.layout.suit.floating)
end)

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
            {
                awful.titlebar.widget.iconwidget(c),
                left = dpi(6),
                top = dpi(4),
                bottom = dpi(4),
                widget = wibox.container.margin
            },
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c),
                font = beautiful.font_mono,
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            {
                {
                    awful.titlebar.widget.minimizebutton(c),
                    forced_height = dpi(16),
                    forced_width = dpi(16),
                    widget = wibox.container.place
                },
                right = dpi(6),
                top = dpi(4),
                bottom = dpi(4),
                widget = wibox.container.margin
            },
            {
                {
                    awful.titlebar.widget.maximizedbutton(c),
                    forced_height = dpi(16),
                    forced_width = dpi(16),
                    widget = wibox.container.place
                },
                right = dpi(6),
                top = dpi(4),
                bottom = dpi(4),

                widget = wibox.container.margin
            },
            {
                {
                    awful.titlebar.widget.closebutton (c),
                    forced_height = dpi(16),
                    forced_width = dpi(16),
                    widget = wibox.container.place
                },
                right = dpi(6),
                top = dpi(4),
                bottom = dpi(4),
                widget = wibox.container.margin
            },
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

screen.connect_signal("arrange", function (s)
    local layout = s.selected_tag.layout.name
    for _, c in pairs(s.clients) do
		if c.maximized then
            c.border_width = 0
    		awful.spawn("xprop -id " .. c.window .. " -f _COMPTON_SHADOW 32c -set _COMPTON_SHADOW 0", false)
        elseif layout == 'floating' then
            c.border_width = 0
   			awful.spawn("xprop -id " .. c.window .. " -f _COMPTON_SHADOW 32c -set _COMPTON_SHADOW 1", false)
        else
    		awful.spawn("xprop -id " .. c.window .. " -f _COMPTON_SHADOW 32c -set _COMPTON_SHADOW 0", false)
            c.border_width = beautiful.border_width
        end
    end
end)

-- Show titlebars on tags with the floating layout
tag.connect_signal("property::layout", function(t)
    for _, c in pairs(t:clients()) do
        if t.layout == awful.layout.suit.floating then
            setTitlebar(c, true)
        else
            setTitlebar(c, false)
        end
    end
end)


--Toggle titlebar on floating status change
-- client.connect_signal("property::floating", function(c)
--     setTitlebar(c, c.floating)
-- end)
