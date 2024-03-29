# frozen_string_literal: true

require_relative "maiden/version"

module Maiden
  class Error < StandardError; end

  @@GRID_SIZE = 4
  
  ##                                                                                                                                                                                                                
  # gridsquare size                                                                                                                                                                                                           
  def self.precision= p
    @@GRID_SIZE = p.to_i
  end

  class Maidenhead  
    def self.valid_maidenhead?(location)
      return false unless location.is_a?String
      return false unless location.length >= 2
      return false unless (location.length % 2) == 0
      
      length = location.length / 2
      length.times do |counter|
        grid = location[counter * 2, 2]
        if (counter == 0)
          return false unless grid =~ /[a-rA-R]{2}/
        elsif (counter % 2) == 0
          return false unless grid =~ /[a-xA-X]{2}/
        else
          return false unless grid =~ /[0-9]{2}/
        end
      end
      true
    end
    def self.to_latlon(location);
      maidenhead = Maidenhead.new; maidenhead.locator = location; return [ maidenhead.lat, maidenhead.lon ]
    end
    def locator=(location)
      unless Maidenhead.valid_maidenhead?(location)
        raise ArgumentError.new("Location is not a valid Maidenhead Locator System string")
      end
      @locator = location
      @lat = -90.0
      @lon = -180.0
      pad_locator
      convert_part_to_latlon(0, 1)
      convert_part_to_latlon(1, 10)
      convert_part_to_latlon(2, 10 * 24)
      convert_part_to_latlon(3, 10 * 24 * 10)
      convert_part_to_latlon(4, 10 * 24 * 10 * 24)
    end
    def self.to_maidenhead(lat, lon, precision = 5)
      maidenhead = Maidenhead.new
      maidenhead.lat = lat
      maidenhead.lon = lon
      maidenhead.precision = precision
      maidenhead.locator
    end
    def lat=(pos); @lat = range_check("lat", 90.0, pos); end
    def lat; @lat.round(6); end
    def lon=(pos); @lon = range_check("lon", 180.0, pos); end
    def lon; @lon.round(6); end
    def precision=(value); @precision = value; end
    def precision; @precision; end
    def locator
      @locator = ''
      @lat_tmp = @lat + 90.0
      @lon_tmp = @lon + 180.0
      @precision_tmp = @precision
      calculate_field
      calculate_values
      @locator
    end
    
    private
    
    def pad_locator
      length = @locator.length / 2
      while (length < 5)
        if (length % 2) == 1
          @locator += '55'
        else
          @locator += 'LL'
        end
        length = @locator.length / 2
      end
    end
    def convert_part_to_latlon(counter, divisor)
      grid_lon = @locator[counter * 2, 1]
      grid_lat = @locator[counter * 2 + 1, 1]
      @lat += l2n(grid_lat) * 10.0 / divisor
      @lon += l2n(grid_lon) * 20.0 / divisor
    end
    def calculate_field
      @lat_tmp = (@lat_tmp / 10) + 0.0000001
      @lon_tmp = (@lon_tmp / 20) + 0.0000001
      @locator += n2l(@lon_tmp.floor).upcase + n2l(@lat_tmp.floor).upcase
      @precision_tmp -= 1
    end
    def compute_locator(counter, divisor)
      @lat_tmp = (@lat_tmp - @lat_tmp.floor) * divisor
      @lon_tmp = (@lon_tmp - @lon_tmp.floor) * divisor
      if (counter % 2) == 0
        @locator += "#{@lon_tmp.floor}#{@lat_tmp.floor}"
      else
        @locator += n2l(@lon_tmp.floor) + n2l(@lat_tmp.floor)
      end
    end
    def calculate_values
      @precision_tmp.times do |counter|
        if (counter % 2) == 0
          compute_locator(counter, 10)
        else
          compute_locator(counter, 24)
        end
      end
    end
    def l2n(letter)
      if letter =~ /[0-9]+/
        letter.to_i
      else
        letter.downcase.ord - 97
      end
    end
    def n2l(number)
      (number + 97).chr
    end
    def range_check(target, range, pos)
      pos = pos.to_f
      if pos < -range or pos > range
        raise ArgumentError.new("#{target} must be between -#{range} and +#{range}")
      end
      pos
    end
  end
  def self.to_grid lat,lon
    Maidenhead.to_maidenhead(lat,lon,@@GRID_SIZE)
  end
  def self.to_gps g
    Maidenhead.to_latlon(g)
  end
end


module GRID

  @@GRID_SIZE = 4
  ##                                                                                                                                                                                                                            
  # gridsquare size                                                                                                                                                                                                             
  def self.precision= p
    Maiden.precision = p.to_i
  end

  @@G = Hash.new { |h,k| h[k] = [] }

  ##
  # known place stack
  def self.[] k
    if k.class == String && "#{k}".length > 0
      return @@G[k]
    end
  end

  ##
  # known grid places
  def self.keys
    @@G.keys
  end
    
  ##
  # convert latitude / longitude to gridsquare
  def self.to_grid lat,lon
    g = Maiden.to_grid(lat,lon)
    @@G[g]
    return g
  end

  ##
  # convert gridsquare to latitude / longitude
  def self.to_gps g
    @@G[g]
    return Maiden.to_gps(g)
  end
end
