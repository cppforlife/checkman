$:.unshift(File.dirname(__FILE__))
require "spec_helper"

describe_check :Travis do
  it_returns_ok   %w(cppforlife checkman-travis-fixture master)
  it_returns_fail %w(cppforlife checkman-travis-fixture fail)
end
