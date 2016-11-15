# expected: guard --watchdir ./ ../sqrl_test
guard 'process',
    :name => 'web',
    :command => 'foreman start web' do
    #:command => 'foreman start web -f Procfile.ssl' do
  watch(%r{lib/.+\.rb})
  watch(%r{../sqrl_check/lib/.+\.rb})
  watch('Guardfile')
  watch('Procfile')
end

guard 'process',
    :name => 'worker',
    :command => 'foreman start worker' do
  watch(%{lib/sqrl/check/web/sidekiq_config.rb})
  watch(%{lib/sqrl/check/web/test_worker.rb})
  watch(%{lib/sqrl/check/web/serialize_reporter.rb})
  watch(%r{../sqrl_check/lib/.+\.rb})
  watch('Guardfile')
  watch('Procfile')
end
