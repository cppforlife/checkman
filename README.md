# Checkman

Checkman runs your custom script(s) periodically and then updates system tray icon status.
It could be used to check on CI build status, see that your site is up, etc.

# Configuration

Checkman is configured via one or more config files. To let Checkman know about a config file
just put it into `~/Checkman` directory. Here is an example of a config file:

    ci: jenkins_build.check https://ci:pwd@127.0.0.1/job/FancySite/lastBuild/api/json
    staging-deploy: jenkins_build.check https://ci:pwd@127.0.0.1/job/FancySiteDeploy/lastBuild/api/json

    #-
    staging-web: site.check http://fancysite.com

Above config file would result in 3 checks. To be continued...

# Thanks to

* Doc Ritezel
* Aram Price
