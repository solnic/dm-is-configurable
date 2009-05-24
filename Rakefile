require 'pathname'
require 'rubygems'

ROOT    = Pathname(__FILE__).dirname.expand_path
JRUBY   = RUBY_PLATFORM =~ /java/
WINDOWS = Gem.win_platform?
SUDO    = (WINDOWS || JRUBY) ? '' : ('sudo' unless ENV['SUDOLESS'])

require ROOT + 'lib/dm-is-configurable/is/version'

AUTHOR = "Piotr Solnica"
EMAIL  = "piotr [a] zenbe [d] com"
GEM_NAME = "dm-is-configurable"
GEM_VERSION = DataMapper::Is::Configurable::VERSION
GEM_DEPENDENCIES = [['dm-core', '0.10.0']]
GEM_CLEAN = %w[ log pkg coverage ]
GEM_EXTRAS = { :has_rdoc => true, :extra_rdoc_files => %w[ README.txt LICENSE TODO History.txt ] }

PROJECT_NAME = "dm-is-configurable"
PROJECT_URL  = "http://github.com/solnic/dm-is-configurable/tree/master"
PROJECT_DESCRIPTION = PROJECT_SUMMARY = "DataMapper plugin which allows to add configuration to your models"

[ ROOT, ROOT.parent ].each do |dir|
  Pathname.glob(dir.join('tasks/**/*.rb').to_s).each { |f| require f }
end
