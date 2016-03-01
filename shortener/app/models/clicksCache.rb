class ClicksCache

  #def initialize(max)
    @@cache = []
    @@MAX = 500
  #end

  def self.insert val
    @@cache << val
    if @@cache.size > @@MAX
      @@cache.shift #remove in FIFO order
    end
  end

  def self.get
    @@cache
  end

end