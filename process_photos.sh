#!/bin/bash

#Load config file as variables
# read in a config file specifying FTP data, $teaser (name of teaser image), $name (prepend string for filenames), $subfolder (if applicable - such as "Toy_Fair_2017")

source ./process_photos.cfg

if [ $V -gt 0 ]; then
	echo "loaded in NAME=$NAME TEASER=$TEASER SUBFOLDER=$SUBFOLDER V=$V DONE=$DONE"
	echo "loaded in FTP_SERVER=$FTP_SERVER FTP_USERNAME=$FTP_USERNAME FTP_PASSWORD=$FTP_PASSWORD FTP_PATH=$FTP_PATH"
fi

if [ $DONE -gt 0 ]; then
	echo "We've attempted this before and should clean up files before trying this again"
	exit
else
	sed -i 's/DONE=0/DONE=1/' ./process_photos.cfg
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
	echo "in folder $NAME"
fi

## Handle teaser (first, so that the configured filename is correct)
# create teaser-resized photo - we'll rename it later
mkdir teaser
# These are MAXIMUM sizes. 180x120 is correct for Dan's camera
mogrify -path ./teaser -auto-orient -thumbnail 500x120 $TEASER
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

## Handle thumbs
# create "$name/thumbs"
mkdir thumbs

# create thumbnail-resized photos in "$name/thumbs/"
# These are MAXIMUM sizes. 240x160 is correct for Dan's camera
mogrify -path ./thumbs -auto-orient -thumbnail 1000x160 *.JPG

# rename all thumbnails to start with tn_
cd thumbs
for i in *.JPG ; do mv "$i" "tn_$i" ; done

if [ $V -gt 0 ]; then
	ls
fi

cd ..

##Handle creating 1000-wide resized photos
# create "$name/midsized"
mkdir midsized

# create midsized-resized photos in "$name/midsized/"
# These are MAXIMUM sizes. 1000x666 is correct for Dan's camera
mogrify -path ./midsized -auto-orient -thumbnail 1000x1000 *.JPG

# rename all midsized pics to start with m_ (while adding watermarks)
cd midsized
for i in *.JPG ; do composite -gravity SouthEast -geometry +10+0 $WATERMARK_IMAGE "$i" "m_$i"; done

if [ $V -gt 0 ]; then
	ls
fi
cd ..

# with all the other image sizes ready, we can add watermarks to the full-sized images
for i in $NAME*.JPG ; do composite -gravity SouthEast -geometry +10+0 $WATERMARK_IMAGE "$i" "$i"; done

## Move all the images back into the main directory to simplify uploading
# teaser (which also needs a rename here)
# move / rename teaser-resized photo teaser_$teaser
mv teaser/$TEASER teaser_$NAME$TEASER
for i in teaser_* ; do mv "$i" "${i/IMG/}" ; done
rm -rf teaser

# thumbs
cp thumbs/* ./
rm -rf thumbs

# midsized
cp midsized/m_* ./
rm -rf midsized


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
	for i in $NAME*.JPG ; do echo "<a href=\"javascript:galImage('/m_$i')\"><img src='/Imaging/stories/tn_$i' alt='m_${i/.JPG/}' border='0'></a>" ; done
else
	for i in $NAME*.JPG ; do echo "<a href=\"javascript:galImage('/$SUBFOLDER/m_$i')\"><img src='/Imaging/stories/$SUBFOLDER/tn_$i' alt='m_${i/.JPG/}' border='0'></a>" ; done

fi
echo "</p>"



## TODO
# automatically FTP all files to server, using $subfolder and FTP data
# Get new gallery viewer with configurable size options
  # adjust code generation to use the new viewer
#frontpage remake/cleanup?


