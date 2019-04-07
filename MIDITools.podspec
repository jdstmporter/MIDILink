#
# Be sure to run `pod lib lint restlogger.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'MIDITools'
s.version          = '0.1.0'
s.summary          = 'OO Swift 5 wrapper around CoreMIDI'

s.description      = <<-DESC
A proper OO Swift 5 wrapper around CoreMIDI, specialising in methods used to link and monitor devices
DESC

s.homepage         = 'https://github.com/jdstmporter/MIDILink'
s.license          = { :type => 'BSD3', :file => 'MIDITools/LICENSE' }
s.author           = { 'jdstmporter' => 'julian.porter@auroralighting.com' }
s.source           = { :git => 'https://github.com/jdstmporter/MIDILink.git', :tag => s.version.to_s }

s.swift_version = '5'
s.platform = :osx, '10.14'

s.source_files = 'MIDITools/*.swift'

s.frameworks = 'CoreMIDI'

end
