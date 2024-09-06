class Store
  def initialize
    @data = {}
    @expiry_times = {}
  end

  def set(key, value, expiry_ms = nil)
    @data[key] = value
    set_expiry(key, expiry_ms) if expiry_ms
    "OK"
  end

  def get(key)
    if expired?(key)
      del(key)
      return nil
    end
    @data[key]
  end

  def del(key)
    @data.delete(key)
    @expiry_times.delete(key)
    1
  end

  private
  attr_accessor :expiry_times, :data

  def set_expiry(key, expiry_ms)
    @expiry_times[key] = Time.now + (expiry_ms / 1000.0)
  end

  def expired?(key)
    return false unless @expiry_times[key]
    Time.now > @expiry_times[key]
  end
end