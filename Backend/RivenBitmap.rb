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

		@compressed = file.read(1).unpack('C')[0]
		@truecolor = file.read(1).unpack('C')[0]
	end

	def palette
		# in BGR form

		palette = Array.new()

		file = File.new(@path, 'r')
		file.seek(@offset+8+4) # skipping headers and unknown field

		256.times do |i|
			color = Array.new()

			3.times do
				color << file.read(1).unpack('C')[0]
			end

			palette << color
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

	def dumpBMP(path)
		file = File.new(path, 'w')

		file.write("BM") # magic word
		file.write([1940].pack('L')) # bitmap data size (file size?)
		file.write("AgFv") # vendor information

		if truecolor?
			file.write([(14 + 40)].pack('L')) # bitmap data offset
		else
			file.write([(14 + 40 + (256*4))].pack('L')) # bitmap data offset
		end

		file.write([40].pack('L')) # header size
		file.write([@width].pack('L'))
		file.write([@height].pack('L'))

		file.write([0].pack('S')) # number of color planes

		if truecolor?
			file.write([24].pack('S'))
		else
			file.write([8].pack('S'))
		end

		file.write([0].pack('L')) # no compression

		file.write([(@width*@height)].pack('L')) # image size
		file.write([(72/0.0254).round].pack('L')) # horizontal and vertical
		file.write([(72/0.0254).round].pack('L')) #  resolution in pixels per meter

		if truecolor?
			file.write([16777216].pack('S'))
		else
			file.write([256].pack('S'))
		end

		file.write([0].pack('L')) # important colors

		# FIXME: appears to give incorrect palette
		@palette.each do |color|
			file.write((color + ['\0']).pack('L'))
		end

		# TODO: fill with actual, non-random image data
		srand 1234
		(@width*@height).times do
			file.write([rand(255)].pack('C'))
		end
	end
end
