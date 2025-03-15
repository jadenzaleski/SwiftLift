#!/bin/zsh
#
#  ci_post_xcodebuild.sh
#  SwiftLift
#
#  Created by Jaden Zaleski on 3/13/25.
#

if [[ -d "$CI_APP_STORE_SIGNED_APP_PATH" ]]; then
    TESTFLIGHT_DIR_PATH=../TestFlight
    mkdir $TESTFLIGHT_DIR_PATH
     # Fetch the latest merge commit message and append it to the build notes
    merge_commit_message=$(git fetch --deepen 1 && git log -1 --pretty=format:"%s")
    echo "Merge commit message: $merge_commit_message"
    echo -e "$merge_commit_message" >> $TESTFLIGHT_DIR_PATH/WhatToTest.en-US.txt
fi
