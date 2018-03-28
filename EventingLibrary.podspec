Pod::Spec.new do |s|
  s.name             = "EventingLibrary"
  s.version          = "0.0.5"
  s.summary          = "Lightweight observable framework"
  s.description      = <<-DESC
    Rx Training wheels.
    
    For more information, see [the README](https://github.com/marksands/EventingLibrary).
                        DESC
  s.homepage         = "https://github.com/marksands/EventingLibrary"
  s.license          = 'MIT'
  s.author           = { "Mark Sands" => "marksands07@gmail.com" }
  s.source           = { :git => "https://github.com/marksands/EventingLibrary.git", :tag => "v0.0.5" }
  s.requires_arc     = true

  s.ios.deployment_target = "8.0"
  
  s.source_files  = "EventingLibrary/EventingLibrary.h", "EventingLibrary/**/*.{swift}"
  s.exclude_files = "EventingLibraryTests"
end
