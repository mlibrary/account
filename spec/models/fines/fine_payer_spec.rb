require 'spec_helper'
describe FinePayer do
  before(:each) do
    @fine = instance_double(Fine, to_h: {}, balance: '1.00')
    @nelnet = instance_double(Nelnet, orderNumber: '1234', url: 'url') 
    @params = {
      uniqname: 'test',
      fine_ids: ['1','2'],
      all_fines: instance_double(Fines, select: [@fine]),
      nelnet_factory: lambda{|amountDue| @nelnet},
      jwt_encoder: lambda{|payload| 'token'}
    }
  end
  subject do
    described_class.new(**@params)
  end
  context "#token" do
    it "returns a string" do
      expect(subject.token).to eq('token')
    end
  end
  context "#orderNumber" do
    it "returns a string of the orderNumber" do
      expect(subject.orderNumber).to eq('1234')
    end
  end
  context "#url" do
    it "returns a nelnet url string" do
      expect(subject.url).to eq('url')
    end
  end
end
