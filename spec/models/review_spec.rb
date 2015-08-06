require "rails_helper"

describe Review do
  describe "associations" do
    it { should belong_to(:reviewable) }
    it { should belong_to(:reviewer) }
  end
end