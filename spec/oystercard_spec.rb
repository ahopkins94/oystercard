require 'oystercard'
require 'pry'
require 'station'

describe Oystercard do
  let(:station) { double :station }
  let(:station2) { double :station2 }

  context 'initialization' do

    it "starts with a balance of 0" do
      expect(subject.balance).to eq(0)
    end

    it "has an empty list of journeys by default" do
      expect(subject.trips).to be_empty
    end

  end

  context 'topup' do

    before :each do
      subject.topup(10)
    end

    it 'can touch in at the beginning of a journey' do
      expect(subject.touch_in(station)).to eq(station)
    end

    it 'can be topped up' do
      expect(subject.balance).to eq 10
    end


    it 'should return a penalty fare of 6 if no entry station' do
      subject.touch_out(station)
      expect(subject.balance).to eq 4
    end

  end

  context 'topup and touch in' do

    before :each do
      subject.topup(10)
      subject.touch_in(station)
    end

    it 'forgets entry station on touch out' do
      subject.touch_out(station)
      expect(subject.start_station).to be_nil
    end

    it 'shows all previous trips' do
      subject.touch_out(station2)
      expect(subject.trips[0]["Start:"]).to eq(station)
      expect(subject.trips[0]["End:"]).to eq(station2)
    end

    it 'can touch out at the end of a journey' do
      expect(subject.touch_out(station)).to eq(subject.trips)
    end

    it 'should return a penalty fare of 6 if no exit station' do
      subject.touch_in(station)
      subject.touch_out(station)
      expect(subject.balance).to eq 4
    end

    it 'should deduct a minimum fare after a complete journey' do
      subject.touch_out(station)
      expect(subject.balance).to eq 9
    end

  end

  it 'cannot store a balance above £90' do
    expect { subject.topup(91) }.to raise_error "Cannot topup £91: maximum balance of £#{Oystercard::MAXIMUM_BALANCE}"
  end

  it 'does not allow user to touch in if balance is below minimum' do
    expect{ subject.touch_in(station) }.to raise_error 'Insufficient funds'
  end

end
