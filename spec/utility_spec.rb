describe DateTime, "patron_format('date_string')" do
  it "formats the time in the preferred way for the app" do
    expect(DateTime.patron_format('2015-11-02T16:59:06.987Z')).to eq('Nov 2, 2015')
  end
end
