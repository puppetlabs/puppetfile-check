# Example control repo with executable Puppetfile check

This repo is a skeleton control-repo. The script `scripts/codecheck.rb` will check a file for Ruby
code that's not expected in a `Puppetfile`. Configure a Gitlab CI job to run the script on pull requests
using the provided `.gitlab-ci.yml` as a starter example.
