#!/bin/bash
#
# build.sh - install script for vrms-rpm
# Copyright (C) 2017 Artur "suve" Iwicki
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 3,
# as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program (LICENCE.txt). If not, see <http://www.gnu.org/licenses/>.
#

# Treat unitiliased variables as errors
set -u

# Set default values for vars
mode="build"
prefix=""

while [ $# -gt 0 ]; do
	case $1 in
		build)
			mode="build"
		;;

		install)
			mode="install"
		;;

		remove)
			mode="remove"
		;;
		
		--prefix)
			if [ "$#" -lt 2 ]; then
				echo "The --prefix option requires an argument"
			fi
			prefix="$2"
		;;

		*)
			echo "Unrecognized argument: '$1'"
			echo "Supported modes: 'build', 'install', 'remove'"
			echo "Supported options: --prefix"
			exit
		;;
	esac
	shift
done	


if [ "$mode" == "build" ]; then
	if [ -d "build" ]; then
		rm -rf build/
	fi
	mkdir -p build/ build/locale/

	po_languages=`ls lang/*.po`
	for po_lang in $po_languages; do
		
		# Remove the dir name and .po extension from variable
		po_lang=${po_lang##*/}
		po_lang=${po_lang%\.po}

		po_langdir="build/locale/$po_lang/LC_MESSAGES/"
		mkdir -p "$po_langdir"
		
		msgfmt --check -o "$po_langdir/vrms-rpm.mo" "lang/$po_lang.po"
		if [ "$?" -ne 0 ]; then
			exit
		fi

		echo "Created .mo file for: '$po_lang'"
	done	
elif [ "$mode" == "install" ]; then
	install -v -p -m 755 src/vrms-rpm.sh "$prefix/usr/bin/vrms-rpm"
	
	install -v -m 755 -d "$prefix/usr/share/suve/vrms-rpm/"
	install -v -m 644 src/good-licences.txt "$prefix/usr/share/suve/vrms-rpm/"

	cp -vR build/locale/ "$prefix/usr/share/suve/vrms-rpm/"

	man_languages=`ls man/*.man`
	for man_lang in $man_languages; do
		
		# Remove the dir name and .man extension from variable
		man_lang=${man_lang##*/}
		man_lang=${man_lang%\.man}

		if [ "$man_lang" == "en" ]; then
			man_langdir="$prefix/usr/share/man/man1"
		else
			man_langdir="$prefix/usr/share/man/$man_lang/man1"
		fi

		install -v -m 755 -d  "$man_langdir"
		install -v -p -m 644 "man/$man_lang.man" "$man_langdir/vrms-rpm.1"
	done
elif [ "$mode" == "remove" ]; then
	rm -v "$prefix/usr/bin/vrms-rpm"
	rm -v -rf "$prefix/usr/share/suve/vrms-rpm"
	find "$prefix/usr/share/man" -name 'vrms-rpm.1*' -delete
fi
