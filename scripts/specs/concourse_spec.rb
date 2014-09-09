$:.unshift(File.dirname(__FILE__))
require "spec_helper"

describe_check :Concourse, "concourse" do
  job_json = <<-JSON
    {
      "finished_build": {
        "id": 928,
        "name": "finished",
        "status": "%s",
        "job_name": "atc"
      },
      "next_build": {
        "id": 929,
        "name": "next",
        "status": "%s",
        "job_name": "atc"
      }
    }
  JSON

  before(:all) { WebMock.disable_net_connect! }
  after(:all) { WebMock.allow_net_connect! }

  before(:all) do
    [
      ["succeeded", "pending"],
      ["succeeded", "started"],
      ["failed", "pending"],
      ["failed", "started"],
      ["errored", "pending"],
      ["errored", "started"],
      ["aborted", "pending"],
      ["aborted", "started"],
    ].each do |finished_status, next_status|
      WebMock.stub_request(:get, "http://server.example.com/api/v1/jobs/#{finished_status}-#{next_status}").
        to_return(:status => 200, :body => job_json % [finished_status, next_status], :headers => {})

      WebMock.stub_request(:get, "http://username77:passw0rd@server.example.com/api/v1/jobs/#{finished_status}-#{next_status}").
        to_return(:status => 200, :body => job_json % [finished_status, next_status], :headers => {})
    end
  end

  context "with no auth" do
    it_returns_ok   %w(http://server.example.com succeeded-pending)
    it_returns_ok   %w(http://server.example.com succeeded-started)

    it_returns_fail %w(http://server.example.com failed-pending)
    it_returns_fail %w(http://server.example.com errored-pending)
    it_returns_fail %w(http://server.example.com aborted-pending)
    it_returns_fail %w(http://server.example.com failed-started)
    it_returns_fail %w(http://server.example.com errored-started)
    it_returns_fail %w(http://server.example.com aborted-started)

    it_returns_changing %w(http://server.example.com succeeded-pending)
    it_returns_changing %w(http://server.example.com failed-pending)
    it_returns_changing %w(http://server.example.com errored-pending)
    it_returns_changing %w(http://server.example.com succeeded-started)
    it_returns_changing %w(http://server.example.com failed-started)
    it_returns_changing %w(http://server.example.com errored-started)
  end

  context 'when using basic auth' do
    it_returns_ok   %w(http://server.example.com username77 passw0rd succeeded-pending)
    it_returns_ok   %w(http://server.example.com username77 passw0rd succeeded-started)

    it_returns_fail %w(http://server.example.com username77 passw0rd failed-pending)
    it_returns_fail %w(http://server.example.com username77 passw0rd errored-pending)
    it_returns_fail %w(http://server.example.com username77 passw0rd aborted-pending)
    it_returns_fail %w(http://server.example.com username77 passw0rd failed-started)
    it_returns_fail %w(http://server.example.com username77 passw0rd errored-started)
    it_returns_fail %w(http://server.example.com username77 passw0rd aborted-started)

    it_returns_changing %w(http://server.example.com username77 passw0rd succeeded-pending)
    it_returns_changing %w(http://server.example.com username77 passw0rd failed-pending)
    it_returns_changing %w(http://server.example.com username77 passw0rd errored-pending)
    it_returns_changing %w(http://server.example.com username77 passw0rd succeeded-started)
    it_returns_changing %w(http://server.example.com username77 passw0rd failed-started)
    it_returns_changing %w(http://server.example.com username77 passw0rd errored-started)
  end
end
