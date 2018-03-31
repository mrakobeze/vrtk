# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gemspec

group :video_clipper do
	require 'ostruct'
	require 'logger'
end

group :collager do
	require 'ostruct'
	require 'logger'
	gem 'mini_magick'
end

group :ffmpeg do
	require 'ostruct'
	require 'logger'
end


group :applets do
	require 'ostruct'
	require 'optparse'
	require 'logger'
end

group :app do
	gem 'colorize'
	require 'optparse'
end