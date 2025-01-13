#!/bin/bash
# PS4='+${LINENO}: '
# set -x # enable these 2 lines for debugging

if ! command -v ffmpeg &> /dev/null; then
    echo "Warning: ffmpeg is not installed. Please install ffmpeg to continue."
    exit 1
else
    continue
fi

echo "Warning - this script will erase any folder named 'output' inside whatever music directory you choose. Be careful!"
echo

while true; do
    read -p "Are you converting for radio or CD? (radio/cd) : " musicType
    musicType=$(echo "$musicType" | tr '[:upper:]' '[:lower:]')

    if [[ "$musicType" == "radio" || "$musicType" == "cd" ]]; then
        echo "You selected $musicType"
        break
    else
        echo "Please type 'radio' or 'CD'."
        continue
    fi
done

while true; do
    read -e -p "Enter Music Directory: " musicDir
    if [ -d "$musicDir" ]; then
        rm -rf "$musicDir/output"
        mkdir "$musicDir/output"
        break
    else
        echo "Directory does not exist. Please try again."
        continue
    fi
done

filesInMusicDir=$(find "$musicDir" -maxdepth 1 -type f)
if [ -z "$filesInMusicDir" ]; then
    echo "There are no files in the selected directory. Please try again."
    exit 1
fi

declare -a musicFiles
while IFS= read -r file; do
    musicFiles+=("$file")
done <<< "$filesInMusicDir"

echo "Transcoding!"

printf 's%s\n' "${musicFiles[@]}" > $musicDir/output/trackorder.txt
track=1
if [ "$musicType" == "cd" ]; then
    for file in "${musicFiles[@]}"; do
        ffmpeg -i "$file" -vn -sn -ar 44100 "$musicDir/output/track${track}.ogg"
        ((track++))
    done

elif [ "$musicType" == "radio" ]; then
    for file in "${musicFiles[@]}"; do
        ffmpeg -i "$file" -vn -sn -ar 22050 -ac 1 "$musicDir/output/track${track}.ogg"
        ((track++))
    done
fi

echo "Done!"
exit
