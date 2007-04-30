#!/usr/bin/env ruby

# AgeFive
# Modernizing Riven in Ruby
#
# RivenBitmap: decoding and (if needed) decompressing tBMP bitmaps
#
# Created by Sören Nils Kuklau on 2007-04-29.
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

# The Riven tBMP bitmap format, as detailed at
# http://www.dalcanton.it/tito/esperimenti/riven/tbmp.html, can contain 8- or
# 24-bit images, optionally compressed in a proprietary algorithm.
# contains inline Metadata on what data an archive contains, and where. Since
# this information is unlikely to change often (if at all), it is useful to
# cache it when first gathered.
# This also especially helps with the 5-CD-ROM version, where four out of five
# media (and thus, their archive Metadata) are typically offline.

# TODO: For now, 8-bit is assumed.

class RivenBitmap
	attr_reader(:width, :height, :palette)

	def initialize(path, offset, size)
		@path = path
		@offset = offset
		@size = size

		headers

		@palette = palette unless truecolor?
	end

	def headers
		file = File.new(@path, 'r')
		file.seek(@offset)

		@width = file.read(2).unpack('n')[0]
		@height = file.read(2).unpack('n')[0]

		@bytesPerRow = file.read(2).unpack('n')[0]

		@compressed = file.read(2).unpack('C')[0]
		@truecolor = file.read(2).unpack('C')[0]
	end

	def palette
		palette = Array.new()

		file = File.new(@path, 'r')
		file.seek(@offset+8+4) # skipping headers and unknown field

		(256*3).times do |i|
			puts file.read(2).unpack('C')[0]
		end

		return palette
	end

	def compressed?
		if @compressed == 4
			return true
		else
			return false
		end
	end

	def truecolor?
		# if @truecolor == 4
		# 	return true
		# else
			return false
		# end
	end
end
