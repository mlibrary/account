require 'spec_helper'
require 'json' 

describe Patron do
  context "found uniqname" do
    before(:each) do
      @alma_response = File.read('./spec/fixtures/mrio_user_alma.json')
      @patron_url = "users/mrio?user_id_type=all_unique&view=full&expand=none"
      stub_alma_get_request(
        url: @patron_url, 
        body: @alma_response
      )
    end
    subject do
      Patron.for(uniqname: 'mrio')
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
    context "sms_number" do
      it "returns nil if empty sms" do
        expect(subject.sms_number).to be_nil
      end
      it "returns sms number if preferred_sms is set" do
        my_response = JSON.parse(@alma_response)
        my_response["contact_info"]["phone"][0]["preferred_sms"] = true
        stub_alma_get_request(
          url: @patron_url, 
          body: my_response.to_json
        )
        expect(subject.sms_number).to eq("555-555-5555")
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
  context "nonexistent uniqname" do
    before(:each) do
      @alma_response = File.read('./spec/fixtures/alma_error.json')
      @patron_url = "users/mrioaaa?user_id_type=all_unique&view=full&expand=none"
      stub_alma_get_request(
        status: 400,
        url: @patron_url, 
        body: @alma_response
      )
    end
    subject do
      Patron.for(uniqname: 'mrioaaa')
    end
    context "response" do
      it "returns array with error" do
        expect(subject.response[0]).to eq(400)
        expect(JSON.parse(subject.response[2])).to eq(JSON.parse(@alma_response))
      end
    end
  end

end
