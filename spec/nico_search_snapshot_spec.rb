RSpec.describe NicoSearchSnapshot do
  it "has a version number" do
    expect(NicoSearchSnapshot::VERSION).not_to be nil
  end

  it "テスト" do
    NicoSearchSnapshot::Agent.new.search '犬走椛'
  end
end
