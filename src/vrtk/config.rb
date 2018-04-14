require_relative '../vrtk'

require_relative 'applets/all'

module VRTK::Config
	# noinspection RubyStringKeysInHashInspection
	APPLET_LIST = [
		VRTK::Applets::ClipperApplet,
		VRTK::Applets::CollagerApplet,
		VRTK::Applets::MetalyzerApplet,
		VRTK::Applets::TemplatorApplet,
		VRTK::Applets::ToreroApplet,
		VRTK::Applets::ReleaserApplet,
		VRTK::Applets::HelpApplet,
		VRTK::Applets::VersionApplet,
	]
	APPLETS     = APPLET_LIST.map do |applet|
		[applet.id, applet]
	end.to_h
end