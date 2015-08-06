require "rails_helper"

describe User do
  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:organization) }
  end

  describe "associations" do
    it { should have_and_belong_to_many(:publications) }
    it { should have_many(:reviews) }
  end
end