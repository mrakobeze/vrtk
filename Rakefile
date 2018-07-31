require 'logger'
require 'colorize'

require_relative 'rake/packager/windows_builder'
require_relative 'rake/packager/windows_packager'

class RakeDSL
	include Rake::DSL


	# noinspection RubyResolve
	alias :task_ :task
	# noinspection RubyResolve
	alias :namespace_ :namespace
	# noinspection RubyResolve
	alias :desc_ :desc

	def namespace(*args, &blk)
		namespace_(*args, &blk)
	end

	def task(*args, &blk)
		task_(*args, &blk)
	end

	def desc(*args)
		desc_(*args)
	end
end

logger               = Logger.new STDERR
logger.sev_threshold = 'DEBUG'
logger.formatter     = proc do |severity, _, _, msg|
	color = case (severity)
		        when 'DEBUG'
			        :green
		        when 'INFO'
			        :cyan
		        when 'WARN'
			        :yellow
		        when 'ERROR'
			        :light_red
		        when 'UNKNOWN'
			        :red
		        else
			        :default
	        end

	"#{("#{severity}:").colorize(color)} #{msg}\n"
end

builder = Packager::WindowsBuilder.new(logger: logger, dsl: RakeDSL.new)
builder.create_tasks

packager = Packager::WindowsPackager.new(logger: logger, dsl: RakeDSL.new)
packager.create_tasks

namespace :windows do
	desc 'Remove all built files'
	task :clean do
		rm_rf Buil
	end

	task :install do
		system ''
	end
end

task :default => %w(windows:clean windows:package:all)