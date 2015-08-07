require "rails_helper"

describe Experiment do
  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:publication) }
  end

  describe "associations" do
    it { should belong_to(:publication) }
    it { should have_many(:reviews) }
  end
end