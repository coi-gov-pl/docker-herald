
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
	sh 'docker rm -f herald'
	sh 'docker rm -f postgres'
	sh 'docker run -d -p 5433:5432 --name=postgres postgres'
	sh 'sleep 5'
	sh 'docker run -d --link postgres -p 11303:11303 --name=herald coigovpl/herald'
	sh 'docker logs -f herald &'
	sh 'sleep 10'
	sh 'curl -ik http://localhost:11303'
	sh 'docker rm -f herald'
	sh 'docker rm -f postgres'
end

task :ci => [:clean, :test]

task :default => [:test]
