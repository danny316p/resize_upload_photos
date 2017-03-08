#!/bin/bash

#Load config file as variables
# read in a config file specifying FTP data, $teaser (name of teaser image), $name (prepend string for filenames), $subfolder (if applicable - such as "Toy_Fair_2017")

source ./process_photos.cfg

if [ $V -gt 0 ]; then
	echo "loaded in NAME=$NAME TEASER=$TEASER SUBFOLDER=$SUBFOLDER V=$V DONE=$DONE"
	echo "loaded in FTP_SERVER=$FTP_SERVER FTP_USERNAME=$FTP_USERNAME FTP_PASSWORD=$FTP_PASSWORD FTP_PATH=$FTP_PATH"
fi

if [ $DONE -gt 0 ]; then
	echo "We've attempted processing photos before and should clean up files before trying that again"

	echo "removing files"
	rm -r $NAME

	echo "resetting DONE flag"
	sed -i 's/DONE=1/DONE=0/' ./process_photos.cfg 
else
	echo "The DONE flag is already clear. Set it > 0 if you need to clean the directory"
	exit
fi



