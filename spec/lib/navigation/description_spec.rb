describe Navigation::Description do
  context "description for current page" do
    it "pulls in the page's description" do
      expect(described_class.for('/').to_s).to eq('Providing access to all of your current account information, including your checkouts and all of your requests for materials (including interlibrary loan and special collection requests).')
    end
  end
  context "description from parent page" do
    it "pulls in the parent page's description if current page does not have a description" do
      expect(described_class.for('/current-checkouts/u-m-library').to_s).to eq("View and renew items you've checked out and see when they're due.")
    end
  end
end
