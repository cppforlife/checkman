$:.unshift(File.dirname(__FILE__))
require "spec_helper"
require "webmock"

describe_check :CCTray, "cctray" do
  let(:cctray_xml) do
    <<-XML
<Projects>
  <Project name="goodPipe :: successfulStage" activity="Sleeping" lastBuildStatus="Success" lastBuildLabel="145" lastBuildTime="2014-06-25T17:46:42" webUrl="http://www.gocd.cf-app.com/go/pipelines/Acceptance/145/provision/1" />
  <Project name="goodPipe :: successfulStage :: reliablyExcellentJob" activity="Sleeping" lastBuildStatus="Success" lastBuildLabel="145" lastBuildTime="2014-06-25T18:55:27" webUrl="http://www.gocd.cf-app.com/go/tab/build/detail/Acceptance/145/promote/1/tag" />

  <Project name="goodPipe :: busyStage" activity="Building" lastBuildStatus="Success" lastBuildLabel="145" lastBuildTime="2014-06-25T17:46:42" webUrl="http://www.gocd.cf-app.com/go/pipelines/Acceptance/145/provision/1" />
  <Project name="goodPipe :: busyStage :: workingJob" activity="Building" lastBuildStatus="Success" lastBuildLabel="145" lastBuildTime="2014-06-25T17:46:42" webUrl="http://www.gocd.cf-app.com/go/pipelines/Acceptance/145/provision/1" />

  <Project name="aBadPipeline :: aBrokenStage" activity="Sleeping" lastBuildStatus="Failure" lastBuildLabel="145" lastBuildTime="2014-06-25T17:46:42" webUrl="http://www.gocd.cf-app.com/go/pipelines/Acceptance/145/provision/1" />
  <Project name="aBadPipeline :: aBrokenStage :: anEvilJob" activity="Sleeping" lastBuildStatus="Failure" lastBuildLabel="145" lastBuildTime="2014-06-25T18:55:27" webUrl="http://www.gocd.cf-app.com/go/tab/build/detail/Acceptance/145/promote/1/tag" />
</Projects>
    XML
  end
  before(:all) do
    WebMock.stub_request(:get, "http://cd-server.example.com/cctray.xml").
      to_return(:status => 200, :body => cctray_xml, :headers => {})

    WebMock.stub_request(:get, "http://username77:passw0rd@cd-server.example.com/cctray.xml").
      to_return(:status => 200, :body => cctray_xml, :headers => {})
  end
  # Branches must actually be ok/failing for these tests to pass

  context 'when using stage specific api' do
    it_returns_ok   %w(http://cd-server.example.com/cctray.xml goodPipe successfulStage)
    it_returns_fail %w(http://cd-server.example.com/cctray.xml aBadPipeline aBrokenStage)
    it_returns_changing %w(http://cd-server.example.com/cctray.xml goodPipe busyStage)
  end

  context 'when using job specific api' do
    it_returns_ok   %w(http://cd-server.example.com/cctray.xml goodPipe successfulStage reliablyExcellentJob)
    it_returns_fail %w(http://cd-server.example.com/cctray.xml aBadPipeline aBrokenStage anEvilJob)
    it_returns_changing %w(http://cd-server.example.com/cctray.xml goodPipe busyStage workingJob)
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
