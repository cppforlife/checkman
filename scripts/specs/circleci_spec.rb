$:.unshift(File.dirname(__FILE__))
require "spec_helper"

describe_check :CircleCi do
  it_returns_ok   %w(dontfidget checkman ok 73e86a18efba7df5cfc5e03c4b67ff06685c5a75)
  it_returns_fail %w(dontfidget checkman failing 73e86a18efba7df5cfc5e03c4b67ff06685c5a75)
end
