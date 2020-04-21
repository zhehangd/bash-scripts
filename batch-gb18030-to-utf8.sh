# https://www.tecmint.com/convert-files-to-utf-8-encoding-in-linux/

INPUT_DIR=$1
OUTPUT_DIR=$2
mkdir -p ${OUTPUT_DIR}

FROM_ENCODING="GB18030"
TO_ENCODING="UTF-8"

for input_file_path in $(find ${INPUT_DIR} -type f -name "*"); do
  echo ${input_file_path}
  name=$(basename ${input_file_path})
  output_filename=${OUTPUT_DIR}/${name}
  
  file -i ${input_file_path}
  if [[ $(file -i ${input_file_path}  | grep -iv "UTF-8") ]]; then
    iconv \
      -f ${FROM_ENCODING} -t ${TO_ENCODING} \
      -o  ${output_filename} ${input_file_path}
      
    if [ ! $? -eq 0 ]; then
        echo "Conversion Error."
        exit 1
    fi
  fi
done
