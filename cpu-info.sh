#!/bin/bash

# yad required
command -v yad >/dev/null 2>&1 || { echo >&2 "yad package required but it is not installed.  Aborting."; exit 99; }

# generate a random filename
tmp_file=$(openssl rand -base64 32 | tr -dc A-Za-z0-9 && echo ".html")

touch $tmp_file

# open body
echo "<body style='
        margin: 0;
        padding: 1rem;
        background-color: #333;
        box-sizing: border-box;
        color: #eee;
        display: flex:
        align-items: center;
        align-content: center;
        justify-content: center;
        flex-flow: column;
        width: 100%;
        font-family: monospace;
    '>" >> $tmp_file

# refresh script
echo "<script>setTimeout(function() { window.location.reload() }, 500)</script>" >> $tmp_file

# window title
echo "<h1 align=center> Computer info </h1>" >> $tmp_file


# catch cpu info

## section title
echo "<h2> ⚙ CPU </h2>" >> $tmp_file

cpu_info=$(openssl rand -base64 32 | tr -dc A-Za-z0-9 && echo ".txt")

touch $cpu_info

cat /proc/cpuinfo >> $cpu_info

info_icon="<span style='color: gold;'> ★ </span>"

declare -a information=(
    "model name"
    "cpu MHz"
    "siblings"
)

for info in "${information[@]}"; do
    echo $info_icon >> $tmp_file
    cat $cpu_info | grep "$info" | head -1 >> $tmp_file
    echo "<br>" >> $tmp_file
done

# catch mem info

## section title
echo "<h2> ⛁ Memory </h2>" >> $tmp_file

mem_info=$(openssl rand -base64 32 | tr -dc A-Za-z0-9 && echo ".txt")

touch $mem_info

cat /proc/meminfo >> $mem_info

info_icon="<span style='color: gold;'> ★ </span>"

declare -a information=(
    "MemTotal"
    "MemFree"
    "MemAvailable"
)

for info in "${information[@]}"; do
    echo $info_icon >> $tmp_file
    cat $mem_info | grep "$info" | head -1 >> $tmp_file
    echo "<br>" >> $tmp_file
done

mem_total=$(cat $mem_info | grep "MemTotal" | grep "[0-9]*" -o)
mem_free=$(cat $mem_info | grep "MemFree" | grep "[0-9]*" -o)


let mem_free_percentage="100 * $mem_free / $mem_total"
let mem_total_percentage="100-$mem_free_percentage"

echo "<br>" >> $tmp_file
echo "<div style='display: flex'>" >> $tmp_file
    echo "<div style='padding:1rem; width: $mem_free_percentage%; height: 40px; background: green'></div>" >> $tmp_file 
    echo "<div style='padding:1rem; width: $mem_total_percentage%; height: 40px; background: red'></div>" >> $tmp_file
echo "</div>" >> $tmp_file

# close body
echo "</body>" >> $tmp_file

# create the gui
yad -tail --title "CPU INFO" --html --uri="./$tmp_file" --monitor --width=550 --height=400 --browser

# delete files
rm $cpu_info
rm $mem_info
rm $tmp_file
