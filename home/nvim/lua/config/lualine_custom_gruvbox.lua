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
return {
  normal = {
    a = {bg = colors.black, fg = colors.white},
    b = {bg = colors.black, fg = colors.gray},
    c = {bg = colors.black, fg = colors.gray}
  },
  insert = {
    a = {bg = colors.black, fg = colors.white},
    b = {bg = colors.black, fg = colors.gray},
    c = {bg = colors.black, fg = colors.gray}
  },
  visual = {
    a = {bg = colors.black, fg = colors.white},
    b = {bg = colors.black, fg = colors.gray},
    c = {bg = colors.black, fg = colors.gray}
  },
  replace = {
    a = {bg = colors.black, fg = colors.white},
    b = {bg = colors.black, fg = colors.gray},
    c = {bg = colors.black, fg = colors.gray}
  },
  command = {
    a = {bg = colors.black, fg = colors.white},
    b = {bg = colors.black, fg = colors.gray},
    c = {bg = colors.black, fg = colors.gray}
  },
  inactive = {
    a = {bg = colors.black, fg = colors.white},
    b = {bg = colors.black, fg = colors.gray},
    c = {bg = colors.black, fg = colors.gray}
  }
}
