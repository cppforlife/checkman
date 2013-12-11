PROJECT_NAME = "Checkman"
CONFIGURATION = "Release"
OCUNIT_LOGIC_SPECS_TARGET_NAME = "CheckmanTests"

PROJECT_ROOT = File.dirname(__FILE__)
BUILD_DIR = File.join(PROJECT_ROOT, "build")

def system_or_exit(cmd, stdout=nil)
  puts "Executing #{cmd}"
  cmd += " >#{stdout}" if stdout
  system(cmd) or raise "** Build failed **"
end

task :default => %w(
  trim_whitespace
  included_scripts:verify_ruby_syntax
  included_scripts:integration_specs
  ocunit:logic
)

%w(install build).each do |task_name|
  task(task_name) do
    system_or_exit "./bin/#{task_name}"
  end
end

desc "Trim whitespace"
task :trim_whitespace do
  system_or_exit %Q[git status --short | awk '{if ($1 != "D" && $1 != "R") print $2}' | grep -e '.*\.[cmh]$' | xargs sed -i '' -e 's/	/    /g;s/ *$//g;']
end

desc "Clean all targets"
task :clean do
  system_or_exit "rm -rf #{BUILD_DIR}/*", "/dev/null"
end

namespace :included_scripts do
  desc "Verifies Ruby syntax for included scripts"
  task :verify_ruby_syntax do
    Dir["./scripts/*.check"].each do |file|
      system_or_exit "ruby -c #{file}"
    end
  end

  desc "Run integration specs"
  task :integration_specs do
    rspec = `which rspec`.strip
    raise "** Install rspec **" if rspec.empty?
    system_or_exit "#{rspec} scripts/specs/*_spec.rb"
  end
end

namespace :ocunit do
  desc "Build and run OCUnit logic specs (#{OCUNIT_LOGIC_SPECS_TARGET_NAME})"
  task :logic do
    ENV["CEDAR_REPORTER_CLASS"] = "CDRColorizedReporter"
    system_or_exit <<-SHELL
      xcodebuild \
        -project #{PROJECT_NAME}.xcodeproj \
        -scheme #{OCUNIT_LOGIC_SPECS_TARGET_NAME} \
        -configuration #{CONFIGURATION} \
        -destination 'arch=x86_64' \
        test SYMROOT=#{BUILD_DIR}
    SHELL
  end
end
