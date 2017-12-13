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
  int
  int
)

Convertion.convert(name, type)