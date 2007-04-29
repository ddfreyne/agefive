#!/usr/bin/env ruby
#
#  Created by Sören Nils Kuklau on 2007-04-29.
#  Copyright (c) 2007. All rights reserved.

class ResourceType
	def initialize(typeIdentifier, resourceTableOffset, nameTableOffset)
		@typeIdentifier = typeIdentifier
		@resourceTableOffset = resourceTableOffset
		@nameTableOffset = nameTableOffset
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