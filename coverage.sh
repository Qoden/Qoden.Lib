#!/bin/sh

PACKAGE=$1
if [ -z "$PACKAGE" ]; then
	echo "Usage: coverage.sh <package>"
	exit 1;
fi

if ! cd $PACKAGE/$PACKAGE.Test; then
	echo "$PACKAGE/$PACKAGE.Test" not found
	exit 1;
fi

if ! msbuild $PACKAGE.Test.csproj /p:Configuration=Debug ; then
	echo "Build failed"
	exit 1;
fi

# if [ -f "CodeCoverage.json" ]; then 
# 	echo "No CodeCoverage.json."
# 	exit 1;
# fi

# if ! mono SharpCover.exe instrument CodeCoverage.json ; then 
# 	echo "SharpCover instrumentation failed. Failed commad - 'mono SharpCover.exe instrument CodeCoverage.json'"
# 	exit 1;
# fi

NUNIT_CONSOLE=`which nunit-console4`
if [ -z "$NUNIT_CONSOLE" ]; then
	echo "nunit-console4 not found. Failed command 'which nunit-console4'";
	exit 1;
fi

MONO_OPTIONS=--profile=cov
if ! $NUNIT_CONSOLE bin/Debug/$PACKAGE.Test.dll ; then
	echo "NUnit test failed";
	exit 1;
fi

# if ! mono SharpCover.exe check > coverage.txt; then
# 	echo "SharpCover check failed. Failed command - 'mono SharpCover.exe check'"
# 	exit 1;
# fi