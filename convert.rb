require 'active_record'
require 'active_support/all'

Dir['./lib/extension/*'].each {|f|require f}

class Convertion
  attr_accessor :camel_names, :columns, :model_name, :is_list, 
                :undersocre_names, :types, :use_symbol,
                :user_references, :is_raw_model, :base_model_name

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

   @user_references = options[:user_references].nil? ? false : options[:user_references]

   @is_raw_model = options[:is_raw_model].nil? ? false : options[:is_raw_model]

   @base_model_name = options[:base_model_name]
  end

  def convert
    relation_string = "has_many :#{model_name.underscore.pluralize}, class_name: 'Warehouse::#{model_name}', dependent: :destroy"
    puts "\n\n==================== RELATION CODE IS ====================\n\n"
    puts relation_string

    code_string = @is_list ? list_code : single_code
    puts "\n\n==================== CREATE CODE IS ====================\n\n"
    puts code_string

    puts "\n\n==================== MIGRATE CODE IS ====================\n\n"
    puts "create_#{model_name.underscore}:"
    puts "rails g model #{model_name} user:#{user_references ? 'references' : 'integer'} loan_id:integer#{is_raw_model ? '' : ' json_data:text'} \\"

    if undersocre_names.size == types.size
      undersocre_names.zip(types).each{|n,t| puts "#{n}:#{t} \\"}
    end   
  end

  # 数组代码
  def list_code
    return <<~EFO
      def self.my_create(user_id, data, loan_id)
        return if data.blank?
        columns = (column_names.select{|x| !["id", "created_at", "updated_at"].include? x}).map(&:to_sym)
        array = []
        data.each do |sub_data|
          array << {
            #{attribute_code(6)}
          }
        end

        import columns, array, :validate => false
      end  
    EFO
  end

  # hash 代码
  def single_code
    str = <<~EFO
      def self.my_create(user_id, data, loan_id)
        attribute = {
          #{attribute_code}
        }

        create!(attribute) 
      end  
    EFO
    str.freeze
    return str
  end

  def attribute_code(indent=4)
    return dynamic_atr(indent) << "\n#{static_atr(indent)}"
  end

  def dynamic_atr(indent=4)
    str = <<~EFO
      :user_id => user_id,  
          :loan_id => loan_id, #{"\n#{' '*indent}:json_data => data[:json_data]," if !is_raw_model}
    EFO
    str.freeze
    return str[0..-2]
  end

  def static_atr(indent=4)
    str = ""
    @undersocre_names.zip(@camel_names).each do |under, n| 
      str << "#{' '*indent}:#{under} => #{parse_by_type(@columns[under], n)}, \n" 
    end
    str.freeze
    return str[0..-2]
  end

  def parse_by_type(type, n, use_symbol=false)
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
