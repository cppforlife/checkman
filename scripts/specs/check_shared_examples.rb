module CheckSharedExamples
  def it_returns_ok(opts)
    context "when check indicates a success" do
      let(:opts) { opts }

      it "returns successful result" do
        subject.latest_status.as_json[:result].should == true
      end
    end
  end

  def it_returns_fail(opts)
    context "when check indicates a failure" do
      let(:opts) { opts }

      it "returns failure result" do
        subject.latest_status.as_json[:result].should == false
      end
    end
  end

  def it_returns_changing(opts)
    context "when check indicates changing" do
      let(:opts) { opts }

      it "returns changing result" do
        subject.latest_status.as_json[:changing].should == true
      end
    end
  end
end
