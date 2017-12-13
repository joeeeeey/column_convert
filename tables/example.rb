require_relative '../convert'
camel_names = %w(
  name
  idCard
  certifyDate
  bindingPhone
  certifyChannel
  financialService
  isBtActivity
  status
)


types = %w(
  string
  string
  date
  string
  string
  string
  int
  int
)

is_list = false

model_name = 'JdBankCardList'

Convertion.new({camel_names: camel_names, 
                types: types,
                model_name: model_name,
                is_list: is_list }).convert
