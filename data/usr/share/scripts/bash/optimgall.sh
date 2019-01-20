#!/bin/bash
# optimgall.sh

VER="20140329"
GREEN="\033[1;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
ENDCOLOR="\033[0m"

tproc=`basename $0`
echo -e $GREEN"$tproc version $VER"$ENDCOLOR
echo ""

usage()
{
    tproc=`basename $0`
    echo -e $YELLOW"usage:"$ENDCOLOR
    echo -e $GREEN" bash $tproc"$ENDCOLOR
    exit 0
}

testargs()
{
    if [ "+$1" = "+--help" -o "+$1" = "+-h" ]
    then
	usage
    fi
}

testcomponent()
{
    tnocomp=""
    tcomp="/usr/bin/bash-optimg"
    tdeb="bash-optimg_*.deb"
    if [ ! -f "$tcomp" ]
    then
	tnocomp="$tnocomp $tcomp($tdeb)"
    fi
    #*)optimg.sh depends begin
    tcomp="/usr/bin/identify"
    tdeb="imagemagick_*.deb"
    if [ ! -f "$tcomp" ]
    then
	tnocomp="*)$tnocomp $tcomp($tdeb)"
    fi
    tcomp="/usr/bin/jpegtran"
    tdeb="libjpeg-progs_*.deb"
    if [ ! -f "$tcomp" ]
    then
	tnocomp="*)$tnocomp $tcomp($tdeb)"
    fi
    tcomp="/usr/bin/gifsicle"
    tdeb="gifsicle_*.deb"
    if [ ! -f "$tcomp" ]
    then
	tnocomp="*)$tnocomp $tcomp($tdeb)"
    fi
    tcomp="/usr/bin/pngcrush"
    tdeb="pngcrush_*.deb"
    if [ ! -f "$tcomp" ]
    then
	tnocomp="*)$tnocomp $tcomp($tdeb)"
    fi
    tcomp="/usr/bin/optipng"
    tdeb="optipng_*.deb"
    if [ ! -f "$tcomp" ]
    then
	tnocomp="*)$tnocomp $tcomp($tdeb)"
    fi
    tcomp="/usr/bin/advpng"
    tdeb="advancecomp_*.deb"
    if [ ! -f "$tcomp" ]
    then
	tnocomp="*)$tnocomp $tcomp($tdeb)"
    fi
    tcomp="/usr/bin/stat"
    tdeb="coreutils_*.deb"
    if [ ! -f "$tcomp" ]
    then
	tnocomp="*)$tnocomp $tcomp($tdeb)"
    fi
    #optimg.sh depends end
    if [ "+$tnocomp" != "+" ]
    then
	echo -e $RED"Not found $tnocomp !"$ENDCOLOR
	echo ""
	exit 0
    fi
}

main()
{
    find ./ -type f -iname "*.png" -printf "%p\n" | while read src
    do
	bash-optimg "$src"
    done
    find ./ -type f -iname "*.gif" -printf "%p\n" | while read src
    do
	bash-optimg "$src"
    done
    find ./ -type f -iname "*.jpg" -printf "%p\n" | while read src
    do
	bash-optimg "$src"
    done
    find ./ -type f -iname "*.jpeg" -printf "%p\n" | while read src
    do
	bash-optimg "$src"
    done
}

testargs "$@"
testcomponent
main "$@"

#end
