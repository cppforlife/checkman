$:.unshift(File.dirname(__FILE__))
require "spec_helper"

describe_check :CCTray, "cctray" do
  cctray_xml = <<-XML
<Projects>
  <Project name="goodPipe :: successfulStage" activity="Sleeping" lastBuildStatus="Success" lastBuildLabel="145" lastBuildTime="2014-06-25T17:46:42" webUrl="http://www.gocd.cf-app.com/go/pipelines/Acceptance/145/provision/1" />
  <Project name="goodPipe :: successfulStage :: reliablyExcellentJob" activity="Sleeping" lastBuildStatus="Success" lastBuildLabel="145" lastBuildTime="2014-06-25T18:55:27" webUrl="http://www.gocd.cf-app.com/go/tab/build/detail/Acceptance/145/promote/1/tag" />

  <Project name="goodPipe :: busyStage" activity="Building" lastBuildStatus="Success" lastBuildLabel="145" lastBuildTime="2014-06-25T17:46:42" webUrl="http://www.gocd.cf-app.com/go/pipelines/Acceptance/145/provision/1" />
  <Project name="goodPipe :: busyStage :: workingJob" activity="Building" lastBuildStatus="Success" lastBuildLabel="145" lastBuildTime="2014-06-25T17:46:42" webUrl="http://www.gocd.cf-app.com/go/pipelines/Acceptance/145/provision/1" />

  <Project name="aBadPipeline :: aBrokenStage" activity="Sleeping" lastBuildStatus="Failure" lastBuildLabel="145" lastBuildTime="2014-06-25T17:46:42" webUrl="http://www.gocd.cf-app.com/go/pipelines/Acceptance/145/provision/1" />
  <Project name="aBadPipeline :: aBrokenStage :: anEvilJob" activity="Sleeping" lastBuildStatus="Failure" lastBuildLabel="145" lastBuildTime="2014-06-25T18:55:27" webUrl="http://www.gocd.cf-app.com/go/tab/build/detail/Acceptance/145/promote/1/tag" />

  <Project name="Pipeline :: SomeStage" activity="Building" lastBuildStatus="Success" lastBuildLabel="1" lastBuildTime="2015-12-25T17:46:42" webUrl="http://www.example.com/go/pipelines/Acceptance/145/provision/1" />
  <Project name="Pipeline :: SomeStage :: job" activity="Sleeping" lastBuildStatus="Success" lastBuildLabel="1" lastBuildTime="2015-12-25T17:46:42" webUrl="http://www.example.com/go/pipelines/Acceptance/145/provision/1" />
  <Project name="Pipeline :: SomeStage :: jobWorking" activity="Building" lastBuildStatus="Success" lastBuildLabel="1" lastBuildTime="2015-12-25T17:46:42" webUrl="http://www.example.com/go/pipelines/Acceptance/145/provision/1" />

  <Project name="Pipeline :: OtherStage" activity="Sleeping" lastBuildStatus="Success" lastBuildLabel="1" lastBuildTime="2015-12-25T17:46:42" webUrl="http://www.example.com/go/pipelines/Acceptance/145/provision/1" />
  <Project name="Pipeline :: OtherStage2" activity="Building" lastBuildStatus="Success" lastBuildLabel="1" lastBuildTime="2015-12-25T17:46:42" webUrl="http://www.example.com/go/pipelines/Acceptance/145/provision/1" />

  <Project name="Pipeline_1.0 :: SomeStage" activity="Building" lastBuildStatus="Success" lastBuildLabel="1" lastBuildTime="2015-12-25T17:46:42" webUrl="http://www.example.com/go/pipelines/Acceptance/145/provision/1" />
  <Project name="Pipeline_2.0 :: SomeStage" activity="Building" lastBuildStatus="Failure" lastBuildLabel="1" lastBuildTime="2015-12-25T17:46:42" webUrl="http://www.example.com/go/pipelines/Acceptance/145/provision/1" />
</Projects>
  XML

  before(:all) { WebMock.disable_net_connect! }
  after(:all) { WebMock.allow_net_connect! }

  before(:all) do
    WebMock.stub_request(:get, "http://cd-server.example.com/cctray.xml").
      to_return(:status => 200, :body => cctray_xml, :headers => {})

    WebMock.stub_request(:get, "http://username77:passw0rd@cd-server.example.com/cctray.xml").
      to_return(:status => 200, :body => cctray_xml, :headers => {})
  end

  context 'when using pipeline specific api' do
    it_returns_ok   %w(http://cd-server.example.com/cctray.xml goodPipe)
    it_returns_fail %w(http://cd-server.example.com/cctray.xml aBadPipeline)
    it_returns_changing %w(http://cd-server.example.com/cctray.xml goodPipe)

    context 'when it matches some pipeline names fully' do
      it_returns_ok   %w(http://cd-server.example.com/cctray.xml Pipeline)
    end

    context 'when it does not match any pipeline name fully' do
      it_returns_fail %w(http://cd-server.example.com/cctray.xml Pipeline_)
    end
  end

  context 'when using stage specific api' do
    it_returns_ok   %w(http://cd-server.example.com/cctray.xml goodPipe successfulStage)
    it_returns_fail %w(http://cd-server.example.com/cctray.xml aBadPipeline aBrokenStage)
    it_returns_changing %w(http://cd-server.example.com/cctray.xml goodPipe busyStage)

    context 'when it matches some pipeline and job name fully' do
      context "when check does not indicate changing" do
        let(:opts) { %w(http://cd-server.example.com/cctray.xml Pipeline OtherStage) }

        it "does not return changing result" do
          subject.latest_status.as_json[:changing].should == false
        end
      end
    end

    it_returns_changing %w(http://cd-server.example.com/cctray.xml Pipeline OtherStag)
  end

  context 'when using job specific api' do
    it_returns_ok   %w(http://cd-server.example.com/cctray.xml goodPipe successfulStage reliablyExcellentJob)
    it_returns_fail %w(http://cd-server.example.com/cctray.xml aBadPipeline aBrokenStage anEvilJob)
    it_returns_changing %w(http://cd-server.example.com/cctray.xml goodPipe busyStage workingJob)

    context 'when it matches some pipeline and job name fully' do
      context "when check does not indicate changing" do
        let(:opts) { %w(http://cd-server.example.com/cctray.xml Pipeline SomeStage job) }

        it "does not return changing result" do
          subject.latest_status.as_json[:changing].should == false
        end
      end
    end

    it_returns_changing %w(http://cd-server.example.com/cctray.xml Pipeline SomeStage jobWorking)
  end

  context 'when using basic auth' do
    context 'when using stage specific api' do
      it_returns_ok   %w(http://username77:passw0rd@cd-server.example.com/cctray.xml goodPipe successfulStage)
      it_returns_fail %w(http://username77:passw0rd@cd-server.example.com/cctray.xml aBadPipeline aBrokenStage)
      it_returns_changing %w(http://username77:passw0rd@cd-server.example.com/cctray.xml goodPipe busyStage)
    end

    context 'when using job specific api' do
      it_returns_ok   %w(http://username77:passw0rd@cd-server.example.com/cctray.xml goodPipe successfulStage reliablyExcellentJob)
      it_returns_fail %w(http://username77:passw0rd@cd-server.example.com/cctray.xml aBadPipeline aBrokenStage anEvilJob)
      it_returns_changing %w(http://username77:passw0rd@cd-server.example.com/cctray.xml goodPipe busyStage workingJob)
    end
  end
end
