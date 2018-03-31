require_relative '../vrtk'

require_relative 'applets/all'

module VRTK::Config
	# noinspection RubyStringKeysInHashInspection
	APPLETS = {
		'clipper'  => VRTK::Applets::ClipperApplet,
		'collager' => VRTK::Applets::CollagerApplet,
		'help'     => VRTK::Applets::HelpApplet
	}
end