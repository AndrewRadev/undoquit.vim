task :default do
  sh 'rspec spec'
end

desc "Prepare archive for deployment"
task :archive do
  sh 'zip -r ~/undoquit.zip autoload/ doc/undoquit.txt plugin/'
end
