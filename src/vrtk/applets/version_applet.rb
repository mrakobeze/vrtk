require_relative '../../vrtk'
require_relative '../version'
require_relative '../utils/ffmpeg'
require_relative 'base_applet'

require 'ostruct'
require 'optparse'
require 'logger'
require 'mini_magick'

module VRTK::Applets
	class VersionApplet < BaseApplet

		include VRTK::Utils

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
				'ffmpeg'   => ffmpeg_version,
				'magick'   => magick_version,
				'license'  => VRTK::LICENSE
			}

			puts JSON.pretty_unparse obj
		end

		# noinspection RubyResolve
		def run_human
			text = []

			text << %[#{VRTK::NAME} #{VRTK::VERSION}]
			text << %[Codename: #{VRTK::CODENAME}]
			text << %[FFMPEG version: #{ffmpeg_version}]
			text << %[ImageMagick version: #{magick_version}]

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

		def ffmpeg_version
			ffmpeg = FFMpeg.resolve.ffmpeg
			`#{ffmpeg} -version`
				.split(/[\r\n]+/).first
				.split('Copyright').first
				.split('version').last
				.strip
		end

		def magick_version
			mogrify = MiniMagick::Tool::Mogrify.new
			mogrify << '--version'

			mogrify.call
				.split(/[\r\n]+/).first
				.split('x64').first
				.split('ImageMagick').last
				.strip
		end

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