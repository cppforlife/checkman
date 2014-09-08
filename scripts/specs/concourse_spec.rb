$:.unshift(File.dirname(__FILE__))
require "spec_helper"

describe_check :Concourse, "concourse" do
  current_json = <<-JSON
    {
      "ID":928,
      "Name":"%s",
      "Status":"%s",
      "JobName":"atc"
    }
  JSON

  before(:all) { WebMock.disable_net_connect! }
  after(:all) { WebMock.allow_net_connect! }

  before(:all) do
    [
      "pending",
      "started",
      "aborted",
      "succeeded",
      "failed",
      "errored",
    ].each do |status|
      WebMock.stub_request(:get, "http://server.example.com/api/v1/jobs/#{status}/current-build").
        to_return(:status => 200, :body => current_json % [status, status], :headers => {})

      WebMock.stub_request(:get, "http://username77:passw0rd@server.example.com/api/v1/jobs/#{status}/current-build").
        to_return(:status => 200, :body => current_json % [status, status], :headers => {})
    end

  end

  context "with no auth" do
    it_returns_ok   %w(http://server.example.com succeeded)
  
    it_returns_fail %w(http://server.example.com failed)
    it_returns_fail %w(http://server.example.com errored)
    it_returns_fail %w(http://server.example.com aborted)
  
    it_returns_changing %w(http://server.example.com pending)
    it_returns_changing %w(http://server.example.com started)
  end

  context 'when using basic auth' do
    it_returns_ok   %w(http://server.example.com username77 passw0rd succeeded)

    it_returns_fail %w(http://server.example.com username77 passw0rd failed)
    it_returns_fail %w(http://server.example.com username77 passw0rd errored)
    it_returns_fail %w(http://server.example.com username77 passw0rd aborted)
  
    it_returns_changing %w(http://server.example.com username77 passw0rd pending)
    it_returns_changing %w(http://server.example.com username77 passw0rd started)
  end
end
