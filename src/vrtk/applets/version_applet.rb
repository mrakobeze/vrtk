require 'bundler'

require_relative '../../vrtk'
require_relative '../version'
require_relative 'base_applet'

require 'ostruct'
require 'optparse'
require 'logger'

module VRTK::Applets
	class VersionApplet < BaseApplet

		def init_options
			@pa = false
			OptionParser.new do |opts|
				opts.on('-p', '--parsable', 'Generate parsable version output') do |v|
					@pa = v
				end
			end
		end

		def run
			if @pa
				run_parse
			else
				run_human
			end
		end

		# noinspection RubyStringKeysInHashInspection,RubyResolve
		def run_parse
			obj = {
				'name'     => VRTK::NAME,
				'version'  => VRTK::VERSION,
				'codename' => VRTK::CODENAME,
				'ocra'     => VRTK::OCRA_VERSION,
				'ffmpeg'   => VRTK::FFMPEG_VERSION,
				'magick'   => VRTK::MAGICK_VERSION,
				'license'  => VRTK::LICENSE
			}
		end

		# noinspection RubyResolve
		def run_human
			text = []

			text << %[#{VRTK::NAME} #{VRTK::VERSION}]
			text << %[Codename: #{VRTK::CODENAME}]
			text << %[OCRA version: #{VRTK::OCRA_VERSION || 'no ocra'}]
			text << %[FFMPEG version: #{VRTK::FFMPEG_VERSION || 'no ffmpeg'}]
			text << %[ImageMagick version: #{VRTK::MAGICK_VERSION || 'no ImageMagick'}]

			text << ''
			text << %q[You can use '-p' option to get output in JSON.]
			text << ''
			text << ''

			text << disclaimer

			puts text.join("\n")
		end

		def self.name
			'Version applet'
		end

		def self.id
			'version'
		end

		def self.desc
			'Displays VRTK version'
		end

		private

		def disclaimer
			[
				%q[Copyright 2018 MRAKOBEZE],
				%q[],
				%q[Licensed under the Apache License, Version 2.0 (the "License");],
				%q[you may not use this file except in compliance with the License.],
				%q[You may obtain a copy of the License at],
				%q[],
				%q[http://www.apache.org/licenses/LICENSE-2.0],
				%q[],
				%q[Unless required by applicable law or agreed to in writing, software],
				%q[distributed under the License is distributed on an "AS IS" BASIS,],
				%q[WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.],
				%q[See the License for the specific language governing permissions and],
				%q[limitations under the License.]
			].join "\n"

		end
	end
end