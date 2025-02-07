# workspace_ids=$(aerospace list-workspaces --monitor 1)
# empty_workspace_ids=$(aerospace list-workspaces --monitor 1 --empty no)
# sketchybar_commands=""

# for sid in $workspace_ids; do
#   if echo "$empty_workspace_ids" | grep -q "$sid"; then
#     sketchybar_commands+="--set space.$sid drawing=on"
#   else
#     sketchybar_commands+="--set space.$sid drawing=off "
#   fi
# done

# if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
#     sketchybar --set $NAME background.drawing=on label.color=0xff1d2021 icon.color=0xff1d2021
# else
#     sketchybar --set $NAME background.drawing=off label.color=0xffd5c4a1 icon.color=0xffd5c4a1
# fi

# focused workspace
# sketchybar_commands+="--set space.$FOCUSED_WORKSPACE background.color=0xffd5c4a1 icon.color=0xff000000 label.color=0xff000000 drawing=on "

file="$HOME/dev/aerospace.txt"
result=$(grep "^$FOCUSED_WORKSPACE " "$file" | cut -d ' ' -f2-)

if [ -z "$result" ]; then
  sketchybar --set aerospace label="$FOCUSED_WORKSPACE"
else
  sketchybar --set aerospace label="$FOCUSED_WORKSPACE $result"
fi
