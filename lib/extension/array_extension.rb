class Array
  def polish_types
    map { |x|
      case x.downcase
      when "int" then "integer"
      when "list" then "text"
      when "double","number","long" then "float"
      when "date" then "datetime"
      else x.downcase
      end
    }
  end
end