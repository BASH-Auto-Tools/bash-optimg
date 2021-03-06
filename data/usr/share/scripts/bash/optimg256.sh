#!/bin/bash

VER="20140329"
GREEN="\033[1;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
ENDCOLOR="\033[0m"

RAMDISK="/dev/shm"

tproc=`basename $0`
echo -e $GREEN"$tproc version $VER"$ENDCOLOR
echo ""

usage()
{
    tproc=`basename $0`
    echo -e $YELLOW"usage:"$ENDCOLOR
    echo -e $GREEN" bash $tproc img-before.[jpg|gif|png] "$ENDCOLOR
    exit 0
}

testargs()
{
    if [ "+$1" = "+" -o "+$1" = "+--help" -o "+$1" = "+-h" ]
    then
	usage
    fi
}

testcomponent()
{
    tnocomp=""
    tcomp="/usr/bin/identify"
    tdeb="imagemagick_*.deb"
    if [ ! -f "$tcomp" ]
    then
	tnocomp="$tnocomp $tcomp($tdeb)"
    fi
    tcomp="/usr/bin/jpegtran"
    tdeb="libjpeg-progs_*.deb"
    if [ ! -f "$tcomp" ]
    then
	tnocomp="$tnocomp $tcomp($tdeb)"
    fi
    tcomp="/usr/bin/gifsicle"
    tdeb="gifsicle_*.deb"
    if [ ! -f "$tcomp" ]
    then
	tnocomp="$tnocomp $tcomp($tdeb)"
    fi
    tcomp="/usr/bin/pngnq"
    tdeb="pngnq_*.deb"
    if [ ! -f "$tcomp" ]
    then
	tnocomp="$tnocomp $tcomp($tdeb)"
    fi
    tcomp="/usr/bin/pngcrush"
    tdeb="pngcrush_*.deb"
    if [ ! -f "$tcomp" ]
    then
	tnocomp="$tnocomp $tcomp($tdeb)"
    fi
    tcomp="/usr/bin/optipng"
    tdeb="optipng_*.deb"
    if [ ! -f "$tcomp" ]
    then
	tnocomp="$tnocomp $tcomp($tdeb)"
    fi
    tcomp="/usr/bin/advpng"
    tdeb="advancecomp_*.deb"
    if [ ! -f "$tcomp" ]
    then
	tnocomp="$tnocomp $tcomp($tdeb)"
    fi
    tcomp="/usr/bin/stat"
    tdeb="coreutils_*.deb"
    if [ ! -f "$tcomp" ]
    then
	tnocomp="$tnocomp $tcomp($tdeb)"
    fi
    if [ "+$tnocomp" != "+" ]
    then
	echo -e $RED"Not found $tnocomp !"$ENDCOLOR
	echo ""
	exit 0
    fi
}

testsource()
{
    src="$1"
    if [ ! -f "$src" ]
    then
	echo "File $src does not exist"
	usage
    fi
}

main()
{
    tproc=`basename $0`
    src="$1"

    if [ -d "$RAMDISK" ]
    then
	tmppath="$RAMDISK"
    else
	tmppath="/tmp"
    fi
    TYPE=`identify "$src" | grep -E -o 'JPEG|GIF|PNG'`
    OLD=`stat -c %s "$src"`

    echo "$src: $OLD"
    case "$TYPE" in
        JPEG)
	    tmpjp="$tmppath/optimg.p.$$.jpg"
	    tmpjn="$tmppath/optimg.n.$$.jpg"
	    jpegtran -copy none -optimize -perfect -progressive -outfile "$tmpjp" "$src"
	    jpegtran -copy none -optimize -perfect -outfile "$tmpjn" "$src"
	    if [ -f "$tmpjp" -a -f "$tmpjn" ]; then
		S_PROG=`stat -c %s "$tmpjp"`
		S_NORM=`stat -c %s "$tmpjn"`
		echo " normal: $S_NORM"
		echo " progressive: $S_PROG"
		if [ $S_PROG -ge $S_NORM ]; then
		    mv -f "$tmpjn" "$src"
		    rm -f "$tmpjp"
		else
		    mv -f "$tmpjp" "$src"
		    rm -f "$tmpjn"
		fi;
	    fi
	;;

	GIF)
	    gifsicle -O2 -b "$src"
	;;

	PNG)
	    tmppng256="$tmppath/optimg.$$-nq8.png"
	    tmppng="$tmppath/optimg.$$.png"
	    cp "$src" "$tmppng"
	    pngnq "$tmppng"
	    if [ ! -s "$tmppng256" ]
	    then
		cp "$tmppng" "$tmppng256"
	    fi
	    tsize0=`stat -c %s "$tmppng"`
	    tsize256=`stat -c %s "$tmppng256"`
	    if [ $tsize256 -gt $tsize0 ]
	    then
		cp "$tmppng" "$tmppng256"
	    fi
	    rm -f "$tmppng"
	    tsize=`stat -c %s "$tmppng256"`
	    echo " pngnq: $tsize"
	    pngcrush -q -rem alla -fix "$tmppng256" "$tmppng"
	    if [ ! -s "$tmppng" ]
	    then
		cp "$tmppng256" "$tmppng"
	    fi
	    rm -f "$tmppng256"
	    tsize=`stat -c %s "$tmppng"`
	    echo " pngcrush: $tsize"
	    advpng -z -4 -q "$tmppng"
	    tsize=`stat -c %s "$tmppng"`
	    echo " advpng: $tsize"
	    if [ -f "$tmppng" ]; then
		mv -f "$tmppng" "$src"
	    fi;
	;;
    esac

    if [ "+$TYPE" != "+" ]
    then
	NEW=`stat -c %s "$src"`
	SDIFF=$(($NEW * 100 / $OLD))
	echo "old size: $OLD, new size: $NEW ($SDIFF%)"
    fi
    echo ""
}

testargs "$@"
testcomponent
testsource "$@"
main "$@"

#end
