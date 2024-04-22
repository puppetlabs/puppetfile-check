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
  - See a working [configuration example below](#gitlab-custom-server-side-hooks-config-example).
- GitHub:
  - GitHub supports server side hooks only on **GitHub Enterprise**.
  - Follow the [official GitHub instructions](https://docs.github.com/en/enterprise-server@3.12/admin/policies/enforcing-policy-with-pre-receive-hooks/managing-pre-receive-hooks-on-your-instance#creating-pre-receive-hooks) to configure them.

### Webhook Configuration

If you don't have the ability to configure CI jobs or server-side hooks, then you can stand up a webhook
server using your platform of choice. The webhook server should clone the repository and then run each of
the hook scripts in this repository or incorporate their functionality. Creating that webhook server is
beyond the scope of this guide, but you can find some guidance for your Git platform.

- GitLab
  - https://docs.gitlab.com/ee/user/project/integrations/webhooks.html
- GitHub
  - https://docs.github.com/en/webhooks
 
-------

## GitLab Custom Server-side Hooks Config example

This is provided without guarantee of suitability. It is a demonstration of the
[official GitLab instructions](https://docs.gitlab.com/ee/administration/server_hooks.html)
for configuring a `pre-receive` hook.

### Get Project info found in GitLab Project details in Admin section
Example:
```
Storage name: default
Relative path: @hashed/8b/94/8b940be7fb78aaa6b6567dd7a3987996947460df1c668e698eb92ca77e425349.git
```

### Create Tarball:
```
custom_hooks/pre-receive.d/codecheck.rb
custom_hooks/pre-receive.d/no_config_version.sh

tar -cf custom_hooks.tar custom_hooks
```

### Exec gitaly command to install webhook(s)
```
cat custom_hooks.tar | sudo /opt/gitlab/embedded/bin/gitaly hooks set --storage <storage> --repository <relative path> --config <config path>
```
Working Example:
```
cat /var/opt/gitlab/test/custom_hooks.tar | /opt/gitlab/embedded/bin/gitaly hooks set \
  --storage default \
  --repository @hashed/8b/94/8b940be7fb78aaa6b6567dd7a3987996947460df1c668e698eb92ca77e425349.git \
  --config /var/opt/gitlab/gitaly/config.toml
```

### Verification 

Check repo directory for existance of script
```
ls -la /var/opt/gitlab/git-data/repositories/@hashed/8b/94/8b940be7fb78aaa6b6567dd7a3987996947460df1c668e698eb92ca77e425349.git/custom_hooks
```

Run a test push to verify execution: 
Example:
```
PS C:\Users\paul\Documents\Code\test\test-pre> git push -v origin main
Pushing to https://gitlab.example.com/puppet/test-pre.git
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 24 threads
Compressing objects: 100% (2/2), done.
Writing objects: 100% (3/3), 299 bytes | 299.00 KiB/s, done.
Total 3 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
POST git-receive-pack (482 bytes)
remote: /var/opt/gitlab/git-data/repositories/@hashed/8b/94/8b940be7fb78aaa6b6567dd7a3987996947460df1c668e698eb92ca77e425349.git/custom_hooks/pre-receive.d/codecheck.rb:38:in `test': [
remote:   {
remote:     "name": "puts",
remote:     "count": 1
remote:   }
remote: ]
To https://gitlab.example.com/puppet/test-pre.git
 ! [remote rejected] main -> main (pre-receive hook declined)
error: failed to push some refs to 'https://gitlab.example.com/puppet/test-pre.git'
PS C:\Users\paul\Documents\Code\test\test-pre>

```


