local colors = {
  black        = '#282828',
  white        = '#ebdbb2',
  red          = '#fb4934',
  green        = '#b8bb26',
  blue         = '#83a598',
  yellow       = '#fe8019',
  gray         = '#a89984',
  darkgray     = '#3c3836',
  lightgray    = '#504945',
  inactivegray = '#7c6f64',
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
