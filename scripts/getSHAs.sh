#!/usr/bin/env bash
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

TEST_ROOT=""
SHAs_FILE=""
workDIR=$(pwd)

usage ()
{
	echo 'This script use git command to get all shas in the provided TEST_ROOT and write the info into the SHAs file'
	echo 'Usage : '
	echo '                --test_root_dir: optional'
	echo '                --shas_file: optional, the file to write the sha info to. Default is to ../SHAs.txt'
}

parseCommandLineArgs()
{
	while [[ $# -gt 0 ]] && [[ ."$1" = .-* ]] ; do
		opt="$1";
		shift;
		case "$opt" in
			"--test_root_dir" | "-d" )
				TEST_ROOT="$1"; shift;;

			"--shas_file" | "-f" )
				SHAs_FILE="$1"; shift;;

			"--help" | "-h" )
				usage; exit 0;;

			*) echo >&2 "Invalid option: ${opt}"; echo "This option was unrecognized."; usage; exit 1;
		esac
	done
	if [ -z "$TEST_ROOT" ] || [ -z "$SHAs_FILE" ] || [ ! -d "$TEST_ROOT" ]; then
		echo "Error, please see the usage and also check if $TEST_ROOT exists"
		usage
		exit 1
	fi
}

timestamp()
{
	date +"%Y%m%d-%H%M%S"
}

getSHAs()
{
	echo "Check shas in $TEST_ROOT and store the info in $SHAs_FILE"
	if [ ! -e "${SHAs_FILE}" ]; then
		echo "touch $SHAs_FILE"
		touch "$SHAs_FILE"
	fi

	cd "$TEST_ROOT" || exit
	find "$TEST_ROOT" -type d -name ".git" | while read -r gitDir; do
		repoDir=$(dirname "$gitDir")
		cd "$repoDir" || continue
		# append the info into $SHAs_FILR
		{ echo "================================================"; echo "timestamp: $(timestamp)"; echo "repo dir: $repoDir"; echo "git repo: "; git remote show origin -n | grep "Fetch URL:"; echo "sha:"; git rev-parse HEAD; }  2>&1 | tee -a "$SHAs_FILE"
	done
}

parseCommandLineArgs "$@"
getSHAs
cd "$workDIR" || exit
