class String
  # 大于 9 位的数字应该认为是编号
  def is_integer?
    self.to_i.to_s == self && self.to_s.size < 9
  end

  def is_float?
    self.to_f.to_s == self
  end
end