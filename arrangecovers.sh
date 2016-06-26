#!/usr/bin/env bash

WIDTH=2386
HEIGHT=1790

H=3
V=2
R=768

# proper values for line drawing
PAD=$[($WIDTH - $R * $H) / ($H + 1)]
VPAD=$[($HEIGHT - $R * $V) / ($V + 1)]

LINE1H="0,$VPAD,$WIDTH,$VPAD"
LINE2H="0,$[$VPAD + $R],$WIDTH,$[$VPAD + $R]"
LINE3H="0,$[$VPAD * 2 + $R],$WIDTH,$[$VPAD * 2 + $R]"
LINE4H="0,$[$VPAD * 2 + $R * 2],$WIDTH,$[$VPAD * 2 + $R * 2]"

LINE1V="$PAD,0,$PAD,$HEIGHT"
LINE2V="$[$PAD + $R],0,$[$PAD + $R],$HEIGHT"
LINE3V="$[$PAD * 2 + $R],0,$[$PAD * 2 + $R],$HEIGHT"
LINE4V="$[$PAD * 2 + $R * 2],0,$[$PAD * 2 + $R * 2],$HEIGHT"
LINE5V="$[$PAD * 3 + $R * 2],0,$[$PAD * 3 + $R * 2],$HEIGHT"
LINE6V="$[$PAD * 3 + $R * 3],0,$[$PAD * 3 + $R * 3],$HEIGHT"

# expanded values for cover drawing
E=8
R=$[$R + $E*2]
PAD=$[($WIDTH - $R * $H) / ($H + 1)]
VPAD=$[($HEIGHT - $R * $V) / ($V + 1)]
RESIZE="$R"x"$R"
P11="+$PAD+$VPAD"
P12="+$[$PAD * 2 + $R]+$VPAD"
P13="+$[$PAD * 3 + $R * 2]+$VPAD"
P21="+$PAD+$[$VPAD * 2 + $R]"
P22="+$[$PAD * 2 + $R]+$[$VPAD * 2 + $R]"
P23="+$[$PAD * 3 + $R * 2]+$[$VPAD * 2 + $R]"


echo "PAD: $PAD"
echo "VPAD: $VPAD"
echo "RESIZE: $RESIZE"
echo "P11: $P11"
echo "P12: $P12"
echo "P13: $P13"
echo "P21: $P21"
echo "P22: $P22"
echo "P23: $P23"


convert \
    -units PixelsPerInch -density 300 \
    -size "$WIDTH"x"$HEIGHT" xc:white \
    -stroke black \
    -draw "line $LINE1H" \
    -draw "line $LINE2H" \
    -draw "line $LINE3H" \
    -draw "line $LINE4H" \
    -draw "line $LINE1V" \
    -draw "line $LINE2V" \
    -draw "line $LINE3V" \
    -draw "line $LINE4V" \
    -draw "line $LINE5V" \
    -draw "line $LINE6V" \
    \( $1 -resize $RESIZE \) -geometry $P11 -composite \
    \( $2 -resize $RESIZE \) -geometry $P12 -composite \
    \( $3 -resize $RESIZE \) -geometry $P13 -composite \
    \( $4 -resize $RESIZE \) -geometry $P21 -composite \
    \( $5 -resize $RESIZE \) -geometry $P22 -composite \
    \( $6 -resize $RESIZE \) -geometry $P23 -composite \
    layers.jpg