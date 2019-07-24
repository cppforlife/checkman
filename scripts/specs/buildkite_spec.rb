$:.unshift(File.dirname(__FILE__))
require "spec_helper"

describe_check :Buildkite, "buildkite" do
  buildkite_xml = <<-XML
<Projects>
  <Project name="MyPipeline Successful Project (master)" activity="Sleeping" lastBuildStatus="Success" lastBuildLabel="11111"
    lastBuildTime="2019-07-19T22:11:15+00:00" webUrl="https://buildkite.com/myorg/mypipeline/builds?branch=master"/>
  <Project name="OtherPipeline Failed Project (master)" activity="Sleeping" lastBuildStatus="Failure" lastBuildLabel="222"
    lastBuildTime="2019-07-19T22:11:15+00:00" webUrl="https://buildkite.com/myorg/otherpipeline/builds?branch=master"/>
  <Project name="ThirdPipeline Building Project (master)" activity="Building" lastBuildStatus="Success" lastBuildLabel="222"
    lastBuildTime="2019-07-19T22:11:15+00:00" webUrl="https://buildkite.com/myorg/thirdpipeline/builds?branch=master"/>
</Projects>
  XML

  before(:all) {WebMock.disable_net_connect!}
  after(:all) {WebMock.allow_net_connect!}

  before(:each) do
    WebMock.stub_request(:get, "https://cc.buildkite.com/myorg.xml?access_token=abcde12345&branch=master").
      to_return(:status => 200, :body => buildkite_xml, :headers => {})
  end

  context 'when using pipeline specific api' do
    it_returns_ok ['myorg', 'MyPipeline Successful Project', 'master', 'abcde12345']
    it_returns_fail ['myorg', 'OtherPipeline Failed Project', 'master', 'abcde12345']
    it_returns_changing ['myorg', 'ThirdPipeline Building Project', 'master', 'abcde12345']
  end
end
