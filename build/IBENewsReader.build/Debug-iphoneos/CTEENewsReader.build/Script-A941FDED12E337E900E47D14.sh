#!/bin/sh
# compress application.

/bin/mkdir $CONFIGURATION_BUILD_DIR/Payload

/bin/cp -R $CONFIGURATION_BUILD_DIR/IBENewsReader.app $CONFIGURATION_BUILD_DIR/Payload

/bin/cp images/tabbaricon/about.png $CONFIGURATION_BUILD_DIR/iTunesArtwork

cd $CONFIGURATION_BUILD_DIR

# zip up the HelloWorld directory

/usr/bin/zip -r CTEENewsReader.ipa Payload iTunesArtwork
