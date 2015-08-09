require "rails_helper"

describe ExperimentsController do
  let(:response_body) { JSON.parse(subject.body) }
  let(:experiment) { create(:experiment) }

  shared_examples "an experiments controller GET action" do
    it "has a json content type" do

      get subject, id: 1

      expect(response.header['Content-Type']).to include('application/json')
    end

    it "returns valid json" do
      get subject, id: 1

      expect{JSON.parse(response.body)}.not_to raise_error
    end
  end

  describe "GET show" do
    subject { :show }

    it_should_behave_like "an experiments controller GET action"

    context "requested experiment is not found" do
      subject { get :show, id: 1 }

      it { expect(subject.response_code).to eq(404) }
      it {expect(response_body["errors"]).to eq("Not Found") }
    end

    context "requested experiment is found" do
      before(:each) { experiment }

      subject { get :show, id: experiment.id }

      it { expect(subject.response_code).to eq(200) }
      it { expect(response_body["title"]).to eq(experiment.title) }
      it { expect(response_body["thread_id"]).to eq(experiment.publication_id) }
      it { expect(response_body["submitted_at"]).to eq(experiment.submitted_at.to_s) }
      it { expect(response_body["submitted"]).to eq(experiment.submitted) }
      it { expect(response_body["_embedded"]["reviews"].class).to eq(Array)}
    end
  end
end