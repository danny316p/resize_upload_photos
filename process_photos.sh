#!/bin/bash

#Load config file as variables
# read in a config file specifying FTP data, $teaser (name of teaser image), $name (prepend string for filenames), $subfolder (if applicable - such as "Toy_Fair_2017")

source ./process_photos.cfg

if [ $V -gt 0 ]; then
	echo "loaded in NAME=$NAME TEASER=$TEASER SUBFOLDER=$SUBFOLDER V=$V"
	echo "loaded in FTP_SERVER=$FTP_SERVER FTP_USERNAME=$FTP_USERNAME FTP_PASSWORD=$FTP_PASSWORD FTP_PATH=$FTP_PATH"
fi

# create "$name" folder
mkdir $NAME

# fix anything that's .jpg instead of .JPG
for x in *.jpg; do mv "$x" "${x%.jpg}.JPG"; done

# copy all photos to "$name" (don't risk damaging the originals)
cp *.JPG $NAME/

# enter $name directory
cd $NAME
if [ $V -gt 0 ]; then
	echo "in folder $NAME\n"
fi

# create teaser-resized photo - we'll rename it later
mkdir teaser
# These are MAXIMUM sizes. 180x120 is correct for Dan's camera
mogrify -path ./teaser -thumbnail 500x120 $TEASER
if [ $V -gt 0 ]; then
	ls teaser
fi

# rename all photos in photos using prepend name
for i in *.JPG ; do mv "$i" "${i/IMG/}" ; done
for i in *.JPG ; do mv "$i" "$NAME$i" ; done

if [ $V -gt 0 ]; then
	echo "renamed files"
	ls
fi

# create "$name/thumbs"
mkdir thumbs

# create thumbnail-resized photos in "$name/thumbs/"
# These are MAXIMUM sizes. 240x160 is correct for Dan's camera
mogrify -path ./thumbs -thumbnail 1000x160 *.JPG

# rename all thumbnails to start with tn_
cd thumbs
for i in *.JPG ; do mv "$i" "tn_$i" ; done

if [ $V -gt 0 ]; then
	ls
fi

cd ..


# move / rename teaser-resized photo teaser_$teaser
mv teaser/$TEASER teaser_$NAME$TEASER
rm -rf teaser
for i in teaser* ; do mv "$i" "${i/IMG/}" ; done


# Dump the thumbs back in the main directory so you don't need to FTP up things from both directories
cp thumbs/* ./
rm -rf thumbs

# automatically generate HTML for gallery viewer and teaser, dump it to stdout
echo ""
if [ "$SUBFOLDER" == "" ]; then
	echo "<img src='/Imaging/stories/teaser_$NAME${TEASER/IMG/}' border='0' align='left' hspace=6>"
else
	echo "<img src='/Imaging/stories/$SUBFOLDER/teaser_$NAME${TEASER/IMG/}' border='0' align='left' hspace=6>"
fi
echo ""
echo ""
echo ""

echo "<p align='center'>"
if [ "$SUBFOLDER" == "" ]; then
	for i in $NAME*.JPG ; do echo "<a href=\"javascript:galImage('/$i')\"><img src='/Imaging/stories/tn_$i' alt='${i/.JPG/}' border='0'></a>" ; done
else
	for i in $NAME*.JPG ; do echo "<a href=\"javascript:galImage('/$SUBFOLDER/$i')\"><img src='/Imaging/stories/$SUBFOLDER/tn_$i' alt='${i/.JPG/}' border='0'></a>" ; done

fi
echo "</p>"



## TODO
# automatically FTP all files to server, using $subfolder and FTP data




