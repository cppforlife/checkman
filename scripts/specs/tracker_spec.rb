$:.unshift(File.dirname(__FILE__))
require "spec_helper"

describe_check :Tracker, "tracker" do
  it_returns_ok %w(829747 00bedcc48d3d8484e244dbad6bf8941c Checkman OK)
  it_returns_changing %w(829747 07ebaa44be590bf33b93a9b8c059db63 Checkman Changing)
  it_returns_fail %w(829747 213d9b96fa4dbd9a0cf04b3fe8b34f82 Checkman Failing)
end
