# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'test' do
  watch(%r{^lib/(.+)\.rb$})     { |m| "test/#{m[1]}_test.rb" }
  watch(%r{^test/.+_test\.rb$})
  watch(%r{^test/test_.+\.rb$})
  watch('test/helper.rb')  { "test" }

  # Rails example
  watch(%r{^app/models/(.+)\.rb$})                   { |m| "test/unit/#{m[1]}_test.rb" }
end
