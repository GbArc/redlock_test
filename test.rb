require 'travis/lock'
require 'redlock'


@options ||= {
  strategy: :redis,
  url: ENV['REDIS_URL'] || 'redis://localhost:6379',
  retries: 0
}


def thrFunc(idx)
  puts "thr_#{idx}++"
  done = false
  loop do
    done == false || break
    begin
      Travis::Lock.exclusive('locklock', @options) do
        puts "thr_#{idx} has lock"
        n = 100
        while n > 0 do
          puts "#{idx}: #{n}"
          n -=1
          sleep(0.01)
        end
        done = true
      end
    rescue Travis::Lock::Redis::LockError => e
      puts "thr_#{idx} ERROR : #{e.message}"
    end
    sleep(0.1)
  end
puts "thr_#{idx}--"
end


threads=Array.new
(0..10).each do |i|
  threads <<  Thread.new {thrFunc i }
end
threads.each do |thr|
  puts 'join ' + thr.object_id.to_s
  thr.join
  puts "thr_"+thr.object_id.to_s
end
