
require 'active_record'

class Array
  def polish_types
    map { |x|
      case x
      when "int" then "integer"
      when "list" then "text"
      when "double","number" then "float"
      when "date" then "datetime"
      else x  
      end
    }
  end
end

class Convertion
  def self.convert(name, types)
    types = types.polish_types

    undersocre_names = name.map{|i|i.underscore}

    columns = Hash[undersocre_names.zip(types)]

    puts "==================== CREATE CODE IS ===================="
    undersocre_names.zip(name).each {|under, n| puts ":#{under} => #{parse_by_type(columns[under], n)}, \n" }


    puts "==================== MIGRATE CODE IS ===================="
    if undersocre_names.size == types.size
      undersocre_names.zip(types).each{|n,t| puts "#{n}:#{t} \\"}
    end    
  end

  def self.parse_by_type(type, n)
    case type
    when 'string','integer','float' then "data[\"#{n}\"]"
    when 'datetime' then "(data[\"#{n}\"].to_datetime rescue nil)"  
    when 'text' then "(data[\"#{n}\"].to_json rescue nil)"  
    end
  end
end

