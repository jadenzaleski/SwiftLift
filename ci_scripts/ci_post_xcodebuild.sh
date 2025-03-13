#!/bin/bash
#
#  ci_post_xcodebuild.sh
#  SwiftLift
#
#  Created by Jaden Zaleski on 3/13/25.
#

echo "Hello World from ci_scripts/ci_post_xcodebuild.sh"

if [[ -d "$CI_APP_STORE_SIGNED_APP_PATH" ]]; then
    echo "in the if loop"
    TESTFLIGHT_DIR_PATH=../TestFlight
    mkdir $TESTFLIGHT_DIR_PATH
    git fetch --deepen 3 && git log -3 --pretty=format:"%s" | cat > $TESTFLIGHT_DIR_PATH/WhatToTest.en-US.txt
fi


