$:.unshift(File.dirname(__FILE__))
require "spec_helper"

rails_issues_json = <<-JSON
[{\"url\":\"https://api.github.com/repos/rails/rails/issues/36686\",\"repository_url\":\"https://api.github.com/repos/rails/rails\",\"labels_url\":\"https://api.github.com/repos/rails/rails/issues/36686/labels{/name}\",\"comments_url\":\"https://api.github.com/repos/rails/rails/issues/36686/comments\",\"events_url\":\"https://api.github.com/repos/rails/rails/issues/36686/events\",\"html_url\":\"https://github.com/rails/rails/issues/36686\",\"id\":468270197,\"node_id\":\"MDU6SXNzdWU0NjgyNzAxOTc=\",\"number\":36686,\"title\":\"[Rails 6.0rc1] window.Rails not defined\",\"user\":{\"login\":\"zzeligg\",\"id\":23168,\"node_id\":\"MDQ6VXNlcjIzMTY4\",\"avatar_url\":\"https://avatars3.githubusercontent.com/u/23168?v=4\",\"gravatar_id\":\"\",\"url\":\"https://api.github.com/users/zzeligg\",\"html_url\":\"https://github.com/zzeligg\",\"followers_url\":\"https://api.github.com/users/zzeligg/followers\",\"following_url\":\"https://api.github.com/users/zzeligg/following{/other_user}\",\"gists_url\":\"https://api.github.com/users/zzeligg/gists{/gist_id}\",\"starred_url\":\"https://api.github.com/users/zzeligg/starred{/owner}{/repo}\",\"subscriptions_url\":\"https://api.github.com/users/zzeligg/subscriptions\",\"organizations_url\":\"https://api.github.com/users/zzeligg/orgs\",\"repos_url\":\"https://api.github.com/users/zzeligg/repos\",\"events_url\":\"https://api.github.com/users/zzeligg/events{/privacy}\",\"received_events_url\":\"https://api.github.com/users/zzeligg/received_events\",\"type\":\"User\",\"site_admin\":false},\"labels\":[],\"state\":\"open\",\"locked\":false,\"assignee\":null,\"assignees\":[],\"milestone\":null,\"comments\":0,\"created_at\":\"2019-07-15T18:24:53Z\",\"updated_at\":\"2019-07-15T18:27:16Z\",\"closed_at\":null,\"author_association\":\"NONE\",\"body\":\"### Steps to reproduce\\r\\nCreate new 6.0rc1 app with defaults `rails new test-ujs` and create a simple view on `application_controller#index`\\r\\n\\r\\n```\\r\\n# app/views/application/index.html.erb\\r\\n\\r\\n<p><%= link_to \\\"Confirm this\\\", root_url, data: { confirm: \\\"Really confirm this?\\\" } %></p>\\r\\n```\\r\\nvisit the resulting url:  http://locahost:3000/\\r\\n\\r\\n### Expected behavior\\r\\nIn browser console: `Rails` and `window.Rails` should return the Rails object defined in rails-ujs and be globally accessible.\\r\\n\\r\\n### Actual behavior\\r\\nIn browser console: `Rails` and `window.Rails` are `undefined`\\r\\n\\r\\nBut rails-ujs has been properly initialized, since the link in the page will display the confirmation dialog, as it should.\\r\\n\\r\\nAlso, this means that the event `rails:attachBindings` is never fired from within the start() method.That is my main concern, since i rely on it for some UI functionality.\\r\\n\\r\\n### Most likely cause\\r\\n\\r\\nrails-ujs, when bundled using Webpacker, is not exported/compiled the same way as with sprokets.\\r\\n\\r\\n### System configuration\\r\\n**Rails version**: 6.0rc1\\r\\n\\r\\n**Ruby version**: ruby 2.6.1p33\\r\\n\"}]
JSON

describe_check :GithubIssues, "github_issues" do
  before { WebMock.disable_net_connect! }
  after { WebMock.allow_net_connect! }

  before(:each) do
    WebMock.stub_request(:get, "https://api.github.com/repos/cppforlife/checkman-travis-fixture/issues?client_id=&client_secret=").
      to_return(:status => 200, :body => "[]", :headers => {})
    WebMock.stub_request(:get, "https://api.github.com/repos/rails/rails/issues?client_id=&client_secret=").
      to_return(:status => 200, :body => rails_issues_json, :headers => {})
  end
  # There must be issues for these tests to pass
  it_returns_ok   %w(cppforlife checkman-travis-fixture)
  it_returns_fail %w(rails rails)
end
