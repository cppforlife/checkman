# Checkman

[![Build Status](https://travis-ci.org/cppforlife/checkman.png?branch=master)](https://travis-ci.org/cppforlife/checkman)

Checkman runs your custom script(s) periodically and then updates system tray
icon. It could be used to check on CI build status, site http response, etc.

![](https://raw.github.com/cppforlife/checkman/master/screenshots/checkman.jpg)


# Installation

Install and open Checkman Mac app into `/Applications`
(backslash is for [overriding possible bash alias](http://en.wikipedia.org/wiki/Alias_\(command\)#Overriding_aliases)):

    \curl https://raw.githubusercontent.com/cppforlife/checkman/master/bin/install | bash -s

If you ever need to kill Checkman:

    killall Checkman


# Configuring Checkman via Checkfile(s)

* Any number of config files in `~/Checkman` directory

* Each config file can define any number of checks. Each check definition takes
  up a single line made of a name and a valid bash command separated by
  colon-space. Example checkfile with 3 checks:

    ```
    google.com: site.check http://www.google.com

    #-
    #- jenkins-ci.org builds
    jenkins_main_trunk: jenkins_build.check https://ci.jenkins-ci.org jenkins_main_trunk
    jenkins_lts_branch: jenkins_build.check https://ci.jenkins-ci.org jenkins_lts_branch
    ```

* Commands run relative to the containing checkfile.

* Symlinks are resolved. Suggested approach is to have per-project Checkfile
  with project specific checks and symlink to them from `~/Checkman` directory.
  e.g. `ln -s ~/workspace/my-project/Checkfile ~/Checkman/my-project`

* Hidden config files (prefixed with `.`) are skipped.

* Config files are reloaded when changes are saved.

* `#` can be used to comment.

* `#-` is used as a separator.

* `#- Some title` is used as a title separator.

* Tip: works great with `tee` to keep check's history
  e.g. `site.check http://site.com | tee -a tmp/site.log`


# Included check scripts

* `site.check <URL>`  
  checks returned http response for 200 OK  
  e.g. `site.check http://www.google.com`

* `cctray.check https://user:pass@<CCTRAY_URL> <PIPELINE_NAME>`  
  checks the status of a GoCD pipeline  
  e.g. `cctray.check https://admin:badger@[your_go_server]/go/cctray.xml`

* `concourse.check <ATC_URL> [USERNAME] [PASSWORD] <PIPELINE_NAME> <JOB_NAME>`  
  checks status of a job in a [Concourse](http://concourse.ci) pipelne
  e.g. `concourse.check https://ci.concourse.ci admin passw0rd deploy`  

* `jenkins_build.check <JENKINS_URL> <JOB_NAME>`  
  checks specific Jenkins build status  
  e.g. `jenkins_build.check https://user:pass@ci.jenkins-ci.org jenkins_main_trunk`  
  (Tip: Encode `@` symbol as `%40` in username)

* `travis.check <REPO_OWNER> <REPO_NAME> [<REPO_BRANCH>] [<REPO_TOKEN>]`  
  checks specific Travis CI build status  
  e.g. `travis.check rails arel`

* `semaphore.check <PROJECT_API_ID> <BRANCH_ID> <AUTH_TOKEN>`  
  checks specific SemaphoreApp CI build status  
  e.g. `semaphore.check 0691ba134341d1baa978436535b6f2b79fec91 27680 1iGx6asGJHk6aMdsB4eu`  
  (Tip: open project's settings page, then find the "API" tab to get required ids)
  
* `codeship.check <PROJECT_ID> <API_KEY> <REPO_BRANCH>`  
  checks specific Codeship CI build status  
  e.g. `codeship.check 12345 0ea7bbedf3340775cecee5f816d03bdfac69c81f816d03bdfac69c81fqw2 master`  
  (Tip: find the API_KEY under account settings)

* `circleci.check <USERNAME> <PROJECT_NAME> <BRANCH_NAME> <API_TOKEN>`  
  checks specific Circle CI build status  
  e.g. `circleci.check myusername myproject master 73e86a18efba7df5cfc5e03c4b67ff06685c5a75`  
  (Tip: open project's setting page, then find the "API Tokens" tab to create an API token of type 'status' or 'all')

* `circlecijson.check <USERNAME> <PROJECT_NAME> <BRANCH_NAME> <API_TOKEN>`  
  checks specific Circle CI build status using the JSON interface which provides build time data  
  e.g. `circlecijson.check myusername myproject master 6cadaa96f7c455a658e00dd4500adc8f654342cc`  
  (Tip: open project's setting page, then find the "API Tokens" tab to create an API token of type 'all')

* `test.check <OPTION_0> ... <OPTION_N>` returns predefined check result  
  (options: url, info, fail, changing, slow, error, flapping)  
  e.g. `test.check fail slow`

* `airbrake.check <ACCOUNT_NAME> <API_TOKEN> <PROJECT_ID>`  
  checks for recent errors  
  e.g. `airbrake.check my-company 2a743rueigw87tegiofs7g 43878087`

* `github_issues.check <REPO_OWNER> <REPO_NAME>`  
  checks for issues in GitHub repo  
  e.g. `github_issues.check rails rails`  
  (Tip: Since GitHub rate limits api requests set
  `GITHUB_ISSUES_CHECK_CLIENT_ID` and `GITHUB_ISSUES_CHECK_CLIENT_SECRET`.
  See [check's code](scripts/github_issues.check) on how to obtain client id/secret.)

* `tracker.check <PROJECT_ID> <API_KEY> <FULL USER NAME>`    
  Checks for your owned story statuses in Tracker, requires the [Pivotal Tracker Gem](https://github.com/jsmestad/pivotal-tracker).    
  e.g `tracker.check 1234 ABC123 Trent Beatie`
  * **Green:** You don't own any rejected stories
  * **Red:** You own a rejected story
  * **Pending:** You haven't started a story

* `tddium.check <ORGANIZATION_TOKEN> <PROJECT_NAME> <BRANCH_NAME>`  
  Checks specific TDDium project build status.  
  e.g. `tddium.check 0691ba134341d1baa978436535b6f2b79fec91 project branch_name`  
  Hint: to get the token, log in to your TDDium dashboard, go to Organizations using the
  drop down in the top right corner. Then click on organization settings for the
  appropriate organization. Then click on "Chat Notifications"; CCmenu is at the
  bottom of the page. Extract the token from the URL, which looks like:
  `https://api.tddium.com/cc/ORGANIZATION_TOKEN/cctray.xml`

* `snapci.check <URL TO CCTRAY FEED> "<PROJECT NAME>" "<STEP NAME>"`  
  Checks the build status of a specific step in Snap CI  
  e.g. `snapci.check https://snap-ci.com/some-random-hash/cctray.xml "my-github-org/my-repo (branch-name)" "MyStepInSnapCi"`  
  To get the PROJECT NAME, look at the CCTray XML and paste in the value before the ` :: ` from `<Project name="">`  
  To get the STEP NAME, look at the CCTray XML and paste in the value after the ` :: ` from `<Project name="">`

Above scripts are located in `/Applications/Checkman.app/Contents/Resources/`.
Checkman makes these scripts available by appending stated path to PATH env
variable when running check commands.


# Building custom check scripts

Each check is expected to output following JSON to `stdout`:

    {
      // [Required]
      // Indicates whether check succeeded
      "result": <bool>,

      // [Optional]
      // Indicates whether result is in progress of being changed
      // e.g. CI build is in progress
      "changing": <bool>,

      // [Optional]
      // Url to open when check menu item is clicked
      "url": <string|null>,

      // [Optional]
      // List of additional details to show in the submenu
      "info": [
        [<string>, <string>] // Key-value pairs
      ]
    }

You can print anything to `stderr`. Check out included `scripts/` for examples.


## Debugging

* `Option + click` check menu item - open check's debugging window.
  Shown command/stderr/stdout will be updated as time passes. Refer to
  [Debugging Tips](https://github.com/cppforlife/checkman/wiki/Debugging-Tips)
  wiki page for more tips.

* `Control + click` check menu item - restart check run.


# Stickies and notifications

* Stickies: mini alert per check appears in right bottom corner if check turns
  red. Alert disappear when check turns back to green. Stickies are enabled
  by default.

* Notifications: there are 3 supported notification transports: built-in,
  Growl and OS X Notification Center. See 'Custom user settings' section on how
  to enable notifications.


# Custom user settings

Change run interval for all/single check(s) (where INTERVAL is integer > 0):

    defaults write com.tomato.Checkman checkRunInterval -int <INTERVAL>
    defaults write com.tomato.Checkman checks.<CHECKFILE>.<CHECK>.runInterval -int <INTERVAL>

Disable single check:

    defaults write com.tomato.Checkman checks.<CHECKFILE>.<CHECK>.disabled -bool YES

Disable stickies:

    defaults write com.tomato.Checkman stickies.disabled -bool YES

Enable notification transports:

    defaults write com.tomato.Checkman notifications.custom.enabled -bool YES
    defaults write com.tomato.Checkman notifications.growl.enabled -bool YES
    defaults write com.tomato.Checkman notifications.center.enabled -bool YES

View all current customizations:

    defaults read com.tomato.Checkman

Delete specific customization:

    defaults delete com.tomato.Checkman <SETTING>

Note: CHECKFILE is checkfile name before symlinks are resolved.


# Todos

* Audit CPU/memory usage
* Find permanent status images
* Run only single instance of the app
* Indicate when check info was last updated
* Limit number of checks running concurrently


# Thanks to

* Doc Ritezel
* Aram Price
* James Bayer
