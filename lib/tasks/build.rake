# frozen_string_literal: true

desc 'Run all tests and checks'
task build: :environment do
  Dotenv.overload('.env.test')
  puts('Running all tests and analysis...')

  exec("echo 'Running rubocop...' && rubocop &&
        echo 'Running rspec...' && rspec &&
        echo 'Running cucumber...' && cucumber &&
        echo 'Running javascript analysis...' && node_modules/.bin/eslint 'app/javascript' &&
        echo 'Running style sheet analysis...' && node_modules/.bin/stylelint 'app/javascript/**/*.(s)?scss' &&
        echo 'Running bundle audit...' && bundle audit &&
        echo 'Running yarn audit...' && yarn run improved-yarn-audit &&
        echo 'Running brakeman...' && brakeman --q")
end
