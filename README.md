# matlab-osx-helper

Helper tool for MATLAB on OSX

## matlab.sh

````matlab.sh```` locates and returns the newest MATLAB.app's path in your Mac.
You can use this script in order to locate MATLAB's mex path for your Makefile.

    $ ./matlab.sh
    Applications/MATLAB_R2014b.app
    
For examples, in Makefile

	MATLAB=$(shell ./matlab.sh)
	mex=$(MATLAB)/bin/mex
	CC=/usr/bin/gcc
	GPP=/usr/bin/g++
	LD=/usr/bin/ld
	LDFLAGS=-L$(MATLAB)/bin/maci64 -lm -lmex -lmx -lut

## build_mexopts.rb 

````build_mexopts.rb```` generates ````mexopts.sh```` which uses SDK's path according to your Xcode version.

    $ ./build_mexopts.rb ./my_mexopts.sh
    
For examples, in Makefile

	# compile source file with mex your original using mexopts.sh
	$(OUTPUTS):$(MEX_SOURCE) custom_mexopts.sh
		$(mex) hoge.c hoge.o -L. -f ./custom_mexopts.sh LDFLAGS=$(MEX_LDFLAGS) CFLAGS='$(CFLAGS)'
	
	# generates custom mexopts.sh
	custom_mexopts.sh:
		./build_mexopts.rb ./custom_mexopts.sh
		
## License

New BSD License.
