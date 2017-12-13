
require 'active_record'



class Convertion
  def self.convert(name, type)
    undersocre_names = name.map{|i|i.underscore}
    puts "==================== CREATE CODE IS ===================="
    undersocre_names.zip(name).each {|u, n| puts ":#{u}=> data[\"#{n}\"], \n" }
    puts "==================== MIGRATE CODE IS ===================="
    if undersocre_names.size == type.size
      undersocre_names.zip(type).each{|n,t| puts "#{n}:#{t} \\"}
    end    
  end
end

