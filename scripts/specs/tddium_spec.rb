$:.unshift(File.dirname(__FILE__))
require "spec_helper"

describe_check :TddiumJob, "tddium" do
  # Branches must actually be ok/failing for these tests to pass
  it { pending "no public account to put here..." }
  # it_returns_ok   ["placeholder_token", "project (ok)"]
  # it_returns_fail ["placeholder_token", "project (failing)"]
end
