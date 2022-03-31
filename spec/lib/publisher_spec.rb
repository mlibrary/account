describe Publisher do
  context "#publish" do
    it "sends appropriate url to appropriate place" do
      params = {"one" => "1"}
      query = Authenticator.params_with_signature(params: params)
      req = stub_request(:post, "#{ENV.fetch("PATRON_ACCOUNT_BASE_URL")}/updater/#{query}")
        .with(
          headers: {
            "Accept" => "*/*",
            "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "User-Agent" => "Ruby"
          }
        ).to_return(status: 200, body: "", headers: {})

      Publisher.new.publish(params)
      expect(req).to have_been_requested
    end
  end
end
