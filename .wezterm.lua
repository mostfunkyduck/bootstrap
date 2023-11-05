local wezterm = require 'wezterm'
local config = {}

config.font = wezterm.font('JetBrains Mono', { weight="Bold", stretch="Normal", })

-- config.font = wezterm.font("Ubuntu Mono", {weight="Bold", stretch="Normal"}) -- /usr/share/fonts/truetype/ubuntu/UbuntuMono-BI.ttf, FontConfig
-- wezterm.font("Ubuntu", {weight=250, stretch="Normal", style="Normal"}) -- /usr/share/fonts/truetype/ubuntu/Ubuntu-Th.ttf, FontConfig


-- The art is a bit too bright and colorful to be useful as a backdrop
-- for text, so we're going to dim it down to 10% of its normal brightness
local dimmer = { brightness = 0.1 }
config.window_background_gradient = {
  -- Can be "Vertical" or "Horizontal".  Specifies the direction
  -- in which the color gradient varies.  The default is "Horizontal",
  -- with the gradient going from left-to-right.
  -- Linear and Radial gradients are also supported; see the other
  -- examples below
    orientation = {
      Linear = {
        angle = -69.0
      }, 
    },

  -- Specifies the set of colors that are interpolated in the gradient.
  -- Accepts CSS style color specs, from named colors, through rgb
  -- strings and more
  colors = {
    '#414f45',
    '#0f0c29',
    '#302b63',
    '#202421',
    '#0e0b29',
    '#160c63',
  },

  -- Instead of specifying `colors`, you can use one of a number of
  -- predefined, preset gradients.
  -- A list of presets is shown in a section below.
  -- preset = "Greys",

  -- Specifies the interpolation style to be used.
  -- "Linear", "Basis" and "CatmullRom" as supported.
  -- The default is "Linear".
  interpolation = 'Basis',

  -- How the colors are blended in the gradient.
  -- "Rgb", "LinearRgb", "Hsv" and "Oklab" are supported.
  -- The default is "Rgb".
  blend = 'Oklab',

  -- To avoid vertical color banding for horizontal gradients, the
  -- gradient position is randomly shifted by up to the `noise` value
  -- for each pixel.
  -- Smaller values, or 0, will make bands more prominent.
  -- The default value is 64 which gives decent looking results
  -- on a retina macbook pro display.
  -- noise = 64,

  -- By default, the gradient smoothly transitions between the colors.
  -- You can adjust the sharpness by specifying the segment_size and
  -- segment_smoothness parameters.
  -- segment_size configures how many segments are present.
  -- segment_smoothness is how hard the edge is; 0.0 is a hard edge,
  -- 1.0 is a soft edge.

  -- segment_size = 6,
  -- segment_smoothness = .5,
}

config.font_size = 15
-- config.text_background_opacity = .5
config.window_background_opacity = .95
return config
