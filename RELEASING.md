# Project releases

This repository releases top-level projects independently. A project opts in by providing a `.release/build.sh` script inside its directory.

The shared `.github/workflows/release.yml` workflow runs after a commit reaches `main`. It discovers releasable projects, checks which project directories changed in that push, and releases the affected projects concurrently. Releases for the same project are serialized so two nearby merges cannot choose the same version.

## Versioning

Each project has its own semantic-version sequence. Tags use this format:

```text
<project>_<major>.<minor>.<patch>
```

The first release is `1.0.0`. After that, a project change produces a patch release by default. Put `#minor` or `#major` in a commit subject or body to select the corresponding bump. If a push contains several commits for a project, the largest requested bump wins.

For example:

```text
battery_monitor_1.0.0
battery_monitor_1.0.1
battery_monitor_1.1.0
```

Version calculation uses `PaulHatch/semantic-version` with the project directory as `change_path`, so tags and history for one project do not advance another project's version.

## Project release hook

A project's `.release/build.sh` receives two arguments:

```text
build.sh <version> <asset-directory>
```

The script may generate, compile, or package whatever that project needs. It must write one or more regular files directly into the asset directory. The shared workflow attaches those files to the GitHub Release with `softprops/action-gh-release`.

Generated release files belong in the runner's temporary asset directory, not in git. This keeps generated output out of normal commits while still giving users a ready-to-use release.

## Manual release

The workflow also supports `workflow_dispatch`. Supply the top-level project directory name. A manual run publishes only when that project has changed since its previous release.
