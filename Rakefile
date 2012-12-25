PROJECT_NAME = "Checkman"
CONFIGURATION = "Release"
OCUNIT_LOGIC_SPECS_TARGET_NAME = "CheckmanTests"

PROJECT_ROOT = File.dirname(__FILE__)
BUILD_DIR = File.join(PROJECT_ROOT, "build")

def build_dir(effective_platform_name)
  File.join(BUILD_DIR, CONFIGURATION + effective_platform_name)
end

def system_or_exit(cmd, stdout = nil)
  puts "Executing #{cmd}"
  cmd += " >#{stdout}" if stdout
  system(cmd) or raise "******** Build failed ********"
end

def with_env_vars(env_vars)
  old_values = {}
  env_vars.each do |key,new_value|
    old_values[key] = ENV[key]
    ENV[key] = new_value
  end

  yield

  env_vars.each_key do |key|
    ENV[key] = old_values[key]
  end
end

def output_file(target)
  output_dir = if ENV['IS_CI_BOX']
    ENV['CC_BUILD_ARTIFACTS']
  else
    Dir.mkdir(BUILD_DIR) unless File.exists?(BUILD_DIR)
    BUILD_DIR
  end

  output_file = File.join(output_dir, "#{target}.output")
  puts "Output: #{output_file}"
  output_file
end

task :default => [:trim_whitespace, "ocunit:logic"]

[:install, :build].each do |name|
  task name do
    system_or_exit "./bin/#{name}"
  end
end

desc "Trim whitespace"
task :trim_whitespace do
  system_or_exit %Q[git status --short | awk '{if ($1 != "D" && $1 != "R") print $2}' | grep -e '.*\.[cmh]$' | xargs sed -i '' -e 's/	/    /g;s/ *$//g;']
end

desc "Clean all targets"
task :clean do
  system_or_exit "rm -rf #{BUILD_DIR}/*", output_file("clean")
end

namespace :ocunit do
  desc "Build and run OCUnit logic specs (#{OCUNIT_LOGIC_SPECS_TARGET_NAME})"
  task :logic do
    with_env_vars("CEDAR_REPORTER_CLASS" => "CDRColorizedReporter") do
      system_or_exit "xcodebuild -project #{PROJECT_NAME}.xcodeproj -target #{OCUNIT_LOGIC_SPECS_TARGET_NAME} -configuration #{CONFIGURATION} -arch x86_64 build TEST_AFTER_BUILD=YES SYMROOT=#{BUILD_DIR}"
    end
  end
end
