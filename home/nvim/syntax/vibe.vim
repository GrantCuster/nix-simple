" Syntax highlighting for .vibe files
"if exists("b:current_syntax")
"  finish
"endif

" Match lines starting with >
" Priority: Higher number = higher priority (will override lower priority matches)

" Case 1: > followed by single word
" Example: "> word"
syntax match vibePrefix "^>" contained
syntax match vibeSingleWord "\S\+$" contained
syntax match vibeLineSingle "^>\s*\S\+$" contains=vibePrefix,vibeSingleWord

" Case 2: > followed by multiple words
" Example: "> word1 word2 word3"
" Match everything except the last word as emphasized
syntax match vibeLineMulti "^>\s*\S\+.*\s\S\+$" contains=vibePrefix,vibeLastWord
syntax match vibeLastWord "\s\S\+$" contained

" Markdown-style headers
" Example: "# Header" or "## Header" or "### Header"
syntax match vibeHeader1 "^$\s.*$"
syntax match vibeHeader2 "^=\s.*$"

" Todo items
" Example: "- [ ] Todo item" or "- [x] Completed item"
syntax match vibeTodoUnchecked "^-\s*\[\s\].*$"
syntax match vibeTodoChecked "^-\s*\[x\].*$"

" Bracket content
" Example: "[something]" - highlights content between brackets
syntax match vibeBracketContent "\[.\{-}\]"

" Define the highlight colors
highlight default link vibePrefix Special
highlight default link vibeSingleWord String
highlight default link vibeLineMulti String
highlight default link vibeLastWord Identifier
highlight default link vibeHeader1 Type
highlight default link vibeHeader2 PreProc
highlight default link vibeTodoUnchecked Special
highlight default link vibeTodoChecked String
highlight default link vibeBracketContent Identifier

let b:current_syntax = "vibe"
