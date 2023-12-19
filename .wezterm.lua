local wezterm = require("wezterm")
local act = wezterm.action
local config = {}

local gradients = {
	blue_and_red = {
		-- Can be "Vertical" or "Horizontal".  Specifies the direction
		-- in which the color gradient varies.  The default is "Horizontal",
		-- with the gradient going from left-to-right.
		-- Linear and Radial gradients are also supported; see the other
		-- examples below
		orientation = {
			Linear = {
				angle = -420.69,
			},
			-- Radial = {
			-- cx = 0.95,
			-- cy = 0.75,
			-- radius = 1.25,
			-- },
		},

		-- Specifies the set of colors that are interpolated in the gradient.
		-- Accepts CSS style color specs, from named colors, through rgb
		-- strings and more
		colors = {
			"#990000",
			"#0000FF",
			"#000099",
			"#220099",
			"#440099",
			"#660099",
			"#660099",
			"#440099",
			"#220099",
			"#000099",
			"#0000FF",
			"#990000",
		},

		-- Instead of specifying `colors`, you can use one of a number of
		-- predefined, preset gradients.
		-- A list of presets is shown in a section below.
		-- preset = "Greys",

		-- Specifies the interpolation style to be used.
		-- "Linear", "Basis" and "CatmullRom" as supported.
		-- The default is "Linear".
		interpolation = "Basis",

		-- How the colors are blended in the gradient.
		-- "Rgb", "LinearRgb", "Hsv" and "Oklab" are supported.
		-- The default is "Rgb".
		blend = "Rgb",

		-- To avoid vertical color banding for horizontal gradients, the
		-- gradient position is randomly shifted by up to the `noise` value
		-- for each pixel.
		-- Smaller values, or 0, will make bands more prominent.
		-- The default value is 64 which gives decent looking results
		-- on a retina macbook pro display.
		noise = 0,

		-- By default, the gradient smoothly transitions between the colors.
		-- You can adjust the sharpness by specifying the segment_size and
		-- segment_smoothness parameters.
		-- segment_size configures how many segments are present.
		-- segment_smoothness is how hard the edge is; 0.0 is a hard edge,
		-- 1.0 is a soft edge.

		-- segment_size = 10,
		-- segment_smoothness = 1.0,
	},
	chrome_and_blue = {
		orientation = {
			Linear = {
				angle = -420.69,
			},
		},

		colors = {
			"#160c63",
			"#0e0b29",
			"#414f45",
			-- chrome/aluminum colors
			"#626569",
			"#6E7173",
			"#494B4D",
			"#838F9C",
			"#6E7173",
		},

		interpolation = "Basis",

		blend = "Rgb",

		noise = 0,
		-- segment_size = 1,
		-- segment_smoothness = 1.0,
	},
}
config.enable_tab_bar = false
config.font = wezterm.font("JetBrains Mono", { weight = "ExtraBold" })
-- config.font = wezterm.font("Nerd Font Mono", { weight = "Regular" })
-- config.font = wezterm.font("Nerd Font Mono", { weight = "Regular" })
-- config.font = wezterm.font("Noto Color Emoji", { weight = "Regular" })

-- config.font = wezterm.font("Ubuntu Mono", {weight="Bold", stretch="Normal"}) -- /usr/share/fonts/truetype/ubuntu/UbuntuMono-BI.ttf, FontConfig
-- wezterm.font("Ubuntu", { weight = "Bold", stretch = "Normal", style = "Oblique" }) -- /usr/share/fonts/truetype/ubuntu/Ubuntu-Th.ttf, FontConfig
-- -> should be ->, not some fancy ligature madness
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
config.background = {
	{
		width = "100%",
		height = "100%",
		hsb = { brightness = 0.3 },
		opacity = 0.90,
		source = {
			Gradient = gradients.blue_and_red,
		},
	},
}

config.font_size = 15
-- config.text_background_opacity = .69
-- config.window_background_opacity = .85

config.term = "wezterm"

config.mouse_bindings = {
	{
		event = { Up = { streak = 2, button = "Right" } },
		mods = "NONE",
		action = wezterm.action_callback(function(window, pane)
			local has_selection = window:get_selection_text_for_pane(pane) ~= ""
			if has_selection then
				window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
				window:perform_action(act.ClearSelection, pane)
			else
				window:perform_action(act({ PasteFrom = "Clipboard" }), pane)
			end
		end),
	},
}
-- Use the defaults as a base
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- make task numbers clickable
-- the first matched regex group is captured in $1.
-- table.insert(config.hyperlink_rules, {
-- multi line comment
-- regex = [[\b[tt](\d+)\b]],
-- format = "https://example.com/tasks/?t=$1",
-- })

-- make username/project paths clickable. this implies paths like the following are for github.
-- ( "nvim-treesitter/nvim-treesitter" | wbthomason/packer.nvim | wez/wezterm | "wez/wezterm.git" )
-- as long as a full url hyperlink regex exists above this it should not match a full url to
-- github or gitlab / bitbucket (i.e. https://gitlab.com/user/project.git is still a whole clickable url)
table.insert(config.hyperlink_rules, {
	regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
	format = "https://www.github.com/$1/$3",
})

return config
