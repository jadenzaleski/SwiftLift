<h1>Contribute to SwiftLift</h1>
<h3>Using Fork for Contributions</h3>

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

<h3>Using Git Flow</h3>

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

<h3>Naming Conventions for Branches</h3>

<p>When creating branches, use the following naming conventions:</p>

<ul>
  <li><strong>Feature Branches</strong>: <code>feature/descriptive-feature-name</code></li>
  <li><strong>Release Branches</strong>: <code>release/version-number</code></li>
  <li><strong>Hotfix Branches</strong>: <code>hotfix/descriptive-fix-name</code></li>
  <li><strong>Support Branches</strong>: <code>support/descriptive-name</code></li>
  <li><strong>Version Tagging</strong>: Use meaningful tags for version releases.</li>
</ul>

<h3>Finishing the Contribution</h3>

<p>Once you've completed the above steps and your pull request is merged, your contribution will be reviewed and integrated into the main project.</p>

<p>Thank you for contributing to SwiftLift!</p>
