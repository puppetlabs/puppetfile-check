#! /bin/sh

# error if a config_version is set
grep -vz config_version environment.conf
