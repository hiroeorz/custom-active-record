# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{custom-active-record}
  s.version = "0.1.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["hiroeorz"]
  s.date = %q{2009-07-08}
  s.email = %q{hiroe.orz@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION.yml",
     "custom-active-record.gemspec",
     "lib/custom_active_record.rb",
     "lib/custom_active_record/flexible_name_base.rb",
     "lib/custom_active_record/no_id_base.rb",
     "lib/custom_active_record/plurals_pkeys_base.rb",
     "lib/custom_active_record/plurals_pkeys_sjis_base.rb",
     "lib/custom_active_record/sjis_base.rb",
     "spec/custom-active-record_spec.rb",
     "spec/spec_helper.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/hiroeorz/custom-active-record}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{TODO}
  s.test_files = [
    "spec/spec_helper.rb",
     "spec/custom-active-record_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
