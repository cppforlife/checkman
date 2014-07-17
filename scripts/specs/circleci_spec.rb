$:.unshift(File.dirname(__FILE__))
require "spec_helper"

describe_check :CircleCi do
  it_returns_ok   %w(dontfidget checkman ok b9d9d7b0d01aac556a9d66f4afb4cadac965c20e)
  it_returns_fail %w(dontfidget checkman failing b9d9d7b0d01aac556a9d66f4afb4cadac965c20e)
end
