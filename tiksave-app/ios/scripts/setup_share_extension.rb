#!/usr/bin/env ruby
require 'xcodeproj'

project_path = File.expand_path('../Runner.xcodeproj', __dir__)
project = Xcodeproj::Project.open(project_path)

ext_name = 'ShareExtension'
if project.targets.any? { |t| t.name == ext_name }
  puts "#{ext_name} target already exists. Skipping."
  exit 0
end

runner_target = project.targets.find { |t| t.name == 'Runner' }
ext_target = project.new_target(:app_extension, ext_name, :ios, '14.0')

runner_bundle_id = 'com.tiksave.tiksaveApp'
runner_target.build_configurations.each do |config|
  b_id = config.build_settings['PRODUCT_BUNDLE_IDENTIFIER']
  runner_bundle_id = b_id if b_id && !b_id.empty?
end

ext_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_NAME'] = ext_name
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "#{runner_bundle_id}.ShareExtension"
  config.build_settings['INFOPLIST_FILE'] = 'ShareExtension/Info.plist'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
  config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
  config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
end

ext_group = project.main_group.find_subpath(ext_name, true)
ext_group.set_source_tree('<group>')
ext_group.set_path(ext_name)

swift_file = ext_group.new_file('ShareViewController.swift')
ext_group.new_file('Info.plist')
ext_target.add_file_references([swift_file])

embed_phase = runner_target.copy_files_build_phases.find { |p| p.name == 'Embed App Extensions' }
unless embed_phase
  embed_phase = runner_target.new_copy_files_build_phase('Embed App Extensions')
  embed_phase.symbol_dst_subfolder_spec = :plug_ins
end
build_file = embed_phase.add_file_reference(ext_target.product_reference)
build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }

runner_target.add_dependency(ext_target)
project.save
puts "Attached #{ext_name} target to Runner.xcodeproj successfully."

