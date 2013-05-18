$:.unshift(File.dirname(__FILE__))
require "spec_helper"

describe_check :PivotalTracker, "pivotal_tracker" do
  let(:ok_project) { double(:ok_project, status: :ok) }
  let(:failing_project) { double(:failing_project, status: :failing) }
  let(:changing_project) { double(:changing_project, status: :changing) }

  before do
    PivotalTracker::Project.stub(:find).with('okprojectid').and_return(ok_project)
    PivotalTracker::Project.stub(:find).with('failingprojectid').and_return(failing_project)
    PivotalTracker::Project.stub(:find).with('changingprojectid').and_return(changing_project)
  end

  it_returns_ok %w(okprojectid userid)
  it_returns_fail %w(failingprojectid userid)
  it_returns_changing %w(changingprojectid userid)
end
