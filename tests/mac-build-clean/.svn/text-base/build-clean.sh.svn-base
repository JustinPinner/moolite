#! /bin/bash

if [ -d clean ]
then
	echo "Removing old copy."
	rm -rf clean
fi

echo "Checking out code."
svn co -q svn://svn.berlios.de/oolite-linux/trunk clean
if [ ! $? ]
then
	echo "Checkout FAILED."
	exit 1
fi


cd clean


PROJECT="Oolite.xcodeproj"
TARGET="Build All"
PRODUCT="Oolite"


function runbuild
{
	CONFIGURATION=$1
	EXTRA=$2
	if [ ! -z $EXTRA ]
	then
		EXTRA_STRING="-$EXTRA"
		EXTRA_STRING2=" with parameters $EXTRA"
	else
		EXTRA_STRING=""
		EXTRA_STRING2=""
	fi
	
	echo "Building $PROJECT target $TARGET in configuration $CONFIGURATION$EXTRA_STRING2..."
	xcodebuild -project "$PROJECT" -target "$TARGET" -configuration "$CONFIGURATION" -parallelizeTargets RUN_CLANG_STATIC_ANALYZER=NO $EXTRA > $"stdout-$PROJECT-$TARGET-$CONFIGURATION$EXTRA_STRING.txt" 2> $"stdout-$PROJECT-$TARGET-$CONFIGURATION$EXTRA_STRING.txt"
}


function moveresult
{
	CONFIGURATION=$1
	ARCH=$2
	ORIGNAME="build/$CONFIGURATION"
	NEWNAME="build/$CONFIGURATION-$ARCH"
	
	if [ -d $ORIGNAME ]
	then
		echo "Moving $ORIGNAME to $NEWNAME"
		mv "$ORIGNAME" "$NEWNAME"
	else
		echo "Cannot find $ORIGNAME"
	fi
}


function rundebugbuild
{
	ARCH=$1
	runbuild Debug "ARCHS=$ARCH"
	moveresult Debug $ARCH
}


rundebugbuild i386
rundebugbuild x86_64
runbuild TestRelease
runbuild Deployment
