#!/bin/bash 

#for i in $(ls -1); do convert $i -resize 20% $(echo $i|cut -d. -f1)_small.jpg; done
# convert /home/ramiro/anabolena/anabolena_color.png -resize 20% anabolena_color_small.png
#for i in $(ls -1 *_small.jpg); do composite  -gravity NorthEast anabolena_color_small.png $i $(echo $i|cut -d. -f1)_small_logo.jpg; done

convert_img(){
    file=$(basename $1)
    file_geometry=$(identify $file|awk '{print $3}')
    file_type=$(identify $file|awk '{print $2}')
    file_width=$(echo $file_geometry|cut -dx -f1)
    file_height=$(echo $file_geometry|cut -dx -f2)
    file_basename=$(echo $file|cut -d. -f1)

    converted_file=${file_basename// /}_converted.${file_type}
    file_logo=~/anabolena/anabolena_color_crop.png

    if [ ! -f $file_logo ];then
        echo "no esta el logo"
        exit
    fi

    echo $file_geometry
    echo $file_width
    echo $file_height

    # intento fallido de calcular segun el ratio
    #if [ $file_width -gt $file_height ]; then
    #    ratio=$(echo "$file_width/$file_height"|bc -l)
    #else
    #    ratio=$(echo "$file_height/$file_width"|bc -l)
    #fi
    #tmp_heigth=$(echo "$ratio*100"|bc -l)
    #logo_size="${tmp_heigth%.*}x100"

    # este tamaño se ajusta bien en la mayoria de los casos
    logo_size="135x100"
    echo "logo size: $logo_size"
    if echo $(basename $file) | egrep -q '(^ne_|^no_|^se_|^so_)'; then
        coord=$(basename $file|cut -d_ -f1)
        echo "archivo con coordenada $coord"
        case $coord in
            ne)
                echo "NorthEast"
                convert  -composite  -gravity NorthEast -resize 1200x800 $file $file_logo -geometry ${logo_size}+15+15 $converted_file
                ;;
            no)
                echo "NorthWest"
                convert  -composite  -gravity NorthWest -resize 1200x800 $file $file_logo -geometry ${logo_size}+15+15 $converted_file
                ;;
            se)
                echo "SouthEast"
                convert  -composite  -gravity SouthEast -resize 1200x800 $file $file_logo -geometry ${logo_size}+25+0 $converted_file
                ;;
            so)
                echo "SouthWest"
                convert  -composite  -gravity SouthWest -resize 1200x800 $file $file_logo -geometry ${logo_size}+20+0 $converted_file
                ;;
            *)
                echo "no deberia"
                ;;
        esac

    else
        # Noreste por defecto
        convert  -composite  -gravity NorthEast -resize 1200x800 $file $file_logo -geometry ${logo_size}+15+15 $converted_file
    fi
    #convert -size 1200x800 -composite  -gravity NorthEast DSC03302_small.jpg anabolena_color.png -geometry 252x153+0+0  result.jpg
}


if [ $# -ne 1 ]; then
    echo "el arg es dir (itera los jpg) o file"
    exit 1
else
    if [ -d "$1" ];then
        export OLD_IFS=$IFS
        export IFS=$'\n'
        for i in $(ls -1 $1/*.{jpg,png});do
            mv "$i" ${i// /}
            convert_img ${i// /}
        done
    elif [ -f "$1" ];then
        mv "$1" ${1// /}
        export IFS=$OLD_IFS
        convert_img "${1// /}"
    fi
fi


