# Checkman

Checkman runs your custom script(s) periodically and then updates system tray icon.
It could be used to check on CI build status, check site response status, etc.


# Installation

Install and open Checkman Mac app into `/Applications`:

    \curl https://raw.github.com/cppforlife/checkman/master/bin/install | bash -s

If you ever need to kill Checkman:

    killall Checkman


# Configuring Checkman via Checkfile(s)

* Configured via one or more files from `~/Checkman` directory.
  Checkfile example with 3 checks (very similar to Procfile):

    ```
    ci: jenkins_build.check https://ci:pwd@127.0.0.1/job/FancySite/lastBuild/api/json
    staging-deploy: jenkins_build.check https://ci:pwd@127.0.0.1/job/FancySiteDeploy/lastBuild/api/json

    #-
    staging-web: site.check http://fancysite.com
    ```

* Symlinks are resolved. Suggested approach is to have Checkfile with project
  specific checks in project directories and then symlink from `~/Checkman` directory.

* Config files are reloaded when changes are saved.

* Commands run relative to the containing checkfile.

* `#` can be used to comment. `#-` is used as a separator.


# Included scripts

* `site.check <URL>` checks returned http response for 200 OK

* `vmc_apps.check <DIR> <APP_PREFIX>` checks that all apps are running

* `jenkins_build.check <URL>` checks specific Jenkins build status


# Building custom checks

Each check is expected to return following JSON:

    ````
    {
      // Indicates whether check succeeded
      "result": <bool>,

      // Indicates whether result is in progress of being changed
      // e.g. CI build is in progress
      "changing": <bool>,
      
      // Url to open when check menu item is clicked
      "url": <string|null>,
      
      // List of additional details to show in the submenu
      "info": [
        [<string>, <string>] // Key-value pairs
      ]
    }
    ````

Check out included `scripts/` for examples.


# Todos

* Custom run intervals for individual checks
* Audit CPU/memory usage
* Fix jenkins_build.check to show last build status while build is in progress
* Indicate when check info was last updated
* Run only single instance of the app


# Thanks to

* Doc Ritezel
* Aram Price
