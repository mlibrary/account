require 'spec_helper'
require 'json' 

describe Patron do
  context "found uniqname and circ history" do
    before(:each) do
      @alma_response = JSON.parse(File.read('./spec/fixtures/mrio_user_alma.json'))
      @circ_history_response = JSON.parse(File.read('./spec/fixtures/circ_history_user.json'))
      @illiad_response = JSON.parse(File.read('./spec/fixtures/illiad_user.json'))
      @patron_url = "users/mrio?user_id_type=all_unique&view=full&expand=none"
      
    end
    subject do
      stub_alma_get_request(
        url: @patron_url, 
        body: @alma_response.to_json
      )
      stub_circ_history_get_request(
        url: 'users/mrio',
        output: @circ_history_response.to_json
      )
      stub_illiad_get_request(url: 'Users/mrio', body: @illiad_response.to_json) 
      Patron.for(uniqname: 'mrio')
    end
    context "#update_sms(sms_number)" do
       before(:each) do
        @new_phone = '(586) 549-5224'
        patron = JSON.parse(@alma_response.to_json)
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
       it "submits internal phone number for non_existent number" do
         @alma_response["contact_info"]["phone"].delete_at(1)
         response_dbl = double('response', code: 200)
         client_dbl = instance_double(AlmaRestClient::Client, put: response_dbl)
         expect(client_dbl).to receive(:put).with(anything, body: @updated_patron)
         subject.update_sms(@new_phone, client_dbl)
       end
       it "submits removed phone number when sent an empty number" do
         response_dbl = double('response', code: 200)
         client_dbl = instance_double(AlmaRestClient::Client, put: response_dbl)

         expected_sent_data = JSON.parse(@alma_response.to_json)
         expected_sent_data["contact_info"]["phone"].delete_at(1)

         expect(client_dbl).to receive(:put).with(anything, body: expected_sent_data.to_json)
         subject.update_sms('', client_dbl)
       end
    end
    context "#uniqname" do
      it "returns string" do
        expect(subject.uniqname).to eq('mrio')
      end
    end
    context "#full_name" do
      it "returns string" do
        expect(subject.full_name).to eq('Monique Rio')
      end
    end
    context "#user_group" do
      it "returns the user group name" do
        expect(subject.user_group).to eq('Staff Level')
      end
    end
    context "#can_book?" do
      it "returns true for staff" do
        expect(subject.can_book?).to eq(true)
      end
      it "returns true for faculty" do
        @alma_response["user_group"]["desc"] = "Faculty Level"
        expect(subject.can_book?).to eq(true)
      end
      it "returns true for graduate students" do
        @alma_response["user_group"]["desc"] = "Graduate Level"
        expect(subject.can_book?).to eq(true)
      end
      it "returns false for undergraduate students" do
        @alma_response["user_group"]["desc"] = "Undergraduate Level"
        expect(subject.can_book?).to eq(false)
      end
    end
    context "#in_circ_history?" do
      it 'returns true' do
        expect(subject.in_circ_history?).to eq(true)
      end
    end
    context "#retain_history?" do
      it "returns correct true boolean" do
        expect(subject.retain_history?).to eq(true)
      end
      it "returns correct false boolean" do
        @circ_history_response["retain_history"] = false
        expect(subject.retain_history?).to eq(false)
      end
    end
    context "#confiremd_history_setting?" do
      it "returns correct true boolean" do
        expect(subject.confirmed_history_setting?).to eq(true)
      end
      it "returns correct false boolean" do
        @circ_history_response["confirmed"] = false
        expect(subject.confirmed_history_setting?).to eq(false)
      end
    end
    context "#sms_number" do
      it "returns sms number if preferred_sms is set" do
        expect(subject.sms_number).to eq('734-123-4567')
      end
      it "returns nil if empty sms" do
        @alma_response["contact_info"]["phone"][1]["preferred_sms"] = false
        expect(subject.sms_number).to be_nil
      end
    end
    context "#sms_number?" do
      it "returns true for exisitng sms number" do
        expect(subject.sms_number?).to eq(true)
      end
      it "returns false for non-existant sms number" do 
        @alma_response["contact_info"]["phone"][1]["preferred_sms"] = false
        expect(subject.sms_number?).to eq(false)
      end
    end
    context "#email" do
      it "returns preferred email address" do
        expect(subject.email_address).to eq("mrio@umich.edu")
      end
      it "returns nil if no preferred email address" do
        @alma_response["contact_info"]["email"][0]["preferred"] = false
      end
    end
    context "#addresses" do
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
  context "has alma; does not have circ history" do
    before(:each) do
      @alma_response = JSON.parse(File.read('./spec/fixtures/mrio_user_alma.json'))
      @circ_history_response = JSON.parse(File.read('./spec/fixtures/circ_history_user.json'))
      @patron_url = "users/mrio?user_id_type=all_unique&view=full&expand=none"
      stub_alma_get_request(
        url: @patron_url, 
        body: @alma_response.to_json
      )
      stub_illiad_get_request(url: 'Users/mrio', status: 404)
      stub_circ_history_get_request(
        status: 400,
        url: 'users/mrio',
      )
    end
    subject do
      Patron.for(uniqname: 'mrio')
    end
    context "#confirmed_history_setting?" do
      it "is false" do
        expect(subject.confirmed_history_setting?).to eq(false)
      end
    end
    context "#retain_history?" do
      it "is false" do
        expect(subject.retain_history?).to eq(false)
      end
    end
    context "#in_circ_history?" do
      it "is false" do
        expect(subject.in_circ_history?).to eq(false)
      end
    end
  end
  context "nonexistent uniqname and not in circ history" do
    before(:each) do
      @alma_response = File.read('./spec/fixtures/alma_error.json')
      @patron_url = "users/mrioaaa?user_id_type=all_unique&view=full&expand=none"
      stub_alma_get_request(
        status: 400,
        url: @patron_url, 
        body: @alma_response
      )
      stub_circ_history_get_request(
        url: 'users/mrioaaa',
        status: 400
      )
      stub_illiad_get_request(url: 'Users/mrioaaa', status: 404)
    end
    subject do
      Patron.for(uniqname: 'mrioaaa')
    end
    context "#in_circ_history?" do
      it "is false when no created_at from circ history" do
        expect(subject.in_circ_history?).to eq(false)
      end
    end
    ['in_alma?', 'can_book?', 'confirmed_history_setting?','retain_history?'].each do |method|
      context "##{method}" do
        it "returns false" do
          expect(subject.send(method)).to eq(false)
        end
      end
    end
    ['email_address', 'sms_number','sms_number?', 'full_name', 'user_group',
      'addresses'].each do |method|
      context "##{method}" do
        it "returns nil" do
          expect(subject.send(method)).to be_nil
        end
      end
    end
    
  end
end
describe Patron, ".set_retain_history" do
  it "updates the circ history setting" do
    stub = stub_circ_history_put_request(url: 'users/tutor', query: {retain_history: false})
    Patron.set_retain_history(uniqname: 'tutor', retain_history: 'false')
    expect(stub).to have_been_requested
  end
end
