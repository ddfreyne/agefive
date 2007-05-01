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
#
# RivenBitmap can extract the image data for internal use, and optionally
# dump it to a Windows V3 Bitmap file.

# TODO: For now, 8-bit is assumed.

class RivenBitmap
	attr_reader(:width, :height, :palette)

	def initialize(path, offset, size)
		@path = path
		@offset = offset
		@size = size

		headers

		if truecolor?
			@dataOffset = @offset+8+4
		else
			@palette = palette
		end

		if compressed?
			@data = decompressedData
		else
			@data = data
		end
	end

	def headers
		file = File.new(@path, 'r')
		file.seek(@offset)

		@width = file.read(2).unpack('n')[0]
		@height = file.read(2).unpack('n')[0]

		@bytesPerRow = file.read(2).unpack('n')[0]

		@compressed = file.read(1).unpack('C')[0]
		@truecolor = file.read(1).unpack('C')[0]

		file.close
	end

	def truecolor?
		# if @truecolor == 4
		# 	return true
		# else
			return false
		# end
	end

	def compressed?
		if @compressed == 4
			return true
		else
			return false
		end
	end

	def palette
		# in BGR form

		palette = []

		file = File.new(@path, 'r')
		file.seek(@offset+8+4) # skipping headers and unknown field

		256.times do |i|
			palette << file.read(3).unpack('CCC')
		end

		@dataOffset = file.pos

		file.close

		return palette
	end

	def data
		file = File.new(@path, 'r')
		file.seek(@dataOffset)

		data = []

		while not file.eof?
			data << file.getc
		end

		return data
	end

	def decompressedData
		@dataOffset += 4

		file = File.new(@path, 'r')
		file.seek(@dataOffset)

		data = []

		while not file.eof?
			puts "  Position: "+file.pos.to_s+" out of "+@size.to_s

			byte = file.getc

			case byte
			when 0x00
				(file.close; return data)

				break
			when 0x01..0x3f
				# output byte*2 pixels
				puts "outputting "+(byte*2).to_s+" pixels:"
				(byte*2).times do
					data << file.getc
				end

				next
			when 0x40..0x7f
				# repeat last 2 pixels byte-0x40 times
				puts "repeat last 2 pixels "+(byte-0x40).to_s+" times!"
				(byte-0x40).times do
					data += data.last(2)
				end

				next
			when 0x80..0xbf
				# repeat last 4 pixels byte-0x80 times
				puts "repeat last 4 pixels "+(byte-0x80).to_s+" times!"
				(byte-0x80).times do
					data += data.last(4)
				end

				next
			when 0xc0..0xff
				# byte-0xc0 subcommands will follow
				puts (byte-0xc0).to_s+" subcommands will follow!"
				(byte-0xc0).times do
					puts "  Position: "+file.pos.to_s+" out of "+@size.to_s

					subbyte = file.getc

					case subbyte
					when 0x01..0x0f
						# repeat duplet subbyte duplets before
						puts "repeat duplet "+subbyte.to_s+" duplets before"

						data += data.slice(-subbyte*2, subbyte*2)

						next
					when 0x10
						# repeat last duplet, but change second pixel to next byte
						puts "repeat last duplet, but change second pixel"

						data += data.slice(-2, 1)
						data << file.getc

						next
					when 0x11-0x1f
						data += data.slice(-2, 1)
						data += data.slice(-(subbyte-0x10), 1)

						next
					when 0x20-0x2f
						data += data.last(2)
						data.last += (subbyte-0x20)

						next
					when 0x30-0x3f
						data += data.last(2)
						data.last -= (subbyte-0x30)

						next
					when 0x40
						# repeat last duplet, but change first pixel to next byte
						puts "repeat last duplet, but change first pixel"

						data << file.read(1)
						data += data.slice(-2, 1)

						next
					when 0x41-0x4f
						data += data.slice(-(subbyte-0x40), 1)
						data += data.slice(-2, 1)

						next
					when 0x50
						2.times do
							data << file.getc
						end

						next
					when 0x51-0x57
						data += data.slice(-(subbyte-0x50), 1)
						data << file.getc

						next
					when 0x59-0x5f
						data << file.getc
						data += data.slice(-(subbyte-0x58), 1)

						next
					when 0x60-0x6f
						data << file.getc
						data << (data.slice(-2, 1)[0] + (subbyte-0x60))

						next
					when 0x70-0x7f
						data << file.getc
						data << (data.slice(-2, 1)[0] - (subbyte-0x70))

						next
					when 0x80-0x8f
						data << (data.slice(-2, 1)[0] + (subbyte-0x80))
						data += data.slice(-2, 1)

						next
					when 0x90-0x9f
						data << (data.slice(-2, 1)[0] + (subbyte-0x90))
						data << file.getc

						next
					when 0xa0
						xy = file.getc.divmod(16)

						data << (data.slice(-2, 1)[0] + xy[0])
						data << (data.slice(-2, 1)[0] + xy[1])

						next
					when 0xb0
						xy = file.getc.divmod(16)

						data << (data.slice(-2, 1)[0] + xy[0])
						data << (data.slice(-2, 1)[0] - xy[1])

						next
					when 0xc0-0xcf
						# TODO: implement

						next
					when 0xd0-0xdf
						# TODO: implement

						next
					when 0xe0
						xy = file.getc.divmod(16)

						data << (data.slice(-2, 1)[0] - xy[0])
						data << (data.slice(-2, 1)[0] + xy[1])

						next
					when 0xf0
						xy = file.getc.divmod(16)

						data << (data.slice(-2, 1)[0] - xy[0])
						data << (data.slice(-2, 1)[0] - xy[1])

						next
					when 0xfc
						# TODO: implement

						next
					when 0xff
						xy = file.getc.divmod(16)

						data << (data.slice(-2, 1)[0] - xy[0])
						data << (data.slice(-2, 1)[0] - xy[1])

						next
					else
						puts "unknown subcommand"

						next
					end
				end

				next
			end
		end

		(file.close; return data)
	end

	def flipVertically(data)
		oldData = []
		oldData += @data
		flippedData = []

		(oldData.length / @bytesPerRow).times do
			flippedData += oldData.slice!(-(@bytesPerRow), @bytesPerRow)
		end

		return flippedData
	end

	def dumpBMP(path)
		bmpData = flipVertically(data)

		file = File.new(path, 'w')

		file.write("BM") # magic word
		file.write([1940].pack('L')) # bitmap data size (file size?), apparently ignored
		file.write([0].pack('L')) # vendor info, unused

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
			file.write([16777216].pack('L'))
		else
			file.write([256].pack('L'))
		end

		file.write([0].pack('L')) # important colors

		unless truecolor?
			@palette.each do |color|
				file.write([color[0]].pack('C'))
				file.write([color[1]].pack('C'))
				file.write([color[2]].pack('C'))
				file.write([0].pack('C'))
			end
		end

		# TODO: verify that the data isn't upside-down
		# FIXME: need to fill out each row to multiples of four(?)
		srand 1234
		internalOffset = 0
		(@height-1).downto(0) do |row| # rows are stored backwards
			@width.times do |column|
#				file.write([rand(255)].pack('C'))
				file.putc(bmpData[internalOffset])
				puts row.to_s+' '+column.to_s+' '+internalOffset.to_s+' '+(bmpData[internalOffset].to_s)
				internalOffset+=1
			end
		end

		file.close
	end
end
