describe DateTime, "patron_format('date_string')" do
  it "formats the time in the preferred way for the app" do
    expect(DateTime.patron_format("2015-11-02T16:59:06.987Z")).to eq("11/02/15")
  end
end

describe UrlHelper, "absolute_url" do
  include UrlHelper
  it "returns an absolute url" do
    with_modified_env PATRON_ACCOUNT_BASE_URL: "http://example.com:55" do
      url = absolute_url(path: "things/stuff", query: {things: "1", stuff: "2"})
      expect(url).to eq("http://example.com:55/things/stuff?things=1&stuff=2")
    end
  end
  it "handles weird path and query stuff" do
    with_modified_env PATRON_ACCOUNT_BASE_URL: "http://example.com:55" do
      url = absolute_url(path: "things/stuff", query: {things: "#1&2", stuff: "#anchors blah"})
      expect(url).to eq("http://example.com:55/things/stuff?things=%231%262&stuff=%23anchors%20blah")
    end
  end
  it "handles empty query" do
    with_modified_env PATRON_ACCOUNT_BASE_URL: "http://example.com:55" do
      url = absolute_url(path: "things/stuff")
      expect(url).to eq("http://example.com:55/things/stuff")
    end
  end
  it "handles empty path" do
    with_modified_env PATRON_ACCOUNT_BASE_URL: "http://example.com:55" do
      url = absolute_url(query: {things: "1", stuff: "2"})
      expect(url).to eq("http://example.com:55/?things=1&stuff=2")
    end
  end
  it "handles leading and trailing slashes for path" do
    with_modified_env PATRON_ACCOUNT_BASE_URL: "http://example.com:55" do
      url = absolute_url(path: "/blah/", query: {things: "1"})
      # trailing slash before query string is fine
      expect(url).to eq("http://example.com:55/blah/?things=1")
    end
  end

  def with_modified_env(options, &block)
    ClimateControl.modify(options, &block)
  end
end
