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
    context "#update_sms(sms_number)" do
       before(:each) do
        @new_phone = '(586) 549-5224'
        patron = JSON.parse(@alma_response)
        patron["contact_info"]["phone"][1]["phone_number"] = @new_phone
        @updated_patron = patron.to_json
       end
       it "returns status of 200 for sucessful update" do

        stub_alma_put_request(
          url: "users/mrio",
          input: @updated_patron,
          output: @updated_patron
        )
         expect(subject.update_sms(@new_phone).code).to eq(200)
       end
       it "returns alma error for failed update" do
         stub_alma_put_request(
          url: "users/mrio",
          input: @updated_patron,
          output: File.read('./spec/fixtures/alma_error.json'),
          status: 500
        )
         result = subject.update_sms(@new_phone)  
         expect(result.code).to eq(500)
         expect(result.message).to eq('User with identifier mrioaaa was not found.')
       end
       it "rejects invalid phone number" do
         result = subject.update_sms('aaa1234')  
         expect(result.code).to eq(500)
         expect(result.message).to eq('Phone number aaa1234 is invalid')
       end
       it "submits submits internal phone number for non_existent number" do
         my_response = JSON.parse(@alma_response)
         my_response["contact_info"]["phone"].delete_at(1)
         stub_alma_get_request(
           url: @patron_url, 
           body: my_response.to_json
         )
         response_dbl = double('response', code: 200)
         client_dbl = instance_double(AlmaClient, put: response_dbl)
         expect(client_dbl).to receive(:put).with(anything, JSON.parse(@updated_patron))
         subject.update_sms(@new_phone, client_dbl)
       end
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
      it "returns sms number if preferred_sms is set" do
        expect(subject.sms_number).to eq('734-123-4567')
      end
      it "returns nil if empty sms" do
        my_response = JSON.parse(@alma_response)
        my_response["contact_info"]["phone"][1]["preferred_sms"] = false
        stub_alma_get_request(
          url: @patron_url, 
          body: my_response.to_json
        )
        expect(subject.sms_number).to be_nil
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
      context "Patron::Address", "to_h" do
        it "returns appropriate address type string" do
          expect(subject.addresses.first.to_h).to eq({type: "Permanent address", display: "1440 Fake Street<br>Ann Arbor, MI  48105"})
        end
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
    context "#code" do
      it "returns error code" do
        expect(subject.code).to eq(400)
        expect(subject.message).to eq('User with identifier mrioaaa was not found.')
      end
    end
  end

end
