class Store
  def initialize
    @data = {}
  end

  def set(key, value)
    @data[key] = value
    "OK"
  end

  def get(key)
    @data[key]
  end

  def del(key)
    @data.delete(key) ? 1 : 0
  end
end