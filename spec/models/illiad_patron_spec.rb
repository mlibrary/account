describe ILLiadPatron do
  before(:each) do
    @illiad_patron = JSON.parse(File.read('./spec/fixtures/illiad_user.json'))
    @code = 200
  end
  subject do
    stub_illiad_get_request(url: 'Users/testhelp', body: @illiad_patron.to_json, status: @code)
    described_class.for(uniqname: 'testhelp')
  end
  context "#in_illiad?" do
    it "is true if response is 200" do
      expect(subject.in_illiad?).to eq(true) 
    end
    it "is false if response is not 200" do
      @code = 404
      expect(subject.in_illiad?).to eq(false) 
    end
  end
  context "#delivery_location" do
    it "returns a campus delivery location" do
      @illiad_patron["Site"] = "Departmental Delivery"
      @illiad_patron["SAddress"] = 'Mailroom'
      @illiad_patron["SAddress2"] = '3rd Floor'
      expect(subject.delivery_location).to eq('Mailroom / 3rd Floor')
    end
    it "concatenates properly" do
      @illiad_patron["Site"] = "Departmental Delivery"
      @illiad_patron["SAddress"] = 'Mailroom'
      @illiad_patron["SAddress2"] = nil
      expect(subject.delivery_location).to eq('Mailroom')
    end
    it "is empty for not in illiad" do
      @code = 404
      expect(subject.delivery_location).to eq('') 
    end
  end
end
