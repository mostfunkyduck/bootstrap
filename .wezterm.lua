local wezterm = require("wezterm")
local act = wezterm.action
local config = {}

config.font = wezterm.font("JetBrains Mono", { weight = "ExtraBold" })
-- config.font = wezterm.font('Nerd Font Mono', { weight="Regular",  })

-- config.font = wezterm.font("Ubuntu Mono", {weight="Bold", stretch="Normal"}) -- /usr/share/fonts/truetype/ubuntu/UbuntuMono-BI.ttf, FontConfig
-- wezterm.font("Ubuntu", {weight=250, stretch="Normal", style="Normal"}) -- /usr/share/fonts/truetype/ubuntu/Ubuntu-Th.ttf, FontConfig

config.background = {
	{
		width = "100%",
		height = "100%",
		hsb = { brightness = 0.3 },
		opacity = 0.95,
		source = {
			Gradient = {
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
					-- cx = 0.75,
					-- cy = 0.75,
					-- radius = 1.25,
					-- }
				},

				-- Specifies the set of colors that are interpolated in the gradient.
				-- Accepts CSS style color specs, from named colors, through rgb
				-- strings and more
				colors = {
					"#160c63",
					-- '#0e0b29',
					"#414f45",
					-- chrome/aluminum colors
					--'#E6EDf5',
					"#626569",
					-- '#9EA3A8',
					"#6E7173",
					"#494B4D",
					"#838F9C",
					--'#C2C8CF',
					"#6E7173",
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
		},
	},
}

config.font_size = 15
-- config.text_background_opacity = .69
-- config.window_background_opacity = .85

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
return config
