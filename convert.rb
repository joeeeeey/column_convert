
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
  attr_accessor :camel_names, :columns, :model_name, :is_list, :undersocre_names, :types, :use_symbol

  def initialize(options={})

   @camel_names = options[:camel_names]
   
   @use_symbol = options[:use_symbol]
   @use_symbol = true if @use_symbol.nil?
   @undersocre_names = @camel_names.map{|i|i.underscore}

   @types = options[:types].polish_types

   if undersocre_names.size == types.size
     @columns = Hash[undersocre_names.zip(types)]
   end

   @model_name = options[:model_name]

   @is_list = options[:is_list]
  end

  def convert
    code_string = @is_list ? list_code : single_code
    puts "\n\n==================== CREATE CODE IS ====================\n\n"
    puts code_string

    puts "\n\n==================== MIGRATE CODE IS ====================\n\n"
    puts "create_#{model_name.underscore}:"
    puts "rails g model #{model_name} user:references loan_id:integer json_data:text \\"

    if @undersocre_names.size == types.size
      undersocre_names.zip(types).each{|n,t| puts "#{n}:#{t} \\"}
    end   
  end

  def list_code
    return <<-EFO
def self.my_create(user_id, data, loan_id)
  return if data.blank?
  columns = (column_names.select{|x| !["id", "created_at", "updated_at"].include? x}).map {|x|x.to_sym}
  array = []
  data.each do |sub_data|
    array << {
      :user_id => user_id,
      :loan_id => loan_id,  
      :json_data => data[:json_data],
#{attribute_string}  
    }
  end

  import columns, array, :validate => false
end  
    EFO
  end

  def single_code
    return <<-EFO
def self.my_create(user_id, data, loan_id)
  attribute = {
      :user_id=> user_id,  
      :loan_id => loan_id, 
      :json_data => data[:json_data],
#{attribute_string}  
  }

  create!(attribute) 
end  
    EFO
  end


  def attribute_string
    str = ""
    @undersocre_names.zip(@camel_names).each do |under, n| 
      str << "      :#{under} => #{parse_by_type(@columns[under], n)}, \n" 
    end
    return str
  end

  def parse_by_type(type, n, use_symbol=false)
    # use_symbol = true
    if @use_symbol
      prefix = @is_list ? "sub_data[:#{n}]" : "data[:#{n}]"
    else 
      prefix = @is_list ? "sub_data[\"#{n}\"]" : "data[\"#{n}\"]" 
    end
    case type
    when 'string' then prefix
    when 'integer','float','boolean' then "type_convert(#{prefix}, '#{type}')"
    when 'datetime' then "(#{prefix}.to_datetime rescue nil)"  
    when 'text' then "(#{prefix}.to_json rescue nil)"  
    else "parse_by_type 未知类型"
    end
  end
end

class ConvertionRaw < Convertion
  def convert
    code_string = @is_list ? list_code : single_code

    relation_string = "has_many :#{model_name.underscore.pluralize}, class_name: 'Warehouse::#{model_name}', dependent: :destroy"
    puts "\n\n==================== RELATION CODE IS ====================\n\n"
    puts relation_string

    puts "\n\n==================== CREATE CODE IS ====================\n\n"
    puts code_string

    puts "\n\n==================== MIGRATE CODE IS ====================\n\n"
    puts "create_#{model_name.underscore}:"
    puts "rails g model #{model_name} user:references loan_id:integer\\"

    if @undersocre_names.size == types.size
      undersocre_names.zip(types).each{|n,t| puts "#{n}:#{t} \\"}
    end   
  end

  def list_code
    return <<-EFO
def self.my_create(user_id, data, loan_id)
  return if data.blank?
  columns = (column_names.select{|x| !["id", "created_at", "updated_at"].include? x}).map {|x|x.to_sym}
  array = []
  data.each do |sub_data|
    array << {
      :user_id => user_id,
      :loan_id => loan_id,  
#{attribute_string}  
    }
  end

  import columns, array, :validate => false
end  
    EFO
  end

  def single_code
    return <<-EFO
def self.my_create(user_id, data, loan_id)
  attribute = {
      :user_id=> user_id,  
      :loan_id => loan_id, 
#{attribute_string}  
  }

  create!(attribute) 
end  
    EFO
  end

end

