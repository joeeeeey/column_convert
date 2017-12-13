require_relative 'convert'
name=%w(
  name
  idCard
  certifyDate
  bindingPhone
  certifyChannel
  financialService
  isBtActivity
  status
)


type = %w(
  string
  string
  datetime
  string
  string
  string
  integer
  integer
)

Convertion.convert(name, type)