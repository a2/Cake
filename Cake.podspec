Pod::Spec.new do |s|
  s.name             = "Cake"
  s.version          = "0.1.0"
  s.summary          = "As easy as pie charts."
  s.homepage         = "https://github.com/a2/Cake"
  s.license          = 'MIT'
  s.author           = { "Alexsander Akers" => "me@a2.io" }
  s.source           = { :git => "https://github.com/a2/Cake.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/a2'
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'Cake' => ['Pod/Assets/*.png']
  }
end
