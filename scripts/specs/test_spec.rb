$:.unshift(File.dirname(__FILE__))
require "spec_helper"

describe_check :Test do
  context "when no options are provided" do
    let(:opts) { %w() }

    it "returns successful result" do
      subject.as_json[:result].should == true
    end

    it "returns non-changing result" do
      subject.as_json[:changing].should == nil
    end

    it "does not return url" do
      subject.as_json[:url].should be_nil
    end

    it "does not return info" do
      subject.as_json[:info].should be_nil
    end
  end

  it_returns_fail %w(fail)

  context "when changing option is given" do
    let(:opts) { %w(changing) }

    it "returns changing result" do
      subject.as_json[:changing].should == true
    end
  end

  context "when url option is given" do
    let(:opts) { %w(url) }

    it "returns url" do
      subject.as_json[:url].should match %r{http://}
    end
  end

  context "when info option is given" do
    let(:opts) { %w(info) }

    it "returns info" do
      subject.as_json[:info].should be_an(Array)
    end
  end
end
