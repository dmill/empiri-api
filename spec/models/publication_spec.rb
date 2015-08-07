require "rails_helper"

describe Publication do
  describe "validations" do
    it { should validate_presence_of(:title) }
  end

  describe "associations" do
    it { should have_and_belong_to_many(:users) }
    it { should have_many(:reviews) }
    it { should have_many(:experiments) }
  end
end