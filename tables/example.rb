require_relative '../convert'
require_relative '../lib/utils'
Dir['./lib/conversions/*.rb'].each {|f|require f}

# 属性名称
camel_names = %w(
suanhua_fraud_level
suanhua_fraud_score
suanhua_fraud_remark
)

# 属性类型
types = %w(
  string
  int
  string
)

# 是否是数组
is_list = true

# 这个 model 名称
model_name = 'SuanhuaBlacklist'

# 关联的 base_info 名称
base_models = ["SuanhuaBlacklistBaseInfo"]


NewConvertion.new({camel_names: camel_names, 
                  types: types,
                  model_name: model_name,
                  is_list: is_list,
                  use_symbol: true,
                  base_models: base_models }).convert




          
          
          