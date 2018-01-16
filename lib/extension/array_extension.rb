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