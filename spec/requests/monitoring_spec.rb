describe "monitoring requests" do
  context "get /-/live" do
    it "returns an OK status" do
      get "/-/live"
      expect(last_response.status).to eq(200)
    end
  end
end
