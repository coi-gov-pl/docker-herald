require 'socket'
require 'timeout'

def is_port_open?(ip, port)
  begin
    Timeout::timeout(1) do
      begin
        s = TCPSocket.new(ip, port)
        s.close
        return true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        return false
      end
    end
  rescue Timeout::Error
  end

  return false
end

def wait_for_port (port, max_time)
	counter = 0
	while is_port_open? 'localhost', port and counter < max_time
    sleep 1
		counter += 1
	end
end

desc 'Cleans produced image'
task :clean do
	sh 'docker rmi -f coigovpl/herald || true'
	sh 'docker images -q --filter "dangling=true" | xargs docker rmi || true'
end

desc 'Builds an image'
task :build do
	sh 'docker build -t coigovpl/herald .'
end

desc 'Run it tests'
task :test => [:build] do
	sh 'docker rm -f herald || true'
	sh 'docker rm -f postgres || true'
	sh 'docker run -d -p 5433:5432 --name=postgres postgres'
	wait_for_port 5433, 10
	sh 'docker run -d --link postgres -p 11303:11303 --name=herald coigovpl/herald'
	sh 'docker logs -f herald &'
	wait_for_port 11303, 60
	sh 'curl -ik http://localhost:11303 | grep -q "Herald - a Puppet report processor"'
	sh 'docker rm -f herald || true'
	sh 'docker rm -f postgres || true'
end

task :ci => [:clean, :test]

task :default => [:test]
