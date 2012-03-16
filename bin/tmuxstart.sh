#!/bin/sh
tmux new-session -d -s windsor

tmux new-window -t windsor -n 'bash' 'bash'
tmux new-window -t windsor -n 'bash' 'bash'
tmux new-window -t windsor -n 'bash' 'bash'
tmux new-window -t windsor -n 'bash' 'bash'
tmux new-window -t windsor -n 'bash' 'bash'
tmux new-window -t windsor -n 'bash' 'bash'
tmux new-window -t windsor -n 'ranger' 'ranger'
tmux new-window -t windsor -n 'mutt' 'mutt'

tmux select-window -t windsor:1
tmux -2 attach-session -t windsor
