$:.unshift(File.dirname(__FILE__))
require "spec_helper"

describe_check :JenkinsJob, "jenkins_build" do
  # Branches must actually be ok/failing for these tests to pass

  context 'when using job specific api' do
    it_returns_ok   %w(https://builds.apache.org Geode-nightly --pretty-api)
    it_returns_fail %w(https://builds.apache.org Giraph-1.2)
  end

  context 'when using node specific api (includes multiple jobs)' do
    it_returns_ok   %w(https://builds.apache.org Geode-nightly --root-api)
    it_returns_fail %w(https://builds.apache.org Giraph-1.2 --root-api)
  end
end
