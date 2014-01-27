$:.unshift(File.dirname(__FILE__))
require "spec_helper"

describe_check :JenkinsJob, "jenkins_build" do
  # Branches must actually be ok/failing for these tests to pass

  context 'when using job specific api' do
    it_returns_ok   %w(https://ci.jenkins-ci.org infra_changelog_refresh --pretty-api)
    it_returns_fail %w(https://ci.jenkins-ci.org libs_svnkit)
  end

  context 'when using node specific api (includes multiple jobs)' do
    it_returns_ok   %w(https://ci.jenkins-ci.org infra_changelog_refresh --root-api)
    it_returns_fail %w(https://ci.jenkins-ci.org libs_svnkit             --root-api)
  end
end
