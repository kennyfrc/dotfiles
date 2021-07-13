#!/bin/bash

if [[ $# -eq 0 ]]
then
	echo "No arguments passed. Try ./build.sh help"
elif [[ $1 = "help" ]]
then
	echo "Pass a project name to create a folder for it."
	echo "Example: ./build.sh sandbox"
else
	mkdir $1 &&
	cd $1 &&
	mkdir src &&
	mkdir test &&
	npm init &&
	npm install webpack webpack-cli --dev &&
	npm install @babel/core @babel/preset-env  &&
	npm install eslint @babel/eslint-parser &&
	npx eslint --init

	echo ""
	echo "Don't forget to set parser (@babel/eslint-parser),"
	echo "set parserOptions (sourceType: module), and"
	echo "set requireConfigFile to false in .eslintrc.json."
	echo ""
	echo "Further, add type: module in package.json"
fi
