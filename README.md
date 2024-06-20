<p align=center>
  <img src="https://github.com/jadenzaleski/SwiftLift/blob/main/logo.png" width="128" height="128">
  <h1 align=center>SwiftLift for iOS</h1>
</p>


<p align=center>
<img alt="GitHub Actions Workflow Status" src="https://img.shields.io/github/actions/workflow/status/jadenzaleski/SwiftLift/iOS-build.yml?style=for-the-badge&logo=GitHub">
<a href="https://testflight.apple.com/join/qlht1QKN"><img alt="Static Badge" src="https://img.shields.io/badge/Testflight-lightblue?style=for-the-badge&logo=apple&logoColor=white&color=186ec3"></a>
</p>

<p>
SwiftLift is a comprehensive fitness-tracking app designed to help you monitor your workouts, track progress, and stay motivated. The app features a simple, streamlined layout, provides detailed statistics, and is fully functional offline. SwiftLift aims to be <b>quick</b>, <b>easy</b>, and <b>free</b>, allowing you to focus on your workout without distractions. You can find the latest TestFlight version of SwiftLift <a href="https://testflight.apple.com/join/qlht1QKN">here</a>.
</p>

<p align=left>
<!--     <img alt="Github Created At" src="https://img.shields.io/github/created-at/jadenzaleski/SwiftLift?style=flat-square"> -->
<!--     <img alt="Github Commits" src="https://img.shields.io/github/commit-activity/t/jadenzaleski/SwiftLift?style=flat-square"> -->
    <img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/jadenzaleski/SwiftLift?style=flat-square">
<!--     <br> -->
    <img alt="GitHub Issues or Pull Requests" src="https://img.shields.io/github/issues/jadenzaleski/SwiftLift?style=flat-square">
    <img alt="GitHub Issues or Pull Requests" src="https://img.shields.io/github/issues-closed/jadenzaleski/SwiftLift?style=flat-square&color=lightGreen">
<!--     <br> -->
<!--     <img alt="GitHub Issues or Pull Requests" src="https://img.shields.io/github/issues-pr/jadenzaleski/SwiftLift?style=flat-square&color=yellow"> -->
<!--     <img alt="GitHub Issues or Pull Requests" src="https://img.shields.io/github/issues-pr-closed/jadenzaleski/SwiftLift?style=flat-square&color=lightGreen"> -->
<!--     <br> -->
    <img alt="GitHub Actions Workflow Status" src="https://img.shields.io/github/actions/workflow/status/jadenzaleski/SwiftLift/swiftlint.yml?style=flat-square&label=SwiftLint">
<!--     <br> -->
    <img alt="GitHub repo size" src="https://img.shields.io/github/repo-size/jadenzaleski/SwiftLift?style=flat-square&color=b50da1">
</p>

>[!Caution]
>This is a personal project in its early stages. I am open-sourcing it now to welcome contributors if this interests you. Please note that there are bugs, and there may be changes to the app that could render your recorded workout data unusable.
<hr>
<h3>Requirements</h3>
<ul>
  <li>iOS: 17.0+</li>
  <li>Xcode: 15.0+</li>
  <li>Swift: 5.9+</li>
</ul>
<hr>
<h3>Installation</h3>
<ol>
  <li>Clone the repository:
    <ul>
      <li><code>git clone https://github.com/jadenzaleski/SwiftLift.git</code></li>
    </ul>
  </li>
  <li>Navigate to your local repository:
    <ul>
      <li><code>cd SwiftLift</code></li>
    </ul>
  </li>
  <li>Open the project in Xcode:
    <ul>
      <li><code>open SwiftLift.xcodeproj</code></li>
    </ul>
  </li>
  <li>Build and run the app on your device or simulator.</li>
</ol>
<hr>
<h3>Contributing</h3>

<h4>Using Fork for Contributions</h4>

<ol>
  <li>Fork the repository by clicking the 'Fork' button on GitHub.</li>
  <li>Clone the forked repository to your local machine:
    <ul>
      <li><code>git clone https://github.com/your-username/SwiftLift.git</code></li>
    </ul>
  </li>
  <li>Create a new branch to work on your feature or bug fix:
    <ul>
      <li><code>git checkout -b feature/my-new-feature</code></li>
    </ul>
    Replace <code>my-new-feature</code> with a descriptive name that summarizes your feature or bug fix.
  </li>
  <li>Make your changes and commit them:
    <ul>
      <li><code>git add .</code></li>
      <li><code>git commit -m "Add your commit message here"</code></li>
    </ul>
  </li>
  <li>Push your changes to your fork:
    <ul>
      <li><code>git push origin feature/my-new-feature</code></li>
    </ul>
  </li>
  <li>Open a pull request on GitHub from your fork to the original repository's <code>main</code> branch.</li>
</ol>

<h4>Using Git Flow</h4>

<p>This project follows the Git Flow branching model. Here's a basic overview of how to use Git Flow:</p>

<ul>
  <li><strong>Initialize Git Flow</strong>: Run the following command to initialize Git Flow in your local repository:
    <ul>
      <li><code>git flow init</code></li>
    </ul>
    Follow the prompts to accept the default branch names unless you have specific preferences.
  </li>
  <li><strong>Start a Feature</strong>: To start working on a new feature, use the following command:
    <ul>
      <li><code>git flow feature start my-feature</code></li>
    </ul>
    Replace <code>my-feature</code> with a descriptive name for your feature. Naming convention: <code>feature/feature-name-here</code>.
  </li>
  <li><strong>Finish a Feature</strong>: When you're done with a feature, finish it to merge it back into <code>develop</code>:
    <ul>
      <li><code>git flow feature finish my-feature</code></li>
    </ul>
    This command will merge your feature branch into <code>develop</code> and remove the feature branch.
  </li>
</ul>

<p>For more details on Git Flow, refer to <a href="https://nvie.com/posts/a-successful-git-branching-model/" target="_blank">this guide</a>.</p>

<h4>Naming Conventions for Branches</h4>

<p>When creating branches, use the following naming conventions:</p>

<ul>
  <li><strong>Feature Branches</strong>: <code>feature/descriptive-feature-name</code></li>
  <li><strong>Release Branches</strong>: <code>release/version-number</code></li>
  <li><strong>Hotfix Branches</strong>: <code>hotfix/descriptive-fix-name</code></li>
  <li><strong>Support Branches</strong>: <code>support/descriptive-name</code></li>
  <li><strong>Version Tagging</strong>: Use meaningful tags for version releases.</li>
</ul>

<h4>Finishing the Contribution</h4>

<p>Once you've completed the above steps and your pull request is merged, your contribution will be reviewed and integrated into the main project.</p>

<p>Thank you for contributing to SwiftLift!</p>
<hr>
<h3>Activity</h3>
<img alt="stats" src="https://repobeats.axiom.co/api/embed/86f2ab22b543bf7ab5a2be344bb944b05753f303.svg" width=100%>


