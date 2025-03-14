#!/bin/zsh
#
#  ci_post_clone.sh
#  SwiftLift
#
#  Created by Jaden Zaleski on 3/13/25.
#

echo "Hello World from ci_scripts/ci_post_clone.sh"

# Install swiftlint so it can be used in a build phase
brew install swiftlint

# Make sure it installed correctly
swiftlint --version
