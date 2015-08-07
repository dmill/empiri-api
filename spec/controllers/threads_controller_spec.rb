require "rails_helper"

describe ThreadsController do
  let(:response_body) { JSON.parse(subject.body) }
  let(:thread) { create(:publication) }

  shared_examples "a threads controller GET action" do |id = nil|
    it "has a json content type" do

      get subject, id: id

      expect(response.header['Content-Type']).to include('application/json')
    end

    it "returns valid json" do
      get subject, id: id

      expect{JSON.parse(response.body)}.not_to raise_error
    end
  end

  describe "GET show" do
    subject { :show }

    it_should_behave_like "a threads controller GET action", 1

    context "requested thread is not found" do
      subject { get :show, id: 1 }

      it { expect(subject.response_code).to eq(404) }
      it {expect(response_body["errors"]).to eq("Not Found") }
    end

    context "requested thread is found" do
      before(:each) { thread }

      subject { get :show, id: thread.id }

      it { expect(subject.response_code).to eq(200) }
      it { expect(response_body["id"]).to eq(thread.id) }
      it { expect(response_body["title"]).to eq(thread.title) }
    end
  end
end