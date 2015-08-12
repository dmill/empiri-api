require "rails_helper"

describe PublicationsController do
  let(:response_body) { JSON.parse(subject.body) }
  let(:publication) { create(:publication, closed: true, closed_at: Time.now - 5.days) }

  shared_examples "a publications controller GET action" do |id = nil|
    it "has a json content type" do

      get subject, id: id

      expect(response.header['Content-Type']).to include('application/json')
    end

    it "returns valid json" do
      get subject, id: id

      expect{JSON.parse(response.body)}.not_to raise_error
    end
  end

  describe "GET index" do
    subject { :index }
    before(:each) do
      6.times{ create(:publication) }
    end

    it_should_behave_like "a publications controller GET action"

    context "successful request" do
      subject { get :index }

      it { expect(subject.response_code).to eq(200) }
      it { expect(response_body["publications"].count).to eq(5) }
      it { expect(response_body["publications"].first.keys).to include("id") }
      it { expect(response_body["publications"].first.keys).to include("title") }
      it { expect(response_body["publications"].first.keys).to include("closed") }
      it { expect(response_body["publications"].first["_embedded"]["authors"].class).to eq(Array) }
    end
  end

  describe "GET show" do
    subject { :show }

    it_should_behave_like "a publications controller GET action", 1

    context "requested publication is not found" do
      subject { get :show, id: 1 }

      it { expect(subject.response_code).to eq(404) }
      it {expect(response_body["errors"]).to eq("Not Found") }
    end

    context "requested publicaiton is found" do
      before(:each) { publication }

      subject { get :show, id: publication.id }

      it { expect(subject.response_code).to eq(200) }
      it { expect(response_body["id"]).to eq(publication.id) }
      it { expect(response_body["title"]).to eq(publication.title) }
      it { expect(response_body["closed"]).to eq(publication.closed) }
      it { expect(response_body["closed_at"]).to eq(publication.closed_at.to_s) }
      it { expect(response_body["_embedded"]["authors"].class).to eq(Array) }
      it { expect(response_body["_embedded"]["reviews"].class).to eq(Array) }
      it { expect(response_body["_embedded"]["experiments"].class).to eq(Array) }
    end
  end
end