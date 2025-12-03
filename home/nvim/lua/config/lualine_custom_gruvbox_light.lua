local colors = {
  black        = '#fbf1c7',
  white        = '#3c3836',
  red          = '#9d0006',
  green        = '#79740e',
  blue         = '#076678',
  yellow       = '#af3a03',
  gray         = '#7c6f64',
  darkgray     = '#ebdbb2',
  lightgray    = '#d5c4a1',
  inactivegray = '#a89984',
}

local background_color = colors.black

return {
  normal = {
    a = {bg = background_color, fg = colors.green},
    b = {bg = background_color, fg = colors.yellow},
    c = {bg = background_color, fg = colors.blue},
    z = {bg = background_color, fg = colors.white},
  },
  insert = {
    a = {bg = background_color, fg = colors.green},
    b = {bg = background_color, fg = colors.yellow},
    c = {bg = background_color, fg = colors.blue},
    z = {bg = background_color, fg = colors.white},
  },
  visual = {
    a = {bg = background_color, fg = colors.green},
    b = {bg = background_color, fg = colors.yellow},
    c = {bg = background_color, fg = colors.blue},
    z = {bg = background_color, fg = colors.white},
  },
  replace = {
    a = {bg = background_color, fg = colors.green},
    b = {bg = background_color, fg = colors.yellow},
    c = {bg = background_color, fg = colors.blue},
    z = {bg = background_color, fg = colors.white},
  },
  command = {
    a = {bg = background_color, fg = colors.green},
    b = {bg = background_color, fg = colors.yellow},
    c = {bg = background_color, fg = colors.blue},
    z = {bg = background_color, fg = colors.white},
  },
  inactive = {
    a = {bg = background_color, fg = colors.green},
    b = {bg = background_color, fg = colors.yellow},
    c = {bg = background_color, fg = colors.blue},
    z = {bg = background_color, fg = colors.white},
  }
}
