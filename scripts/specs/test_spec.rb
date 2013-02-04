$:.unshift(File.dirname(__FILE__))
require "spec_helper"

describe "Test" do
  _ = eval_require("test.check")
  subject { _::Test.new(*opts) }

  describe "#as_json" do
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

    context "when fail option is given" do
      let(:opts) { %w(fail) }

      it "returns failure result" do
        subject.as_json[:result].should == false
      end
    end

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
end
