require 'rails_helper'
require 'date'


RSpec.describe FuzzyDatePart, type: :concern do
  let(:fuzzy_date) { FuzzyDatePart.new }

  describe '#value' do
    specify 'defaults to empty string' do
      expect(fuzzy_date.value.empty?).to be_truthy
    end

    specify 'converts everything to String silently' do
      fuzzy_date.value = 1234
      expect(fuzzy_date.value).to match '1234'
    end
  end

  describe '#load' do
    specify 'from string' do
      value = 1234
      obj = FuzzyDatePart.load(value)
      expect(obj).to be_a FuzzyDatePart
      expect(obj.value).to match '1234'
    end
  end

  describe '#dump' do
    specify 'just the value as string' do
      fuzzy_date.value = 1234
      str = FuzzyDatePart.dump(fuzzy_date)
      expect(str).to match '1234'
    end

    specify 'expects FuzzyDate obj' do
      expect {
        FuzzyDatePart.dump('1234')
      }.to raise_error ::ActiveRecord::SerializationTypeMismatch
    end
  end

  describe '#inspect' do
    specify 'value as string' do
      fuzzy_date.value = 1234
      expect(fuzzy_date.inspect).to match '1234'
    end
  end
end

RSpec.describe FuzzyYear, type: :concern do
  let(:fuzzy_year) { FuzzyYear.new }

  context 'parsing' do
    context 'exact years' do
      specify 'accepts number "XYZ"' do
        expect(FuzzyYear.new('1234').first).to eq 1234
      end

      specify 'denies non-number "ABC"' do
        expect {
          FuzzyYear.new('abc')
        }.to raise_error StandardError
      end
    end

    context 'fuzzy years' do
      specify 'accepts number range "XYZ-ZYX"' do
        fuzzy_year = FuzzyYear.new('1234-4321')
        expect(fuzzy_year.first).to eq 1234
        expect(fuzzy_year.last).to eq 4321
      end

      specify 'denies non-numbers "XYZ-ABC"' do
        %w(1234-abc abc-1234 abc-def).each do |arg|
          expect {
            FuzzyYear.new(arg)
          }.to raise_error StandardError
        end
      end


      specify 'denies multi-range "XYZ-IJK-LMN"' do
        expect {
          FuzzyYear.new('1234-5678-1234')
        }.to raise_error StandardError
      end

      specify 'denies unsupported characters' do
        expect {
          FuzzyYear.new('1234+5678')
        }.to raise_error StandardError
      end
    end
  end

  context 'Comparable' do
    specify 'is incomparable to other objects' do
      expect(fuzzy_year <=> '12').to be_nil
    end

    context 'with value "12"' do
      let(:fuzzy_year) { FuzzyYear.new('12') }

      context 'is smaller' do
        %w(12-13 13).each do |arg|
          specify "than \"#{arg}\"" do
            expect(fuzzy_year < FuzzyYear.new(arg)).to be_truthy
          end
        end
      end

      context 'is equal' do
        specify 'to "12"' do
          expect(fuzzy_year == FuzzyYear.new('12')).to be_truthy
        end
      end

      context 'is larger' do
        %w(11 11-13).each do |arg|
          specify "than \"#{arg}\"" do
            expect(fuzzy_year > FuzzyYear.new(arg)).to be_truthy
          end
        end
      end

      specify 'is incomparable to nil' do
        expect(fuzzy_year <=> FuzzyYear.new).to be_nil
      end
    end

    context 'with value "12-14"' do
      let(:fuzzy_year) { FuzzyYear.new('12-14') }

      context 'is smaller' do
        %w(13 12-15 13-14).each do |arg|
          specify "than \"#{arg}\"" do
            expect(fuzzy_year < FuzzyYear.new(arg)).to be_truthy
          end
        end
      end

      context 'is equal' do
        specify 'to "12-14"' do
          expect(fuzzy_year == FuzzyYear.new('12-14')).to be_truthy
        end
      end

      context 'is larger' do
        %w(11 12 12-13).each do |arg|
          specify "than \"#{arg}\"" do
            expect(fuzzy_year > FuzzyYear.new(arg)).to be_truthy
          end
        end
      end
    end
  end

  describe '#to_s' do
    specify 'just the value' do
      fuzzy_year.value = '1234'
      expect(fuzzy_year.to_s).to match '1234'
    end
  end
end


RSpec.describe FuzzyMonth, type: :concern do
  let(:fuzzy_month) { FuzzyMonth.new }

  context 'parsing' do
    context 'exact months' do
      specify 'accepts number between "1" and "12"' do
        (1..12).each do |month|
          expect(FuzzyMonth.new(month.to_s).first).to eq month
        end
      end

      specify 'accepts full English month names' do
        Date::MONTHNAMES[1..12].each do |month|
          expect(FuzzyMonth.new(month).first).to eq Date::MONTHNAMES.index(month)
        end
      end

      specify 'accepts abbreviated English month names' do
        Date::ABBR_MONTHNAMES[1..12].each do |month|
          expect(FuzzyMonth.new(month).first).to eq Date::ABBR_MONTHNAMES.index(month)
        end
      end

      specify 'denies other strings' do
        expect {
          FuzzyMonth.new('Mai')
        }.to raise_error StandardError
      end

      specify 'denies invalid month numbers' do
        expect {
          FuzzyMonth.new('0')
        }.to raise_error StandardError

        expect {
          FuzzyMonth.new('13')
        }.to raise_error StandardError
      end
    end

    context 'fuzzy months' do
      specify 'accepts two dash-separated numbers between "1" and "12"' do
        (1..11).each do |month|
          expect(FuzzyMonth.new("#{month}-#{month+1}").first).to eq month
        end
      end

      specify 'does not ensure natural order of both numbers' do
        expect {
          FuzzyMonth.new('3-1')
        }.not_to raise_error
      end

      specify 'accepts full English month names' do
        (1..11).each do |month|
          month_1 = Date::MONTHNAMES[month]
          month_2 = Date::MONTHNAMES[month+1]
          fuzzy_month = FuzzyMonth.new("#{month_1}-#{month_2}")
          expect(fuzzy_month.first).to eq month
          expect(fuzzy_month.last).to eq month+1
        end
      end

      specify 'accepts abbreviated English month names' do
        (1..11).each do |month|
          month_1 = Date::ABBR_MONTHNAMES[month]
          month_2 = Date::ABBR_MONTHNAMES[month+1]
          fuzzy_month = FuzzyMonth.new("#{month_1}-#{month_2}")
          expect(fuzzy_month.first).to eq month
          expect(fuzzy_month.last).to eq month+1
        end
      end

      specify 'accepts mixture of full and abbreviated English month names' do
        (1..11).each do |month|
          month_1 = Date::MONTHNAMES[month]
          month_2 = Date::ABBR_MONTHNAMES[month+1]
          fuzzy_month = FuzzyMonth.new("#{month_1}-#{month_2}")
          expect(fuzzy_month.first).to eq month
          expect(fuzzy_month.last).to eq month+1
        end
      end

      specify 'denies other strings' do
        expect {
          FuzzyMonth.new('Mai')
        }.to raise_error StandardError
      end
    end
  end

  context 'Comparable' do
    specify 'is incomparable to other objects' do
      expect(fuzzy_month <=> '1').to be_nil
    end

    context 'with value "2"' do
      let(:fuzzy_month) { FuzzyMonth.new('2') }

      context 'is smaller' do
        %w(2-3 3).each do |arg|
          specify "than \"#{arg}\"" do
            expect(fuzzy_month < FuzzyMonth.new(arg)).to be_truthy
          end
        end
      end

      context 'is equal' do
        specify 'to "2"' do
          expect(fuzzy_month == FuzzyMonth.new('2')).to be_truthy
        end
      end

      context 'is larger' do
        %w(1 1-3).each do |arg|
          specify "than \"#{arg}\"" do
            expect(fuzzy_month > FuzzyMonth.new(arg)).to be_truthy
          end
        end
      end

      specify 'is incomparable to nil' do
        expect(fuzzy_month <=> FuzzyMonth.new).to be_nil
      end
    end

    context 'with value "2-4"' do
      let(:fuzzy_month) { FuzzyMonth.new('2-4') }

      context 'is smaller' do
        %w(3 2-5 3-4).each do |arg|
          specify "than \"#{arg}\"" do
            expect(fuzzy_month < FuzzyMonth.new(arg)).to be_truthy
          end
        end
      end

      context 'is equal' do
        specify 'to "2-4"' do
          expect(fuzzy_month == FuzzyMonth.new('2-4')).to be_truthy
        end
      end

      context 'is larger' do
        %w(1 2 2-3).each do |arg|
          specify "than \"#{arg}\"" do
            expect(fuzzy_month > FuzzyMonth.new(arg)).to be_truthy
          end
        end
      end
    end
  end
end


RSpec.describe FuzzyDay, type: :concern do
  let(:fuzzy_day) { FuzzyDay.new }

  context 'parsing' do
    context 'exact days' do
      specify 'accepts number "XYZ"' do
        expect(FuzzyDay.new('1234').first).to eq 1234
      end

      specify 'does not ensure natural order of both numbers' do
        expect {
          FuzzyDay.new('29-3')
        }.not_to raise_error
      end

      specify 'denies non-number "ABC"' do
        expect {
          FuzzyDay.new('abc')
        }.to raise_error StandardError
      end
    end

    context 'fuzzy days' do
      specify 'accepts number range "XYZ-ZYX"' do
        fuzzy_day = FuzzyDay.new('1234-4321')
        expect(fuzzy_day.first).to eq 1234
        expect(fuzzy_day.last).to eq 4321
      end

      specify 'denies non-numbers "XYZ-ABC"' do
        %w(1234-abc abc-1234 abc-def).each do |arg|
          expect {
            FuzzyDay.new(arg)
          }.to raise_error StandardError
        end
      end


      specify 'denies multi-range "XYZ-IJK-LMN"' do
        expect {
          FuzzyDay.new('1234-5678-1234')
        }.to raise_error StandardError
      end

      specify 'denies unsupported characters' do
        expect {
          FuzzyDay.new('1234+5678')
        }.to raise_error StandardError
      end
    end
  end

  context 'Comparable' do
    specify 'is incomparable to other objects' do
      expect(fuzzy_day <=> '12').to be_nil
    end

    context 'with value "12"' do
      let(:fuzzy_day) { FuzzyDay.new('12') }

      context 'is smaller' do
        %w(12-13 13).each do |arg|
          specify "than \"#{arg}\"" do
            expect(fuzzy_day < FuzzyDay.new(arg)).to be_truthy
          end
        end
      end

      context 'is equal' do
        specify 'to "12"' do
          expect(fuzzy_day == FuzzyDay.new('12')).to be_truthy
        end
      end

      context 'is larger' do
        %w(11 11-13).each do |arg|
          specify "than \"#{arg}\"" do
            expect(fuzzy_day > FuzzyDay.new(arg)).to be_truthy
          end
        end
      end

      specify 'is incomparable to nil' do
        expect(fuzzy_day <=> FuzzyDay.new).to be_nil
      end
    end

    context 'with value "12-14"' do
      let(:fuzzy_day) { FuzzyDay.new('12-14') }

      context 'is smaller' do
        %w(13 12-15 13-14).each do |arg|
          specify "than \"#{arg}\"" do
            expect(fuzzy_day < FuzzyDay.new(arg)).to be_truthy
          end
        end
      end

      context 'is equal' do
        specify 'to "12-14"' do
          expect(fuzzy_day == FuzzyDay.new('12-14')).to be_truthy
        end
      end

      context 'is larger' do
        %w(11 12 12-13).each do |arg|
          specify "than \"#{arg}\"" do
            expect(fuzzy_day > FuzzyDay.new(arg)).to be_truthy
          end
        end
      end
    end
  end

  describe '#to_s' do
    specify 'just the value' do
      fuzzy_day.value = '1234'
      expect(fuzzy_day.to_s).to match '1234'
    end
  end
end


RSpec.describe FuzzyDate, type: :concern do
  describe '#to_s' do
    specify 'range of begin and end date' do
      date = FuzzyDate.new(FuzzyYear.new('123-456'), FuzzyMonth.new('3-5'), FuzzyDay.new('6-16'))
      expect(date.to_s).to match "#{Date.new(123, 3, 6)}"
      expect(date.to_s).to match "#{Date.new(456, 5, 16)}"
    end
  end

  context 'Comparable' do
    context 'with value "1234-03-26 - 5678-02-13"' do
      let(:date) { FuzzyDate.new(FuzzyYear.new('1234-5678'),
                                 FuzzyMonth.new('3-2'),
                                 FuzzyDay.new('26-13')) }

      context 'is smaller' do
        specify 'than "1234-03-27"' do
          expect(date < Date.new(1234, 3, 27)).to be_truthy
        end
      end

      context 'is equal' do
        specify 'to "1234-03-26 - 5678-02-13"' do
          expect(date == FuzzyDate.new(date.year, date.month, date.day)).to be_truthy
        end
      end

      context 'is larger' do
        specify 'than "1234-03-26"' do
          expect(date > Date.new(1234, 3, 26)).to be_truthy
        end
      end
    end
  end
end
