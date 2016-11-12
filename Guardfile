# expected: guard --watchdir ./ ../sqrl_test
guard 'process',
    :name => 'web',
    :command => 'foreman start web' do
    #:command => 'foreman start web -f Procfile.ssl' do
  watch(%r{lib/.+\.rb})
  watch('Guardfile')
  watch('Procfile')
end
