class String
  def prepend(str)
    str + self
  end

  def prepend_if_not_exist(str)
      return self.prepend str unless self.include? str
      self
  end
end