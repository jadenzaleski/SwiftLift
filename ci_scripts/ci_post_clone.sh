#!/bin/zsh
#
#  ci_post_clone.sh
#  SwiftLift
#
#  Created by Jaden Zaleski on 3/13/25.
#

echo "Hello World from ci_scripts/ci_post_clone.sh"

brew install swiftlint

echo "Attempting swiftlint --strict $CI_WORKSPACE_PATH"
swiftlint --strict $CI_WORKSPACE_PATH

