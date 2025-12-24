#!/bin/sh

# Kaomojis and their emotions
kaomojis=("(*^‿^*)" "(╯°□°）╯︵ ┻━┻" "(>_<)" "(¬‿¬)" "(•‿•)" "(╥﹏╥)")
emotions=("happy" "angry" "frustrated" "sly" "content" "sad")

# Log file path
log="$HOME/kaomoji_log.txt"

tick=0

# Function to shut down
shutdown_pc() {
  echo "Delete pressed. Shutting down..."
  sudo shutdown now
  exit
}

# Run key listener in background
(
  while true; do
    # Read one character silently
    read -rsn1 key
    if [ "$key" = $'\x7f' ]; then  # Delete key ASCII 127
      shutdown_pc
    fi
  done
) &

listener_pid=$!  # Save background PID to kill later

# Main kaomoji loop
while true; do
  # Clear the screen
  clear

  # Pick kaomoji and emotion
  index=$((tick % ${#kaomojis[@]}))
  kaomoji=${kaomojis[$index]}
  emotion=${emotions[$index]}

  # Print kaomoji with emotion
  echo "$kaomoji — $emotion"

  # Log it with timestamp
  echo "$(date '+%Y-%m-%d %H:%M') $kaomoji — $emotion" >> "$log"

  tick=$((tick + 1))

  # Sleep 30 minutes (1800s)
  sleep 1800
done

# Cleanup listener if somehow the loop exits
kill $listener_pid