require 'date'


class FuzzyDatePart
  include Comparable

  RANGE_SEPARATOR = '-'

  attr_accessor :value, :first, :last, :is_fuzzy

  class << self
    def load(string)
      self.new string
    end

    def dump(obj)
      unless obj.is_a?(self)
        raise ::ActiveRecord::SerializationTypeMismatch,
              "Attribute was supposed to be a #{self}, but was a #{obj.class}. -- #{obj.inspect}"
      end
      obj.value
    end
  end

  def initialize(value=nil)
    self.value = value
    @is_fuzzy = false
    @first = nil
    @last = nil

    parse
  end

  def value=(value)
    @value = value.to_s.strip
    self.parse
  end

  def <=>(other)
    unless other.class == self.class
      return nil
    end

    if self.is_fuzzy
      if other.is_fuzzy
        if self.first != other.first
          self.first <=> other.first
        else
          self.last <=> other.last
        end
      else
        if self.first == other.first
          1
        else
          self.first <=> other.first
        end
      end
    else
      if other.is_fuzzy
        if self.first == other.first
          -1
        else
          self.first <=> other.first
        end
      else
        self.first <=> other.first
      end
    end
  end

  def inspect
    "<#{self.class.name}: '#{@value}' (#{@is_fuzzy ? 'fuzzy' : 'exact'}): #{@first} - #{@last}>"
  end

  def to_s
    @value
  end

  def parse
    if @value.empty?
      return nil
    end

    if @value['-']
      values = @value.split('-').map{ |e| e.strip }
      if values.length != 2
        raise StandardError, "Expecting either one or two numbers separated by '-': '#{@value}'."
      end
      @is_fuzzy = true
    else
      values = [@value, @value]
      @is_fuzzy = false
    end

    # first
    if values[0] =~ /^\d+$/
      @first = parse_number(values[0])
    else
      @first = name_to_number(values[0])
    end

    #last
    if values[1] =~ /^\d+$/
      @last = parse_number(values[1])
    else
      @last = name_to_number(values[1])
    end
  end

  def parse_number(string)
    string.to_i
  end

  def name_to_number(name)
  end
end


class FuzzyYear < FuzzyDatePart
  def name_to_number(name)
    raise StandardError, "Year value '#{name}' cannot be interpreted as a year number."
  end
end


class FuzzyMonth < FuzzyDatePart
  def <=>(other)
    unless other.is_a? FuzzyMonth
      return nil
    end

    super
  end

  def parse_number(string)
    number = super

    unless number.between?(1, 12)
      raise StandardError, "There is no month with number '#{number}'"
    end

    number
  end

  def name_to_number(name)
    if Date::MONTHNAMES.include? name
      Date::MONTHNAMES.index name
    elsif Date::ABBR_MONTHNAMES.include? name
      Date::ABBR_MONTHNAMES.index name
    else
      raise StandardError, "'#{name}' not a valid name for a month."
    end
  end
end


class FuzzyDay < FuzzyDatePart
  def name_to_number(name)
    raise StandardError, "Day value '#{name}' cannot be interpreted as a day number."
  end
end


#TODO finish and test it
class FuzzyDate
  include Comparable

  attr_accessor :year, :month, :day
  attr_reader :begin, :end

  def initialize(year=nil, month=nil, day=nil)
    @begin = nil
    @end = nil

    self.year = year unless year.nil?
    self.month = month unless month.nil?
    self.day = day unless day.nil?

    finalize
  end

  def year=(new_year)
    unless new_year.is_a? FuzzyYear
      raise StandardError, "Year must be a FuzzyYear, not #{new_year.class}."
    end
    @year = new_year
    finalize
  end

  def month=(new_month)
    unless new_month.is_a? FuzzyMonth
      raise StandardError, "Month must be a FuzzyMonth, not #{new_month.class}."
    end
    @month = new_month
    finalize
  end

  def day=(new_day)
    unless new_day.is_a? FuzzyDay
      raise StandardError, "Day must be a FuzzyDay not #{new_day.class}."
    end
    @day = new_day
    finalize
  end

  def to_s
    "#{@begin} - #{@end}"
  end

  def <=>(other)
    unless other.is_a? FuzzyDate or other.is_a? Date
      return nil
    end

    if other.is_a? FuzzyDate
      if @begin == other.begin
        return @end <=> other.end
      else
        return @begin <=> other.begin
      end
    else
      if @begin == other
        # for same date, a specific date is smaller than a Fuzzy one
        1
      else
        @begin <=> other
      end
    end
  end

  def finalize
    begin_year, end_year = finalize_year
    begin_month, end_month = finalize_month
    begin_day, end_day = finalize_day

    @begin = Date.new(begin_year, begin_month, begin_day)
    @end = Date.new(end_year, end_month, end_day)
  end

  private
  def finalize_year
    begin_year = 0
    end_year = Date.today.year

    if @year
      begin_year = @year.first unless @year.first.nil?
      end_year = @year.last unless @year.last.nil?
    end

    [begin_year, end_year]
  end

  private
  def finalize_month
    begin_month = 1
    end_month = 12

    if @month
      begin_month = @month.first unless @month.first.nil?
      end_month = @month.last unless @month.last.nil?
    end

    [begin_month, end_month]
  end

  private
  def finalize_day
    begin_day = 1
    end_day = -1

    if @day
      begin_day = @day.first unless @day.first.nil?
      end_day = @day.last unless @day.last.nil?
    end

    [begin_day, end_day]
  end
end
