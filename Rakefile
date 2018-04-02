require_relative 'rake/ziputil'
require_relative 'rake/download'
require_relative 'src/vrtk/version'

BINDEPS = {
	ffmpeg: %w(ffmpeg ffmpeg/ffprobe.exe ffmpeg/ffmpeg.exe),
	magick: %w(magick magick/magick.exe magick/identify.bat magick/mogrify.bat magick/montage.bat)
}

def get_bindep(dep)
	rm_rf "#{dep}"

	download("https://dist.nuklearcorp.com/misc/#{dep}.zip", "#{dep}.zip") unless File.exists? "#{dep}.zip"

	unzipper = Unzipper.new "#{dep}.zip", "#{dep}"
	unzipper.extract(verbose: true)

	rm_rf "#{dep}.zip"

	nil
end

def get_mpeg_version
	`pkg\\win32\\bin\\ffmpeg.exe -version`
		.split(/[\r\n]+/)[0]
		.split(/[\s]+/)[0...3]
		.join ' '
end

def get_magick_version
	`pkg\\win32\\bin\\magick.exe --version`
		.split(/[\r\n]+/)[0]
		.split(/[\s]+/)[1...5]
		.join ' '
end

def generate_iss(out_file)
	iss = IO.read('dist/innosetup/setup.iss') % {
		base_dir: %Q["#{File.dirname(__FILE__).gsub('\\', '\\\\')}"],
		rs_name:  %Q["vrtk-#{VRTK::CODENAME}-win32-x86_64"]
	}

	IO.write out_file, iss
end

namespace :win32 do

	desc 'Prepare all files to build'
	task(:prepare => %w(win32:prepare:ruby win32:prepare:executable)) {}
	namespace :prepare do
		task :cpsrc do
			rm_rf 'pkg/win32/src'
			mkdir_p 'pkg/win32/src'
			cp_r 'src', 'pkg/win32/src/'
			cp_r 'bin', 'pkg/win32/src/'
		end

		desc 'Update sources, do not touch binaries'
		task :source => [:cpsrc, :gen_version] {}

		desc 'Prepare ruby binaries for build'
		task :ruby => ['win32:clean'] do
			idir = nil

			cd 'bin' do
				command = 'ocra --no-enc --debug-extract --gem-minimal --no-lzma vrtk --output vrtk.exe'
				puts "#{command}"

				system command
				`vrtk.exe`

				ocr_dirs = Dir['ocr*tmp']
				raise 'Couldn\'t find ocra output dir' unless ocr_dirs.size > 0

				rm_rf 'vrtk.exe'

				idir = File.absolute_path ocr_dirs[0]
			end

			mv idir, 'pkg/win32'

		end

		desc 'Create executable file for current build'
		task :executable do
			Dir['dist/launcher/*'].each do |file|
				cp_r file, 'pkg/win32/'
			end
		end
	end

	desc 'Fill version file with build info'
	task :gen_version do
		v_rb = nil
		cd 'pkg/win32/src/src/vrtk' do
			v_rb = IO.readlines 'version.rb'
			v_rb.pop
		end

		v_rb << %Q[\tOCRA_VERSION = '#{`ocra --version`.split(/[\r\n]+/)[0]}']
		v_rb << %Q[\tFFMPEG_VERSION = '#{get_mpeg_version}']
		v_rb << %Q[\tMAGICK_VERSION = '#{get_magick_version}']

		v_rb << 'end'

		cd 'pkg/win32/src/src/vrtk' do
			IO.write 'version.rb', v_rb.map(&:strip).join("\n")
		end
	end

	desc 'Remove all build files'
	task :clean do
		Dir['pkg/*'].each do |file|
			rm_rf file
		end
	end

	namespace :bindeps do
		BINDEPS.each do |bindep, files|
			desc "Install '#{bindep.to_s}' bindep"
			task bindep.to_sym do
				cd 'dist' do

					files.each do |file|
						next if File.exists? file

						puts "'#{file}' bindep-file not found!"

						get_bindep(bindep.to_s)
						break
					end

				end

				Dir["dist/#{bindep.to_s}/*"].each do |file|
					cp_r file, 'pkg/win32/bin'
				end
			end
		end
	end

	desc 'Install bindeps'
	task :bindeps => BINDEPS.keys.map { |key| "win32:bindeps:#{key.to_s}" }

	namespace :build do

		desc 'Create build in folder'
		# noinspection RubyLiteralArrayInspection
		task :folder => [
			'win32:prepare',
			'win32:bindeps',
			'win32:gen_version'
		]

		desc 'Create zip-packaged build'
		task :zip => [:folder] do
			zipper = Zipper.new 'pkg/win32', "pkg/vrtk-#{VRTK::CODENAME}-win32-x86_64.zip"
			zipper.write
		end

		desc 'Create Inno script based build'
		task :inno => [:folder] do
			generate_iss('tmp.iss')
			system 'iscc tmp.iss'

			rm_rf 'tmp.iss'
		end

		namespace :inno do
			task :generate do
				generate_iss('generated.iss')
			end
		end
	end
end
