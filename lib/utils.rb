Dir['./lib/extension/*'].each {|f|require f}
module Utils

  # 对于非顶层 key 对应的数据若为 hash 类型
  # 若这个 hash 对应的数据中有多条 null
  # 如何猜测这些 null 数据的类型?
  # 1. 对于这个 key 的数据条目, null 占比数量大于 50%
  # 2. 非 null 类型都为同一类型
  # 则认为 null 类型也都是此类型
  def guess_null_type
    
  end

  # 将数据中是 hash 类型的 key 提取出来
  def extract_hash(data, new_data={}, key_prefix='')
    data.each do |k, v|
      if v.is_a? Hash 
        extract_hash(v, new_data, "#{k.to_s}_")
      else 
        new_data.merge!("#{key_prefix + k.to_s}"=>v)  
      end
    end
    return new_data
  end

  
  # 判断数据类型 
  # 此外
  # 该方法会检查字符串类型究竟是 float, datetime true false 等
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
        p "未知变量:#{e} class: #{e.class.to_s}"
      end
    end
  end

  alias_method :convert_type, :strong_convert_type
  # 检查 String 究竟是 float, datetime true false 等
  def check_string(str)
    return 'Fixnum' if str.is_integer? 
    return 'Float' if str.is_float? 
    return 'TrueClass' if str == 'true'
    return 'FalseClass' if str == 'false'
    return 'String' if str == ""
    require 'date'
    begin
      return 'Date' if str.to_datetime
    rescue ArgumentError
      return 'String'
    end
  end

end