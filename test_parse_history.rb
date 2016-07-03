require_relative 'threadDict.rb'
require_relative 'common_funcs.rb'

#ph = read('parse_history_23')
#repair = []
#ph.updateTimes.each { |t| repair.push(t) unless repair.include?(t) }
#puts repair
#ph.updateTimes = repair
#ph.write
#puts ph.updateTimes

ThreadDict.new(23).write