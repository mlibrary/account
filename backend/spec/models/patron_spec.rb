require 'spec_helper'
require 'json' 

describe Patron do
  before(:each) do
    stub_alma_get_request(
      url: "users/mrio?user_id_type=all_unique&view=full&expand=none", 
      body: File.read('./spec/fixtures/mrio_user_alma.json')
    )
  end
  subject do
    Patron.new(uniqname: 'mrio')
  end
  context "uniqname" do
    it "returns string" do
      expect(subject.uniqname).to eq('mrio')
    end
  end
  context "full_name" do
    it "returns string" do
      expect(subject.full_name).to eq('Monique Rio')
    end
  end
  context "addresses" do
    it "returns an array of addresses" do
      expect(subject.addresses.class.name).to eq('Array')
      expect(subject.addresses.count).to eq(2)
      expect(subject.addresses.first.class.name).to eq('Patron::Address')
    end
    context "Patron::Address", "to_html" do
      it "returns appropriate address string" do
        expect(subject.addresses.first.to_html).to eq("1440 Fake Street<br>Ann Arbor, MI  48105")
      end
    end
    context "Patron::Address", "type" do
      it "returns appropriate address type string" do
        expect(subject.addresses.first.type).to eq("Permanent address")
      end
    end
  end
  context "to_h" do
    it "returns a hash" do
      expect(subject.to_h.class.name).to eq('Hash')
    end
  end
end
