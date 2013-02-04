def eval_require(file_name)
  Class.new.tap do |k|
    k.class_eval(file_contents(file_name))
  end
end

def file_contents(file_name)
  specs_path = File.dirname(File.expand_path(__FILE__))
  file_path = File.join(specs_path, "..", file_name)
  contents = File.read(file_path)
end
