#!/bin/bash
PROJECT=${PROJECT:-all}
CONFIG=${CONFIG:-Debug}
REPO=`pwd`/local.nugets
mkdir $REPO &> /dev/null
ROOT=`pwd`

if [ -z "$PROJECT" ]; then
	echo "rebuild.sh - rebuild and publish all Qoden libraries into local NuGet repo"
	echo "Usage: PROJECT=path-to-project-folder SUFFIX=optional-version-suffix CONFIG=build-config rebuild.sh"
	exit 1;
fi

function rebuild()
{	
	echo "=============== Building '$1' $CONFIG ==============="

	if ! cd $ROOT; then
		echo "Cannot 'cd $ROOT'";
		exit 1;
	fi

	if ! cd $1; then 
		echo "Error: '$1' not found";
		exit 1;
	fi

	if [ -z "$SUFFIX" ]; then
		local SUFFIX=b`git log --oneline | wc -l | tr -d ' '`
	fi

	if [[ "$1" == *iOS ]]; then	
		echo "Info: iOS project detected. Using 'msbuild' and 'nuget' instead of 'dotnet' ==============="	

		if ! nuget restore; then
			echo "Error: nuget restore '$1' failed. Make sure you use latest nuget 'nuget update -self'";
			exit 1;
		fi
		PACK_ARGS="-OutputDirectory bin/$CONFIG -Build -Properties Configuration=$CONFIG -Suffix $SUFFIX"
		if ! nuget pack $PACK_ARGS; then
			echo "Error: 'nuget pack $PACK_ARGS' failed"
			exit 1;
		fi
	else
		echo "Info: Normal project. Using 'dotnet' tools instead of 'msbuild' and 'nuget' ==============="	
		if ! dotnet restore; then
			echo "Error: dotnet restore '$1' failed";
			exit 1;
		fi
		PACK_ARGS="--version-suffix $SUFFIX -c $CONFIG"
		if ! dotnet pack $PACK_ARGS ; then
			echo "Error: 'dotnet pack --version-suffix $SUFFIX -c $CONFIG' in '$1' failed";
			exit 1;		
		fi
	fi

	if ! mv bin/$CONFIG/*.nupkg $REPO; then 
		echo "Cannot 'mv bin/$CONFIG/*.nupkg $REPO'"
		exit 1;
	fi
}

if [ "$PROJECT" == "all" ]; then
	if ! rebuild Qoden.Reflection/Qoden.Reflection; then exit 1; fi
	if ! rebuild Qoden.Format/Qoden.Format; then exit 1; fi
	if ! rebuild Qoden.Validation/Qoden.Validation; then exit 1; fi
	if ! rebuild Qoden.Binding/Qoden.Binding; then exit 1; fi
	if ! rebuild Qoden.UI/Qoden.UI; then exit 1; fi
	if ! rebuild Qoden.UI/Qoden.UI.iOS; then exit 1; fi
	if ! rebuild Qoden.SlideController/Qoden.SlideController.iOS; then exit 1; fi
	if ! rebuild Qoden.Calendar/Qoden.Calendar.iOS; then exit 1; fi
else
	rebuild "$PROJECT/$PROJECT"
fi