class NewConvertion < Convertion
  attr_accessor :camel_names, :columns, :model_name, :is_list, 
                :undersocre_names, :types, :use_symbol,
                :user_references, :is_raw_model, :base_model_name,
                :base_models

  def initialize(options={})
   @camel_names = options[:camel_names]
   
   @use_symbol = options[:use_symbol]
   @use_symbol = true if @use_symbol.nil?

   @undersocre_names = @camel_names.map{|i|i.underscore}

   # 将如 int 这种非 ruby 类型转化为 ruby 类型
   @types = options[:types].polish_types

   if undersocre_names.size == types.size
     @columns = Hash[undersocre_names.zip(types)]
   end

   @model_name = options[:model_name]

   @is_list = options[:is_list]

   @user_references = options[:user_references].nil? ? false : options[:user_references]

   @is_raw_model = options[:is_raw_model].nil? ? false : options[:is_raw_model]

   @base_model_name = options[:base_model_name]
   @base_models = options[:base_models] # => ["AsdDataBaseInfo", "BfsReportBaseInfo"]
  end

  def convert
    relation_string = "has_many :#{model_name.underscore.pluralize}, class_name: 'Warehouse::#{model_name}', dependent: :destroy"
    puts "\n\n==================== ADD RELATION CODE IN user.rb ====================\n\n"
    puts relation_string

    if base_models.present?
      puts "\n==================== ADD RELATION CODE IN #{base_models.map{|e|e.underscore+'.rb'}.join(',')} ====================\n\n"
      # base_model_relation_string = "has_many :#{model_name.underscore.pluralize}, class_name: 'Warehouse::#{model_name}', dependent: :destroy"
      base_models.each do |e|
        str = @is_list ? "\nhas_many :#{model_name.underscore.pluralize}, dependent: :destroy\n" : "\nhas_one :#{model_name.underscore.singularize}, dependent: :destroy\n"
        puts str
        puts "\n==================== ADD RELATION CODE IN #{model_name.underscore+'.rb'} ====================\n\n"
        str2 = "belongs_to :#{e.underscore}"
        puts str2
      end
    end

    code_string = @is_list ? list_code : single_code
    puts "\n\n==================== CREATE CODE IN #{model_name.underscore+'.rb'} IS ====================\n\n"
    puts code_string

    puts "\n\n==================== MIGRATE CODE IS ====================\n\n"
    puts "create_#{model_name.underscore}:"
    puts "rails g model #{model_name} #{user_references ? 'user:references' : 'user_id:integer'} \\"

    # 增加关联外键字段
    if base_models.present?
      base_models.each {|e|puts "#{e.underscore}_id:integer \\"}
    end
    if undersocre_names.size == types.size
      undersocre_names.zip(types).each{|n,t| puts "#{n}:#{t} \\"}
    end   
  end

  def belongs_relation(base_models)
    str = ""
    base_models.each {|e|str += "belongs_to :#{e.underscore}\n"}
    return str
  end
  # 数组代码
  def list_code
    return <<~EFO
    module Warehouse
      class #{model_name} < WarehouseBase
        #{belongs_relation(base_models)}
        def self.my_create(options)
          user_id = options[:user_id]
          relation_model_data = options[:relation_model_data]
          data = options[:data]

          columns = (column_names.select{|x| !["id", "created_at", "updated_at"].include? x}).map(&:to_sym)
          array = []
          data.each do |sub_data|
            array << relation_model_data.merge!({
              #{attribute_code(6)}
            })
          end

          import columns, array, :validate => false
        end  
      end
    end
    EFO
  end

  # hash 代码
  def single_code
    str = <<~EFO
    module Warehouse
      class #{model_name} < WarehouseBase
        #{belongs_relation(base_models)}
        def self.my_create(options)
          user_id = options[:user_id]
          relation_model_data = options[:relation_model_data]
          data = options[:data]

          attribute = relation_model_data.merge!({
            #{attribute_code}
          })

          create!(attribute) 
        end  
      end
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
