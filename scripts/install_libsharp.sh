#!/usr/bin/env bash

if [ "$(uname)" == "Darwin" ]; then
	brew install clang-omp # anticipating gcc issues
fi


DEPDIR=_deps
[ -e $DEPDIR ] || mkdir $DEPDIR
cd $DEPDIR
[ -e libsharp ] || git clone https://github.com/Libsharp/libsharp # do we want a frozen version?
cd libsharp
aclocal
if [ $? -eq 0 ]; then
    echo Found automake.
else
	if [ "$(uname)" == "Darwin" ]; then
		echo WARNING: automake not found. Since this looks like Mac OS, attempting to install it.
		brew install autoconf automake
		if [ $? -eq 0 ]; then
			echo
		else
			echo "NOTE: You might need to enter your user password since we are going to attempt to install homebrew."
			ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
			brew install autoconf automake
		fi
		aclocal
	elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
		echo WARNING: automake not found. Since this looks like Linux, attempting to load its module.
		module load autotools
		aclocal
	fi
	if [ $? -eq 0 ]; then
		echo Found automake.
	else
		echo WARNING: automake not found. Please install this or libsharp will not be installed correctly.
		exit 127
	fi
fi
autoconf
./configure --enable-pic
make
if [ $? -eq 0 ]; then
    echo Successfully installed libsharp.
	touch success.txt
else
	echo ERROR: Libsharp did not install correctly.
	exit 127
fi
rm -rf python/
