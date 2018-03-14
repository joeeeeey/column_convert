Dir['./lib/extension/*'].each {|f|require f}
module Utils

  # 对于非顶层 key 对应的数据若为 hash 类型
  # 若这个 hash 对应的数据中有多条 null
  # 如何猜测这些 null 数据的类型?
  # 1. 对于这个 key 的数据条目, null 占比数量小于 50%
  # 2. 非 null 类型都为同一类型
  # 则认为 null 类型也都是此类型
  def guess_null_type(v)
    groups = {}
    v.each do |k, e_v|
      if e_v.nil?
        groups[nil] ? groups[nil] += 1 : groups[nil] = 1
      else 
        groups[e_v.class.to_s] ? groups[e_v.class.to_s] += 1:groups[e_v.class.to_s] = 1
      end
    end

    keys = groups.keys
    if keys.include?(nil) &&  keys.size == 2 
      data_counts = groups.values.sum
      if groups[nil].to_f/data_counts <= 0.4
        # TODO 给缺失赋予值
      end

    end
    return v
  end

  def polish_key(origin_key, key_mapping)
    destination_key = key_mapping[origin_key]
    if !destination_key.nil?

      if destination_key == ""
        return ""
      else 
        return "#{destination_key}_"
      end
    end
    return "#{origin_key.to_s}_"
  end

  # 将数据中是 hash 类型的 key 提取出来
  def extract_hash(data, new_data={}, key_prefix='', guess=false, key_mapping = {})
    data.each do |k, v|
      if v.is_a? Hash 
        v = guess_null_type(v) if guess
        extract_hash(v, new_data, polish_key(k, key_mapping), guess, key_mapping)
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