require "spec_helper"
describe Authenticator do
  context ".verify" do
    it "returns true for valid params" do
      hash = Digest::SHA256.hexdigest "12secret"
      params = {"one" => "1", "two" => "2", "hash" => hash}
      expect(Authenticator.verify(params: params, key: "secret")).to eq(true)
    end
    it "returns false for invalid params" do
      hash = Digest::SHA256.hexdigest "12secretsssss"
      params = {"one" => "1", "two" => "2", "hash" => hash}
      expect(Authenticator.verify(params: params, key: "secret")).to eq(false)
    end
  end
  context ".params_with_signature" do
    it "returns appropriately escaped params with correct signature" do
      secret = "secret"
      params = {one: 123, two: "I love marshmallows"}
      hash = Digest::SHA256.hexdigest "123I love marshmallows#{secret}"

      output = Authenticator.params_with_signature(params: params, key: "secret")
      expect(output).to eq("?one=123&two=I+love+marshmallows&hash=#{hash}")
    end
  end
end
