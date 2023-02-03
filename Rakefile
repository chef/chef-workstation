begin
  require "chefstyle"
  require "rubocop/rake_task"
  desc "Run Chefstyle tests"
  RuboCop::RakeTask.new(:style) do |task|
    task.options += ["--display-cop-names", "--no-color"]
  end
rescue LoadError
  puts "chefstyle gem is not installed. bundle install first to make sure all dependencies are installed."
end
task default: %i{style}

desc "Update the One True Gemfile.lock in the components/gems directory with the latest dependencies."
task :update do
  require "bundler"
  Bundler.with_unbundled_env do
    Dir.chdir("./components/gems/") do
      sh "bundle _2.1.4_ lock --update --add-platform ruby x64-mingw32 x86-mingw32 x64-mingw-ucrt"
    end
  end
end
