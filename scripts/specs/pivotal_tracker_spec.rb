$:.unshift(File.dirname(__FILE__))
require "spec_helper"

# describe_check :PivotalTracker, "pivotal_tracker" do
  # it_returns_ok %w(829747 00bedcc48d3d8484e244dbad6bf8941c Checkman OK)
  # it_returns_changing %w(829747 07ebaa44be590bf33b93a9b8c059db63 Checkman Changing)
  # it_returns_fail %w(829747 213d9b96fa4dbd9a0cf04b3fe8b34f82 Checkman Failing)
# end

describe_check :PivotalTracker, "pivotal_tracker" do
  let(:ok_project) { double(:ok_project, status: :ok) }
  let(:failing_project) { double(:failing_project, status: :failing) }
  let(:changing_project) { double(:changing_project, status: :changing) }

  before do
    PivotalTracker::Project.stub(:find).with('okprojectid').and_return(ok_project)
    PivotalTracker::Project.stub(:find).with('failingprojectid').and_return(failing_project)
    PivotalTracker::Project.stub(:find).with('changingprojectid').and_return(changing_project)
  end

  it_returns_ok %w(okprojectid okusertoken OK UserName)
  it_returns_fail %w(failingprojectid failingusertoken FailingUserName)
  it_returns_changing %w(changingprojectid changingusertoken Changing User Name)
end

describe PivotalTracker::Project do
  let(:project) { PivotalTracker::Project.new }
  let(:user_name) { "Trent Beatie" }

  let(:accepted)  { stub_story('accepted') }
  let(:rejected)  { stub_story('rejected') }
  let(:delivered) { stub_story('delivered') }
  let(:finished)  { stub_story('finished') }
  let(:started)   { stub_story('started') }
  let(:unstarted) { stub_story('unstarted') }

  before do
    project.stub_chain(:stories, :all).with(owned_by: user_name).and_return(stories)
  end

  describe "#status" do
    subject { project.status(user_name) }

    context "no stories started or rejected" do
      let(:stories) { [delivered, finished, accepted, unstarted] }

      it { should == :changing }
    end

    context "started stories exist, none rejected or accepted" do
      let(:stories) { [finished, started, unstarted] }

      it { should == :ok }
    end

    context "started stories exist, some accepted, none rejected" do
      let(:stories) { [accepted, delivered, finished, started, unstarted] }

      it { should == :ok }
    end

    context "rejected stories exist" do
      let(:stories) { [rejected] }

      it { should == :failing }
    end
  end

  private

  def stub_story(status)
    story = ::PivotalTracker::Story.new
    story.stub(:current_state).and_return(status)
    story
  end
end
