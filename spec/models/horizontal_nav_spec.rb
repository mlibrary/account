require 'spec_helper'

describe HorizontalNav do
  context ".for" do
    it "selects 'Requests' when the path starts with /requests/" do
      nav = described_class.for("/requests/um-library")
      expect(nav.class.name).to eq("RequestNav")
    end
    it "selects 'Shelf' when the path starts with /shelf/" do
      nav = described_class.for("/shelf/loans")
      expect(nav.class.name).to eq("ShelfNav")
    end
  end
  context "#label" do
    subject do
      described_class.for("/requests/um-library").label
    end
    it "returns the appropariate label" do
      expect(subject).to eq("U-M Library")
    end
  end
  context "#section" do
    subject do
      described_class.for("/requests/um-library").section
    end
    it "returns 'Requests' when the path starts with /requests/" do
      expect(subject).to eq("Requests")
    end
  end
  context "#pages" do
    subject do
      described_class.for("/requests/um-library").pages
    end
    it "returns a non-empty array" do
      expect(subject).to be_an_instance_of(Array)
      expect(subject).not_to be_empty
    end
  end
end
