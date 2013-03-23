$:.unshift(File.dirname(__FILE__))
require "spec_helper"

describe_check :GithubIssues, "github_issues" do
  # There must be issues for these tests to pass
  it_returns_ok   %w(cppforlife checkman-travis-fixture)
  it_returns_fail %w(rails rails)
end
