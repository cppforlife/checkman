# Checkman

Checkman runs your custom script(s) periodically and then updates system tray icon.
It could be used to check on CI build status, check site response status, etc.


# Installation

Install and open Checkman Mac app into `/Applications`
(backslash is for [overriding possible bash alias](http://en.wikipedia.org/wiki/Alias_(command\)#Overriding_aliases)):

    \curl https://raw.github.com/cppforlife/checkman/master/bin/install | bash -s

If you ever need to kill Checkman:

    killall Checkman


# Configuring Checkman via Checkfile(s)

* Configured via one or more files from `~/Checkman` directory.
  Checkfile example with 3 checks (very similar to Procfile):

    ```
    ci: jenkins_build.check https://ci:pwd@127.0.0.1 FancySite
    staging-deploy: jenkins_build.check https://ci:pwd@127.0.0.1 FancySiteDeploy

    #-
    staging-web: site.check http://fancysite.com
    ```

* Symlinks are resolved. Suggested approach is to have Checkfile with project
  specific checks in project directories and then symlink from `~/Checkman` directory.

* Config files are reloaded when changes are saved.

* Commands run relative to the containing checkfile.

* `#` can be used to comment. `#-` is used as a separator.

* Works great with `tee` to keep check's history
  e.g. `site: site.check http://site.com | tee -a tmp/site.log`


# Included scripts

* `site.check <URL>` checks returned http response for 200 OK

* `vmc_apps.check <CC_TARGET_URL> <SPACE_ID> <APP_PREFIX>` checks that all apps are running

* `jenkins_build.check <JENKINS_URL> <JOB_NAME>` checks specific Jenkins build status

* `test.check <RESULT> <CHANGING>` returns predefined result/changing

* `airbrake.check <ACCOUNT_NAME> <API_TOKEN> <PROJECT_ID>` checks for recent errors


# Building custom checks

Each check is expected to return following JSON:

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

Check out included `scripts/` for examples.


# Custom user settings

Change default 10 sec run interval for all checks:

    defaults write com.tomato.Checkman checkRunInterval -int 20


# Todos

* Audit CPU/memory usage
* Run only single instance of the app
* Indicate when check info was last updated
* Find permanent status images


# Thanks to

* Doc Ritezel
* Aram Price
