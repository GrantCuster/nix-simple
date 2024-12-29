workspace_ids=$(aerospace list-workspaces --monitor 1)
empty_workspace_ids=$(aerospace list-workspaces --monitor 1 --empty no)
sketchybar_commands=""

for sid in $workspace_ids; do
  if echo "$empty_workspace_ids" | grep -q "$sid"; then
    sketchybar_commands+="--set space.$sid drawing=on background.color=0xff1d2021 label.color=0xffebdbb2 icon.color=0xffebdbb2 "
  else
    sketchybar_commands+="--set space.$sid drawing=off "
  fi
done

# focused workspace
sketchybar_commands+="--set space.$FOCUSED_WORKSPACE background.color=0xffd5c4a1 icon.color=0xff000000 label.color=0xff000000 drawing=on "

sketchybar $sketchybar_commands


