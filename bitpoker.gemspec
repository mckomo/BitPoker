# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = 'bitpoker'
  s.version      = '0.1.1'
  s.license      = 'MIT'
  s.summary      = 'Bots play poker!'
  s.description  = 'Ruby implementation of BitPoker game.'
  s.author       = 'Maciej Komorowski'
  s.email        = 'mckomo@gmail.com'
  s.files        = `git ls-files`.split("\n") - %w[.gitignore]
  s.test_files   = s.files.select { |p| p =~ /^test\/test_.*.rb/ }
  s.homepage     = 'https://github.com/mckomo/BitPoker'
  s.add_dependency 'parallel', '~> 1.11'
end
