describe CirculationHistorySettingsText do
  context "decided to keep history" do
    subject {described_class.for(retain_history: true, confirmed_history_setting: true)}
    it "returns decided to keep history" do
      expect(subject.class.name).to include('DecidedKeepHistory')
    end
  end
  context "decided to not keep history" do
    subject {described_class.for(retain_history: false, confirmed_history_setting: true)}
    it "returns decided to not keep history" do
      expect(subject.class.name).to include('DecidedNoHistory')
    end
  end
  context "undecided and currently keeping history" do
    subject {described_class.for(retain_history: true, confirmed_history_setting: false)}
    it "returns undecided but currently keeping history" do
      expect(subject.class.name).to include('UndecidedKeepHistory')
    end
  end
  context "undecided and not currently keeping history" do
    subject {described_class.for(retain_history: false, confirmed_history_setting: false)}
    it "returns undecided and currently not keeping history" do
      expect(subject.class.name).to include('UndecidedNoHistory')
    end
  end
end

