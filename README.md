# Example control repo with executable file check

This repo is a skeleton control-repo including checks for executable code that may be run
by the Puppet server. These files can be used in CI jobs to help ensure that executable code
is not committed to your control repository. 

## ⚠️ Please note that this does not prevent a malicious user from committing malicious Puppet code or malicious custom facts.

- `scripts/codecheck.rb` will check a file for Ruby code that's not expected in a `Puppetfile`.
- `scripts/no_config_version.sh` will ensure that the environment does not specify a [`config_version`](https://www.puppet.com/docs/puppet/latest/config_file_environment.html) setting.


## Usage:

### CI Configuration

If your workflow consists of developers working in their own fork of your control repository and contributing
changes as pull/merge requests then you should configure a CI job to prevent these from being merged when they
include executable code:

- GitLab:
  - Configure a CI job to run the scripts on merge requests using the provided `.gitlab-ci.yml` as a starter example.
- GitHub:
  - Configure a workflow to run the scripts on pull requests using the provided `.github/workflows/ci.yml` as a starter example.

### Server-side Hook Configuration

If your workflow grants developers the ability to create feature branches and contributing code directly,
then you will need to configure server `pre-receive` hooks to reject commits with executable code. Create
hooks for each of the files in the `scripts` directory.

- GitLab:
  - GitLab supports server side hooks only on **self-managed instances**.
  - Follow the [official GitLab instructions](https://docs.gitlab.com/ee/administration/server_hooks.html) to configure them.
- GitHub:
  - GitHub supports server side hooks only on **GitHub Enterprise**.
  - Follow the [official GitHub instructions](https://docs.github.com/en/enterprise-server@3.12/admin/policies/enforcing-policy-with-pre-receive-hooks/managing-pre-receive-hooks-on-your-instance#creating-pre-receive-hooks) to configure them.
