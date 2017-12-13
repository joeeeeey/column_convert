require_relative '../convert'
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
  date
  string
  string
  string
  int
  int
)

Convertion.convert(name, type)