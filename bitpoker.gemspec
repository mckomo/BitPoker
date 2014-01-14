Gem::Specification.new do |s|
   s.name         = 'bitpoker'
   s.version      = '0.1.0'
   s.license      = 'MIT'
   s.summary      = "Bots play poker!"
   s.description  = "Ruby implementation of BitPoker game."
   s.author       = "Maciej Komorowski"
   s.email        = 'mckomo@gmail.com'
   s.files        = `git ls-files`.split("\n") - %w[.gitignore]
   s.test_files   = s.files.select { |p| p =~ /^test\/test_.*.rb/ }
   s.homepage     = 'https://github.com/mckomo/BitPoker'
   s.add_dependency 'parallel', '~> 0.9', '>= 0.9.2'
end

