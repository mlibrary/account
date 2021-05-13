describe EmptyState do
  context "#heading" do
    before(:each) do
      @current_path = nil
    end
    subject do
      described_class.new(@current_path).heading
    end
    # it "returns default empty state heading if one isn't defined in the current page or its parent" do
    #   @current_path = "/directory/view" 
    #   expect(subject).to eq("You have no items.")
    # end
    it "returns the empty state heading of the parent if one isn't define in the current page" do
      @current_path = "/pending-requests/special-collections" 
      expect(subject).to eq("You don\'t have any active requests.")
    end
    it "returns the empty state heading of the current page if defined" do
      @current_path = "/current-checkouts/interlibrary-loan" 
      expect(subject).to eq("You don\'t have any loans yet.")
    end
  end
  context "#message" do
    before(:each) do
      @current_path = nil
    end
    subject do
      described_class.new(@current_path).message
    end
    it "returns default empty state message if one isn't defined in the current page or its parent" do
      @current_path = "/current-checkouts/u-m-library" 
      expect(subject).to eq("See <a href=\"https://www.lib.umich.edu/find-borrow-request\">what you can borrow from the library</a>.")
    end
    # it "returns the empty state message of the parent if one isn't define in the current page" do
    #   @current_path = "/directory/view" 
    #   expect(subject).to eq("View your <a href=\"/current-checkouts\">current checkouts</a> to see if you would like to renew any items.")
    # end
    it "returns the empty state message of the current page if defined" do
      @current_path = "/current-checkouts/interlibrary-loan" 
      expect(subject).to eq("See how to <a href=\"https://www.lib.umich.edu/find-borrow-request/request-items-pick-or-delivery/items-another-institution-using-interlibrary\">request items from another institution</a>.")
    end
  end
end
