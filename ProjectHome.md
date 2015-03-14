**AgeFive is a re-implementation of _Riven: The Sequel to Myst_**, working off the same data files. The project eventually intends to cover everything from initial set up to save games.

Naturally, one of the first major milestones to accomplish lies in parsing the Riven Mohawk archive format as well as decoding (and, in some cases, decompressing) the tBMP image, tMOV video and tWAV audio formats, as well as other data. In order to test the feasibility and robustness, smaller apps may be written long before an actual game client: for example, a small utility to extract all images from all Riven data files, working off one and the same backend that would eventually be used for the game application.

With the thinking that performance should not be a major issue, and that the project's results should be as reusable as possible by others in the future, it is preferred to maximize code readability over code efficiency. That said, techniques will be used to help mitigate some bottlenecks. For example, a Mohawk file's metadata will only be read once, and stored in a separate file for subsequent cached use, hopefully speeding up access to individual files tremendously.

Much prior research from independent parties is used. Some relevant links can be seen to the side of this page.

Riven is Copyright © 1997 by Cyan Worlds, Inc. The project is not endorsed by or affiliated with them.