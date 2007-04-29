#!/usr/bin/env ruby

# AgeFive
# Modernizing Riven in Ruby
#
# MohawkCatalog: Caching Mohawk archive contents
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

# The Riven Mohawk archive format, as detailed at
# http://www.dalcanton.it/tito/esperimenti/riven/mohawk-archive-format.html,
# contains inline Metadata on what data an archive contains, and where. Since
# this information is unlikely to change often (if at all), it is useful to
# cache this information when first gathered, and to only look it up again
# when changed. (Such a change is determined by a different file checksum.)
# This also especially helps with the 5-CD-ROM version, where four out of five
# media (and thus, their archive Metadata) are typically offline.

require 'yaml'
require 'Backend/OSInfo'
require 'Backend/ResourceType'

class MohawkCatalog
	attr_reader(:sourceType)

	def initialize(mhkPath)
		# osInfo = OSInfo.new
		# puts osInfo.applicationSupport

		@mhkPath = mhkPath

		verifyHeaders

		@resourceDirOffset = resourceDirOffset
		@fileTableOffset = relativeFileTableOffset + @resourceDirOffset
		@fileTableSize = fileTableSize

		@resourceNameListOffset = relativeResourceNameListOffset + @resourceDirOffset

		@types = types
		@nameTables = nameTables

#		puts @types[0].humanName

#		puts @nameTables.size
#		puts @nameTables[0].size
#		puts @nameTables[0][0].size
		@nameTables[0].each {
			|item|
#			puts @resourceNameListOffset + item[0]
#			puts item[2]
		}

		# @resourceTables = resourceTables
		# @resourceNames = resourceNames
		# @files = files
	end

	def verifyHeaders
		mhkFile = File.new(@mhkPath, 'r')

		if mhkFile.read(4).to_s != "MHWK" # IFF chunk signature
			return false
		end

		if mhkFile.read(4).unpack('N')[0] != mhkFile.stat.size-8 # file size in bytes, excluding IFF header
			return false
		end

		if mhkFile.read(4).to_s != "RSRC" # RSRC chunk signature
			return false
		end

		mhkFile.seek(4, IO::SEEK_CUR) # discarding this; seems useless

		if mhkFile.read(4).unpack('N')[0] != mhkFile.stat.size # complete file size in bytes
			return false
		end

		mhkFile.close
	end

	def resourceDirOffset
		mhkFile = File.new(@mhkPath, 'r')

		mhkFile.seek(20)

		return mhkFile.read(4).unpack('N')[0]

		mhkFile.close # FIXME: find way to actually close file before returning
	end

	def relativeFileTableOffset
		mhkFile = File.new(@mhkPath, 'r')

		mhkFile.seek(24)

		return mhkFile.read(2).unpack('n')[0]

		mhkFile.close
	end

	def fileTableSize
		mhkFile = File.new(@mhkPath, 'r')

		mhkFile.seek(26)

		return mhkFile.read(2).unpack('n')[0]

		mhkFile.close
	end

	def relativeResourceNameListOffset
		mhkFile = File.new(@mhkPath, 'r')

		mhkFile.seek(@resourceDirOffset)

		return mhkFile.read(2).unpack('n')[0]

		mhkFile.close
	end

	def types
		mhkFile = File.new(@mhkPath, 'r')

		mhkFile.seek(@resourceDirOffset + 2)

		types = Array.new()

		mhkFile.read(2).unpack('n')[0].times do |n|
			types << ResourceType.new(mhkFile.read(4).to_s, mhkFile.read(2).unpack('n')[0], mhkFile.read(2).unpack('n')[0])
		end

		return types

		mhkFile.close
	end

	def nameTables
		# @nameTables[a][b] will contain:
		# {offset relative to name list, resource index}

		# FIXME: iteration bug in here /somewhere/

		mhkFile = File.new(@mhkPath, 'r')

		mhkFile.seek(@resourceDirOffset + 4 + @types.size * 8)

		nameTables = Array.new()

		@types.size.times do |n|
			nameTable = Array.new()

			mhkFile.read(2).unpack('n')[0].times do |n|
				nameEntry = Array.new()

				offset = mhkFile.read(2).unpack('n')[0]
				index = mhkFile.read(2).unpack('n')[0]

				oldOffset = mhkFile.pos

				mhkFile.seek(@resourceNameListOffset + offset)
				name = mhkFile.gets("\0")
				puts name
				mhkFile.seek(oldOffset+2)

				nameEntry << offset
				nameEntry << index
				nameEntry << name

				nameTable << nameEntry
			end

			nameTables << nameTable
		end

		return nameTables
	end
end
