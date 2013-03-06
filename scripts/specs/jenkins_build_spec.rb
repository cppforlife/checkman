$:.unshift(File.dirname(__FILE__))
require "spec_helper"

describe_check :JenkinsJob, "jenkins_build" do
  # Branches must actually be ok/failing for these tests to pass
  it_returns_ok   %w(https://ci.jenkins-ci.org infra_changelog_refresh)
  it_returns_fail %w(https://ci.jenkins-ci.org libs_svnkit)
end
