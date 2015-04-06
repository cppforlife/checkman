$:.unshift(File.dirname(__FILE__))
require "spec_helper"

describe_check :TddiumJob, "tddium" do
  pending "trial account expired"
  # Branches must actually be ok/failing for these tests to pass
  # it_returns_ok   %w(4ee7ab3c716d0d0703901410dca129f85fef40eb checkman ok)
  # it_returns_fail %w(4ee7ab3c716d0d0703901410dca129f85fef40eb checkman failing)
end
