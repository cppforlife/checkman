$:.unshift(File.dirname(__FILE__))
require "spec_helper"

describe_check :Site do
  it_returns_ok %w(http://www.google.com)

  # Google's non-www version redirects to www
  it_returns_fail %w(http://google.com)
end
