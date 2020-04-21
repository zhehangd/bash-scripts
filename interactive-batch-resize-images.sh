read -p "Enter source directory: "
IN_DIR=$REPLY
read -p "Enter output directory: "
OUT_DIR=$REPLY

read -p "Enter target size (WxH): "
target_size=$REPLY

cmd_args=()

if ! [[ $target_size =~ ^[[:digit:]]+x[[:digit:]]+$ ]]; then
  echo "Invalid size: \"${target_size}\""
  exit 1
fi

read -p "Do you want the images fill entirely the size? (y/N): "
if [[ $REPLY =~ ^[Yy]$ ]]; then
  cmd_args+=(-resize "$target_size^")
  read -p "Do you want to crop the images? (y/N): "
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    cmd_args+=(-gravity center -crop "$target_size+0+0")
  fi
else
  cmd_args+=(-resize "$target_size")
fi

for in_filename in $(find "$IN_DIR" -mindepth 1 -type f | sort -h); do
  echo "$in_filename -> $out_filename"
  filename=$(realpath --relative-to "$IN_DIR" "$in_filename")
  filename_noext="${filename%.*}"
  ext="${filename##*.}"
  out_filename="${OUT_DIR}/${filename_noext}.jpg"
  mkdir -p $(dirname "$out_filename")
  convert "${in_filename}" "${cmd_args[@]}" "${out_filename}"
done
