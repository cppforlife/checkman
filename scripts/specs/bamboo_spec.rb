$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe_check :Bamboo, 'bamboo' do
  bamboo_fail_xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<rss xmlns:dc="http://purl.org/dc/elements/1.1/" version="2.0">
  <channel>
    <title>Bamboo build results feed for the build</title>
    <link>http://bamboo.local</link>
    <description>This feed is updated whenever the build gets built</description>
    <item>
      <title>the build has FAILED : Updated by the developer</title>
      <link>http://bamboo.local/browse/BUILD1</link>
      <description>description of build</description>
      <pubDate>Wed, 25 May 2016 09:47:15 GMT</pubDate>
      <guid>http://bamboo.local/browse/BUILD1</guid>
      <dc:date>2016-05-25T09:47:15Z</dc:date>
    </item>
    <item>
      <title>the build was SUCCESSFUL : Updated by the developer</title>
      <link>http://bamboo.local/browse/BUILD2</link>
      <description>description of build</description>
      <pubDate>Wed, 25 May 2016 09:47:15 GMT</pubDate>
      <guid>http://bamboo.local/browse/BUILD2</guid>
      <dc:date>2016-05-25T09:47:15Z</dc:date>
    </item>
  </channel>
</rss>
  XML

  bamboo_pass_xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<rss xmlns:dc="http://purl.org/dc/elements/1.1/" version="2.0">
  <channel>
    <title>Bamboo build results feed for the build</title>
    <link>http://bamboo.local</link>
    <description>This feed is updated whenever the build gets built</description>
    <item>
      <title>the build was SUCCESSFUL : Updated by the developer</title>
      <link>http://bamboo.local/browse/BUILD2</link>
      <description>description of build</description>
      <pubDate>Wed, 25 May 2016 09:47:15 GMT</pubDate>
      <guid>http://bamboo.local/browse/BUILD2</guid>
      <dc:date>2016-05-25T09:47:15Z</dc:date>
    </item>
    <item>
      <title>the build has FAILED : Updated by the developer</title>
      <link>http://bamboo.local/browse/BUILD1</link>
      <description>description of build</description>
      <pubDate>Wed, 25 May 2016 09:47:15 GMT</pubDate>
      <guid>http://bamboo.local/browse/BUILD1</guid>
      <dc:date>2016-05-25T09:47:15Z</dc:date>
    </item>
  </channel>
</rss>
  XML

  before(:all) { WebMock.disable_net_connect! }
  after(:all) { WebMock.allow_net_connect! }

  before(:all) do
    WebMock.stub_request(:get, 'http://bamboo.local/failedbuild.rss').
        to_return(:status => 200, :body => bamboo_fail_xml, :headers => {})

    WebMock.stub_request(:get, 'http://bamboo.local/passedbuild.rss').
        to_return(:status => 200, :body => bamboo_pass_xml, :headers => {})
  end

  context 'when the first item in the feed shows was SUCCESSFUL' do
    it_returns_ok   %w(http://bamboo.local/passedbuild.rss)
  end

  context 'when the first item in the feed shows has FAILED' do
    it_returns_fail %w(http://bamboo.local/failedbuild.rss)
  end

  context 'when showing build details, provides useful links' do
    let(:opts) { %w(http://bamboo.local/passedbuild.rss) }

    it 'returns an url to RSS feed' do
      url = subject.latest_status.as_json[:rssUrl]
      expect(url).to eq('http://bamboo.local/passedbuild.rss')
    end

    it 'returns an url that links directly to the bamboo build' do
      link = subject.latest_status.as_json[:info][0][1]
      expect(link).to eq('http://bamboo.local/browse/BUILD2');
    end
  end
end
