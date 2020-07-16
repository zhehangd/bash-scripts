# WxH of the side-by-side array. e.g. 3x2
ARRAY_SIZE="5x1"

# Placeholder for image name
IMAGE_NAME_PLACEHOLDER="<ImAgE>"

# The image list is obtained by searching this directory
SEARCH_DIRECTORY="imgs"

# The image list is obtained by searching this pattern
SEARCH_PATTERN="*.jpg"

# Directory to save the generated images
# Will be created if it does not exist
OUTPUT_DIRECTORY="sbs_out"

# Suffix added to the generated image filename
OUTPUT_SUFFIX="_sbs"

# Extension the generated image filename
OUTPUT_EXT="jpg"

# ----------- Code to register array items ---------

item_names=()
item_image_pathname_templates=()

register_item () {
  item_name="$1"
  item_dir="$2"
  item_suffix="$3"
  item_ext="$4"
  item_image_pathname_template="${item_dir}/${IMAGE_NAME_PLACEHOLDER}${item_suffix}.${item_ext}"
  item_names+=("${item_name}")
  item_image_pathname_templates+=("${item_image_pathname_template}")
  echo "Added <${item_name}>: ${item_image_pathname_template}"
}

# ---------------------------------------------------

# Configure the side-by-side array:
# <Item name> <Directory> <Suffix> <Extension>
register_item "original" "imgs" "" "jpg"
register_item "global lighting" "imgs_global_lighting" "" "jpg"
register_item "grep0" "color1.5_lighting1.35_grey0" "_result" "jpg"
register_item "grep25" "color1.5_lighting1.35_grey25" "_result" "jpg"
register_item "grep50" "color1.5_lighting1.35_grey50" "_result" "jpg"

# --------------------- Start ---------------------

check_file_exists () {
  file_name=$1
  if [ ! -f $file_name ] 
  then
      echo "File \"$file_name\" DOES NOT exist."
      exit 1
  fi
}

find "${SEARCH_DIRECTORY}" -type f -name "${SEARCH_PATTERN}" -print0 |
while IFS= read -r -d '' image_pathname; do
  image_filename=$(realpath "$image_pathname" --relative-to "${SEARCH_DIRECTORY}")
  image_filename_ext="${image_filename##*.}"
  image_filename_noext="${image_filename%.*}"
  printf '%s\n' "$image_filename_noext"
  
  montage_cmd=(montage)
  montage_cmd+=(-tile "${ARRAY_SIZE}")
  montage_cmd+=(-background skyblue -pointsize 80 -geometry +0+0)
  for ((i = 0; i < ${#item_names[@]}; i++)); do
    item_name="${item_names[$i]}"
    if [ -n "$item_name" ]; then
      item_image_pathname_template="${item_image_pathname_templates[$i]}"
      item_image_pathname=$(\
        echo "$item_image_pathname_template" |\
        sed "s/${IMAGE_NAME_PLACEHOLDER}/${image_filename_noext}/g")
      echo " - <$item_name>: <$item_image_pathname>"
      check_file_exists "$item_image_pathname"
      montage_cmd+=(-label "${item_name}" "${item_image_pathname}")
    else
      echo " - EMPTY"
      montage_cmd+=("null:") # DOES NOT WORK, SOMEHOW
    fi
  done
  
  output_image_pathname="${OUTPUT_DIRECTORY}/${image_filename_noext}${OUTPUT_SUFFIX}.${OUTPUT_EXT}"
  echo " -> <$output_image_pathname>"
  mkdir -p "$(dirname "$output_image_pathname")"
  montage_cmd+=("$output_image_pathname")
  "${montage_cmd[@]}"
  echo "${montage_cmd[@]}"
  break
done

