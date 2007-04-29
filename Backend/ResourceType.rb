#!/usr/bin/env ruby

# AgeFive
# Modernizing Riven in Ruby
#
# ResourceType
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

class ResourceType
	def initialize(typeIdentifier, resourceTableOffset, nameTableOffset)
		@typeIdentifier = typeIdentifier
		@resourceTableOffset = resourceTableOffset
		@nameTableOffset = nameTableOffset
	end

	def name
		return @typeIdentifier
	end

	def humanName
		case @typeIdentifier
		when 'tBMP'
			return 'Picture'
		when 'BLST'
			return 'Card hotspot enabling list'
		when 'CARD'
			return 'Card script'
		when 'FLST'
			return 'Card water effect list'
		when 'HSPT'
			return 'Card hotspot list'
		when 'MLST'
			return 'Card movie list'
		when 'tMOV'
			return 'Movie'
		when 'NAME'
			return 'Object name'
		when 'PLST'
			return 'Card picture list'
		when 'RMAP'
			return 'Card code map'
		when 'SFXE'
			return 'Water effect animation'
		when 'SLST'
			return 'Card ambient sound list'
		when 'VARS'
			return 'Saved game variable values'
		when 'VERS'
			return 'Version info'
		when 'tWAV'
			return 'Sound'
		when 'ZIPS'
			return 'Zip mode status'
		else
			return @typeIdentifier
		end
	end
end