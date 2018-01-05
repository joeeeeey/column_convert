class String
  # 大于 9 位的数字应该认为是编号
  def is_integer?
    self.to_i.to_s == self && self.to_s.size < 9
  end

  def is_float?
    self.to_f.to_s == self
  end
end

module Utils
  def convert_type(data)
    types = data.values.map do |e|
      raise RuntimeError.new('未知数据类型') if e.to_s.downcase == 'null'
      case e.class.to_s
      when 'String' then 'string'
      when 'Fixnum' then 'integer'
      when 'Float' then 'float'
      when 'TrueClass','FalseClass' then 'boolean'  
      when 'Hash' then 'text' 
      when 'Date' then 'datetime' 
      else 
        p e.class.to_s + "未知"
      end
    end

    return types
  end

  # 该方法会检查字符串类型究竟是 float, datetime, 
  def strong_convert_type(data)
    types = data.values.map do |e|
      raise RuntimeError.new('未知数据类型') if e == 'null'
      if e.class.to_s == 'String'
        type_class = check_string(e)
      else 
        type_class = e.class.to_s
      end
      case type_class
      when 'String' then 'string'
      when 'Fixnum' then 'integer'
      when 'Float' then 'float'
      when 'TrueClass','FalseClass' then 'boolean'  
      when 'Hash','Array' then 'text' 
      when 'Date' then 'datetime' 
      else 
        p e.class.to_s + "未知"
      end
    end
  end

  def check_string(str)
    return 'Fixnum' if str.is_integer? 
    return 'Float' if str.is_float? 
    return 'TrueClass' if str == 'true'
    return 'FalseClass' if str == 'false'

    require 'date'
    begin
      return 'Date' if str.to_datetime
    rescue ArgumentError
      return 'String'
    end
  end

end