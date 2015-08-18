require 'territorial'

RSpec.describe Territorial do
  it 'has a version number' do
    expect(Territorial::VERSION).not_to be nil
  end

  let(:expander) { Territorial.new }

  describe "the default regions are correctly expanded" do
    specify { expect(expander.expand('GSA')).to eq(Territorial::EXPANSIONS['GSA']) }
    specify { expect(expander.expand('EU')).to eq(Territorial::EXPANSIONS['EU']) }
    specify { expect(expander.expand('EFTA')).to eq(Territorial::EXPANSIONS['EFTA']) }
    specify { expect(expander.expand('WW')).to eq(Territorial::EXPANSIONS['WW']) }
  end

  describe 'region expansion' do
    it 'accepts multiple regions' do
      expected = Territorial::EXPANSIONS['EU'] + Territorial::EXPANSIONS['EFTA']
      expect(expander.expand('EU', 'EFTA')).to eq(expected)
    end

    it 'accepts an array of regions' do
      expected = Territorial::EXPANSIONS['EU'] + Territorial::EXPANSIONS['EFTA']
      expect(expander.expand(['EU', 'EFTA'])).to eq(expected)
    end

    it 'accepts region symbols' do
      expect(expander.expand(:EU)).to eq(Territorial::EXPANSIONS['EU'])
    end

    it 'accepts multiple region symbols' do
      expected = Territorial::EXPANSIONS['EU'] + Territorial::EXPANSIONS['EFTA']
      expect(expander.expand(:EU, :EFTA)).to eq(expected)
    end

    it "passes non-expandable territories through" do
      expect(expander.expand('GB')).to eq(['GB'])
    end

    it 'passes unknown regions through' do
      expect(expander.expand('WHATEVER')).to eq(['WHATEVER'])
    end

    it "copes with lowercase regions" do
      expect(expander.expand('gb')).to eq(['GB'])
      expect(expander.expand(:gb)).to eq(['GB'])
    end

    it 'removes duplicates' do
      territories = expander.expand(:GSA, :EU)
      germany = territories.select { |t| t == 'DE' }
      expect(germany.size).to eq(1)
    end
  end

  describe "creating and configuring an instance" do
    context "with extra expansions" do
      it "accepts hashes with string keys" do
        expander = Territorial.new('NorthAm' => ['US', 'CA'])
        expect(expander.expand('NorthAm')).to eq(['US', 'CA'])
      end

      it "accepts hashes with symbol keys" do
        expander = Territorial.new(NorthAm: [:US, :CA])
        expect(expander.expand(:NorthAm)).to eq(['US', 'CA'])
      end
    end

    context "with bounds on what territories can be emitted" do
      let(:expander) { Territorial.new({}, [:EU]) }

      it "places an upper constraint on what gets expanded" do
        expect(expander.expand(:WW).sort).to eq(Territorial.expand(:EU).sort)
      end

      it "doesn't place a lower constraint on what gets expanded" do
        expect(expander.expand(:GB, :FR).sort).to eq(Territorial.expand(:GB, :FR).sort)
      end

      it "constrains list parsing in the same way" do
        expect(expander.territories('WW -FR').sort)
          .to eq(expander.territories('EU -FR').sort)
      end
    end
  end

  context "nested expansions" do
    it "can be expanded" do
      expander = Territorial.new(EEA: [:EU, :EFTA])
      expect(expander.expand(:EEA)).to eq(expander.expand(:EU, :EFTA))
    end

    it "safely do not allow themselves to be recursively expanded infinitely" do
      expander = Territorial.new(EEA: [:EEA])
      expect(expander.expand(:EEA)).to eq(['EEA'])
    end
  end

  describe "parsing a territory list" do
    context "simple prefix handling" do
      it "converts +GB to [GB]" do
        expect(expander.territories("+GB")).to eq(['GB'])
      end

      it "treats GB as +GB" do
        expect(expander.territories("GB")).to eq(['GB'])
      end

      it "converts several territories correctly" do
        expect(expander.territories("+GB +DE").sort).to eq(['DE', 'GB'])
      end

      it "converts -GB to []" do
        expect(expander.territories("-GB")).to eq([])
      end

      it "doesn't mind repeated entries" do
        expect(expander.territories("+GB +GB +GB")).to eq(['GB'])
      end
    end

    context "simple territory expansion" do
      it "converts +GSA to [AT, CH, DE]" do
        expect(expander.territories("+GSA").sort).to eq(['AT', 'CH', 'DE'])
      end
    end

    context "mixed allowed / disallowed territories" do
      it "handles e.g. '+GB -GB'" do
        expect(expander.territories("+GB -GB")).to eq([])
      end

      it "handles allowed expansion with specific exceptions" do
        expect(expander.territories("+GSA -DE").sort).to eq(['AT', 'CH'])
      end
    end
  end
end
