#!/usr/bin/env ruby

# AgeFive
# Modernizing Riven in Ruby
#
# OSInfo: convenience methods for OS-specific info, such as file system paths
#
# Created by Sören Nils Kuklau
# Copyright (c) 2007. Some rights reserved.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# 
# The full license can be retrieved at:
# http://www.opensource.org/licenses/mit-license.php
#

require 'yaml'

class OSInfo
	#FIXME: ought to be a singleton class
	# 
# 	private_class_method :new
# 	@@osInfo = nil
# 	def OSInfo.create
# 		@@osInfo = new unless @@osInfo
# 		return @@osInfo
# #		puts 'foo'
# 	end
# 
# 	def OSInfo.new
# 	end

	def applicationSupport
		if @applicationSupport == nil
			if ENV['HOMEPATH'] != nil && ENV['HOMEPATH'].class == String && ENV['APPDATA'] != nil && ENV['APPDATA'].class == String
				@@system = 'WinNT'
				Dir.chdir(ENV['APPDATA'])
				if ! File.exists?('AgeFive')
					Dir.mkdir('AgeFive')
				end
				Dir.chdir('AgeFive')
				@applicationSupport = Dir.pwd + '/'
				# e.g.:
				# C:\Documents and Settings\foo\Application Data\AgeFive\
				# or, on Vista,
				# C:\Users\foo\AppData\Local\AgeFive\
			else
				Dir.chdir # changes to $HOME on Unix-esque systems
				if File.exists?('Library/Application Support')
					@@system = 'OSX' # or NeXTStep, for that matter, but whatever
					Dir.chdir('Library/Application Support')
					if ! File.exists?('AgeFive')
						Dir.mkdir('AgeFive')
					end
					Dir.chdir('AgeFive')
					@applicationSupport = Dir.pwd + '/'
					# e.g.:
					# /Users/foo/Library/Application Support/AgeFive/
				else
					@@system = 'Unix'
					if ! File.exists?('.AgeFive')
						Dir.mkdir('.AgeFive')
					end
					Dir.chdir('.AgeFive')
					@applicationSupport = Dir.pwd + '/'
					# e.g.:
					# /home/foo/.AgeFive/
				end
			end
		end

		return @applicationSupport
	end
end
