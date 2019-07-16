$:.unshift(File.dirname(__FILE__))
require "spec_helper"

jenkins_json = <<-JSON
{
  "_class" : "hudson.model.FreeStyleBuild",
  "actions" : [
    {
      "_class" : "hudson.model.CauseAction",
      "causes" : [
        {
          "_class" : "hudson.triggers.TimerTrigger$TimerTriggerCause",
          "shortDescription" : "Started by timer"
        }
      ]
    },
    {
      "_class" : "jenkins.metrics.impl.TimeInQueueAction",
      "blockedDurationMillis" : 0,
      "blockedTimeMillis" : 0,
      "buildableDurationMillis" : 551735,
      "buildableTimeMillis" : 551735,
      "buildingDurationMillis" : 1233622,
      "executingTimeMillis" : 1233622,
      "executorUtilization" : 1.0,
      "subTaskCount" : 0,
      "waitingDurationMillis" : 1,
      "waitingTimeMillis" : 1
    },
    {
      "_class" : "hudson.plugins.git.GitTagAction"
    },
    {
      "_class" : "hudson.plugins.jira.JiraBuildAction"
    },
    {
      "_class" : "hudson.tasks.junit.TestResultAction",
      "failCount" : 0,
      "skipCount" : 18,
      "totalCount" : 5520,
      "urlName" : "testReport"
    },
    {
      "_class" : "hudson.plugins.git.util.BuildData",
      "buildsByBranchName" : {
        "refs/remotes/origin/develop" : {
          "_class" : "hudson.plugins.git.util.Build",
          "buildNumber" : 1308,
          "buildResult" : null,
          "marked" : {
            "SHA1" : "92eb597e252c9116d7486c46a2cf90dc5239c6a3",
            "branch" : [
              {
                "SHA1" : "92eb597e252c9116d7486c46a2cf90dc5239c6a3",
                "name" : "refs/remotes/origin/develop"
              }
            ]
          },
          "revision" : {
            "SHA1" : "92eb597e252c9116d7486c46a2cf90dc5239c6a3",
            "branch" : [
              {
                "SHA1" : "92eb597e252c9116d7486c46a2cf90dc5239c6a3",
                "name" : "refs/remotes/origin/develop"
              }
            ]
          }
        }
      },
      "lastBuiltRevision" : {
        "SHA1" : "92eb597e252c9116d7486c46a2cf90dc5239c6a3",
        "branch" : [
          {
            "SHA1" : "92eb597e252c9116d7486c46a2cf90dc5239c6a3",
            "name" : "refs/remotes/origin/develop"
          }
        ]
      },
      "remoteUrls" : [
        "https://github.com/apache/geode.git"
      ],
      "scmName" : ""
    },
  ],
  "building" : false,
  "description" : null,
  "displayName" : "#1308",
  "duration" : 1233622,
  "estimatedDuration" : 1335509,
  "executor" : null,
  "fullDisplayName" : "Geode-nightly #1308",
  "id" : "1308",
  "keepLog" : false,
  "number" : 1308,
  "queueId" : 399563,
  "result" : "SUCCESS",
  "timestamp" : 1536120246717,
  "url" : "https://builds.apache.org/view/All/job/Geode-nightly/1308/",
  "builtOn" : "H15",
  "changeSet" : {
    "_class" : "hudson.plugins.git.GitChangeSetList",
    "items" : [
      {
        "_class" : "hudson.plugins.git.GitChangeSet",
        "affectedPaths" : [
          "geode-core/src/main/java/org/apache/geode/cache/client/internal/ClientMetadataService.java",
          "geode-core/src/main/java/org/apache/geode/internal/cache/CachePerfStats.java",
          "geode-core/src/main/java/org/apache/geode/cache/client/internal/SingleHopClientExecutor.java",
          "geode-core/src/distributedTest/java/org/apache/geode/internal/cache/PartitionedRegionSingleHopDUnitTest.java",
          "geode-core/src/distributedTest/java/org/apache/geode/internal/cache/execute/SingleHopGetAllPutAllDUnitTest.java"
        ],
        "commitId" : "72d393e649ecf0dfa73993187843bc135a47c516",
        "timestamp" : 1536076412000,
        "author" : {
          "absoluteUrl" : "https://builds.apache.org/user/bschuchardt",
          "fullName" : "bschuchardt"
        },
        "authorEmail" : "bschuchardt@pivotal.io",
        "comment" : "GEODE-5649 getAll() does not trigger client metadata refresh when\nprimary bucket not known\nIf the primary for a bucket was not known when creating one-hop tasks we \nwere not scheduling a metadata refresh.\nThese changes initiate a refresh but allow the current operation to \ncontinue as a non-single-hop operation.\nThis closes #2402\n",
        "date" : "2018-09-04 08:53:32 -0700",
        "id" : "72d393e649ecf0dfa73993187843bc135a47c516",
        "msg" : "GEODE-5649 getAll() does not trigger client metadata refresh when",
        "paths" : [
          {
            "editType" : "edit",
            "file" : "geode-core/src/main/java/org/apache/geode/cache/client/internal/ClientMetadataService.java"
          },
          {
            "editType" : "edit",
            "file" : "geode-core/src/distributedTest/java/org/apache/geode/internal/cache/PartitionedRegionSingleHopDUnitTest.java"
          },
          {
            "editType" : "edit",
            "file" : "geode-core/src/main/java/org/apache/geode/cache/client/internal/SingleHopClientExecutor.java"
          },
          {
            "editType" : "edit",
            "file" : "geode-core/src/distributedTest/java/org/apache/geode/internal/cache/execute/SingleHopGetAllPutAllDUnitTest.java"
          },
          {
            "editType" : "edit",
            "file" : "geode-core/src/main/java/org/apache/geode/internal/cache/CachePerfStats.java"
          }
        ]
      },
      {
        "_class" : "hudson.plugins.git.GitChangeSet",
        "affectedPaths" : [
          "ci/pipelines/geode-build/jinja.template.yml"
        ],
        "commitId" : "92eb597e252c9116d7486c46a2cf90dc5239c6a3",
        "timestamp" : 1536103289000,
        "author" : {
          "absoluteUrl" : "https://builds.apache.org/user/github",
          "fullName" : "github"
        },
        "authorEmail" : "noreply@github.com",
        "comment" : "GEODE-5212: new windows group on develop pipeline. (#2409)\n   Until builds are stable on Windows lets hide\n  the jobs on the main pipeline and move them to\n  a new group 'windows'\n",
        "date" : "2018-09-04 16:21:29 -0700",
        "id" : "92eb597e252c9116d7486c46a2cf90dc5239c6a3",
        "msg" : "GEODE-5212: new windows group on develop pipeline. (#2409)",
        "paths" : [
          {
            "editType" : "edit",
            "file" : "ci/pipelines/geode-build/jinja.template.yml"
          }
        ]
      }
    ],
    "kind" : "git"
  },
  "culprits" : [
    {
      "absoluteUrl" : "https://builds.apache.org/user/bschuchardt",
      "fullName" : "bschuchardt"
    },
    {
      "absoluteUrl" : "https://builds.apache.org/user/github",
      "fullName" : "github"
    }
  ]
}
JSON

describe_check :JenkinsJob, "jenkins_build" do
  # Branches must actually be ok/failing for these tests to pass
  before(:all) { WebMock.disable_net_connect! }
  after(:all) { WebMock.allow_net_connect! }

  before(:each) do
    WebMock.stub_request(:get, "https://builds.apache.org/view/All/job/Geode-nightly/lastBuild/api/json?pretty=true").
      to_return(:status => 200, :body => jenkins_json, :headers => {})
  end

  context 'when using job specific api' do
    it_returns_ok   %w(https://builds.apache.org Geode-nightly --pretty-api)
    it_returns_fail %w(https://builds.apache.org Giraph-1.2)
  end

  context 'when using node specific api (includes multiple jobs)' do
    it_returns_ok   %w(https://builds.apache.org Geode-nightly --root-api)
    it_returns_fail %w(https://builds.apache.org Giraph-1.2 --root-api)
  end
end
