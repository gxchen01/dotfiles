#!/bin/bash

DOT_FILES=('vimrc' 'gitconfig' 'bashrc' 'bash_profile')

echo "${DOT_FILES[@]}"

DST_LOCATION="$HOME"

# for debug
# DST_LOCATION="./tmp"
# mkdir ./tmp

for file in ${DOT_FILES[@]}; do
    echo "processing config file: $file"

    if [ -e "${DST_LOCATION}/.$file" ]; then
        echo "${DST_LOCATION}/.$file exists, backup it first..."
        # todo: if the current file is a symbol link, then we don't backup it.
        mv "${DST_LOCATION}/.$file"   "${DST_LOCATION}/.${file}.backup"
    fi

    cur_dir="$(pwd)"
    ln -fs ${cur_dir}/${file} ${DST_LOCATION}/.${file}
done

