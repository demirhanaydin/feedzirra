require 'spec_helper'

describe Feedjira::FeedUtilities do
  before(:each) do
    @klass = Class.new do
      include Feedjira::FeedEntryUtilities
    end
  end

  describe "handling dates" do
    it "should parse an ISO 8601 formatted datetime into Time" do
      time = @klass.new.parse_datetime("2008-02-20T8:05:00-010:00")
      time.class.should == Time
      time.should == Time.parse_safely("Wed Feb 20 18:05:00 UTC 2008")
    end

    it "should parse a ISO 8601 with milliseconds into Time" do
      time = @klass.new.parse_datetime("2013-09-17T08:20:13.931-04:00")
      time.class.should == Time
      time.should == Time.parse_safely("Tue Sep 17 12:20:13 UTC 2013")
    end
  end

  describe "sanitizing" do
    before(:each) do
      @feed = Feedjira::Feed.parse(sample_atom_feed)
      @entry = @feed.entries.first
    end

    it "doesn't fail when no elements are defined on includer" do
      expect { @klass.new.sanitize!  }.to_not raise_error
    end

    it "should provide a sanitized title" do
      new_title = "<script>this is not safe</script>" + @entry.title
      @entry.title = new_title
      @entry.title.sanitize.should == Loofah.scrub_fragment(new_title, :prune).to_s
    end

    it "should sanitize content in place" do
      new_content = "<script>" + @entry.content
      @entry.content = new_content.dup
      @entry.content.sanitize!.should == Loofah.scrub_fragment(new_content, :prune).to_s
      @entry.content.should == Loofah.scrub_fragment(new_content, :prune).to_s
    end

    it "should sanitize things in place" do
      @entry.title   += "<script>"
      @entry.author  += "<script>"
      @entry.content += "<script>"

      cleaned_title   = Loofah.scrub_fragment(@entry.title, :prune).to_s
      cleaned_author  = Loofah.scrub_fragment(@entry.author, :prune).to_s
      cleaned_content = Loofah.scrub_fragment(@entry.content, :prune).to_s

      @entry.sanitize!
      @entry.title.should   == cleaned_title
      @entry.author.should  == cleaned_author
      @entry.content.should == cleaned_content
    end
  end
end
