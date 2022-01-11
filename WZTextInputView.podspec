

Pod::Spec.new do |s|
  s.name             = 'WZTextInputView'
  s.version          = '0.1.0'
  s.summary          = 'A short description of WZTextInputView.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://code.aliyun.com/wzlyios/WZTextInputView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'qiuqiqixang' => '739140860@qq.com' }
  s.source           = { :git => 'https://code.aliyun.com/wzlyios/WZTextInputView.git', :tag => s.version.to_s }

  s.swift_version         = '5.0'
  s.ios.deployment_target = '9.0'
  s.source_files = 'WZTextInputView/Classes/**/*'

end
