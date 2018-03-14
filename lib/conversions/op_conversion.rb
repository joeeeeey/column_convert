class OpConversion < Convertion
  # 数组代码
  def list_code
    return <<~EFO
      def self.my_create(options)
        user_id = options[:user_id]
        data = options[:data]
        loan_id = options[:loan_id]

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

  def dynamic_atr(indent=4)
    str = <<~EFO
      :user_id => user_id,  
          :loan_id => loan_id, 
          :#{base_model_name.underscore}_id => #{base_model_name.underscore}_id, #{"\n#{' '*indent}:json_data => data[:json_data]," if !is_raw_model}
    EFO
    str.freeze
    return str[0..-2]
  end

  # hash 代码
  def single_code
    str = <<~EFO
      def self.my_create(options)
        user_id = options[:user_id]
        data = options[:data]
        loan_id = options[:loan_id]

        attribute = {
          #{attribute_code}
        }
        
        create!(attribute) 
      end 
    EFO
    str.freeze
    return str
  end
end