SHELL=/bin/bash
ACT_DIR := $(shell pwd)
CPU_COUNT := $(shell cat /proc/cpuinfo | grep processor | wc -l)
export PATH := ${PATH}:${CZENG_TOOLS_BIN}

.PHONY : check-architecture clean info extern

readme:
	# To compile trtok for a particular architecture:
	# 1. Put this Makefile in to a blank directory
	# 2. Go there
	# 3. Type: make all
	# ...it should locally install things that can be installed locally
	# ...it should ask you to globally install global things


all:
	make check-architecture
	make packages.installed
	mkdir trtok
	make trtok/trtok
	make info

trtok/trtok: trtok.compiled
	touch trtok/trtok; \
	echo 'export TRTOK_PATH='${ACT_DIR}'/trtok/' >> config.sh;

trtok.compiled: quex boost.compiled maxent.compiled trtok-src packages.installed
	source config.sh; \
	cd trtok \
	&& export QUEX_PATH=`pwd`/../quex \
	&& export BOOST_ROOT=`pwd`/../boost.compiled \
	&& cmake ../trtok-src/src \
	      -DBoost_USE_STATIC_LIBS=ON \
	      -DMaxEnt_LIBRARY=`pwd`/../maxent.compiled/lib/libmaxent.a \
	      -DMaxEnt_INCLUDE_DIR=`pwd`/../maxent.compiled/include/maxent \
	      -DBoost_USE_MULTITHREADED=OFF \
			-DCMAKE_BUILD_TYPE=Release \
	      -DINSTALL_DIR=`pwd`/../trtok \
	&& make
	touch trtok.compiled

DEPS=python g++ make cmake cmake-curses-gui libtbb-dev gfortran zlib1g zlib1g-dev libltdl-dev libpcre3 libpcre3-dev libpcrecpp0v5 libtbb2 libicu-dev
packages.installed:
	# Intel threading building blocks are needed
	dpkg -s libtbb-dev | grep Status.*installed
	for p in $(DEPS); do \
	  if dpkg -s $$p | grep Status.*installed; then \
	    echo $$p seems OK ; \
	  else \
	    echo $$p seems missing!; \
	    echo "## Please run the following to install all deps:" ; \
	    echo "  sudo apt install $(DEPS)"; \
	    exit 1; \
	  fi; \
	done
	# Everything seems OK.
	hostname > $@

trtok-src:
	git clone git@github.com:obo/trainable-tokenizer.git $@

maxent:
	git clone git://github.com/lzhang10/maxent.git

maxent.compiled: maxent boost.compiled
	source config.sh; \
	cd maxent \
	&& ./configure --prefix=`pwd`/../$@ \
	&& make \
	&& make install; \
	cd ..; \
	touch maxent.compiled;

quex: quex-0.63.1.tar.gz
	tar xzf $<; \
	f=$<; mv $${f/.tar.gz/} $@;
	touch $@
	echo 'export QUEX_PATH='${ACT_DIR}'/quex/' >> config.sh; \
	source config.sh;

boost_1_51_0.tar.gz:
	wget http://sourceforge.net/projects/boost/files/boost/1.51.0/boost_1_51_0.tar.gz

boost_1_51_0: boost_1_51_0.tar.gz
	tar xzf $<


boost.compiled: boost_1_51_0
	cd boost_1_51_0 \
	&& sh bootstrap.sh \
	&& ./b2 install --prefix=`pwd`/../$@ \
	     --with-filesystem --with-program_options \
	     --with-system --with-thread \
	     link=static \
	&& cd .. \
	&& cd $@ \
	&& echo 'export LD_LIBRARY_PATH='`pwd`'/lib:$$LD_LIBRARY_PATH' >> ../config.sh \
	&& echo 'export LIBRARY_PATH='`pwd`'/lib:$$LIBRARY_PATH' >> ../config.sh \
	&& echo 'export CPATH='`pwd`'/include:$$CPATH' >> ../config.sh; \
	touch $@


# Use a machine where cmake is installed from packages
#
# bin/cmake: cmake-2.8.5
# 	mkdir -p bin; \
# 	cd bin; \
# 	for f in ../cmake-2.8.5/bin/*; do \
# 		n=`echo $$f | cut -f4 -d/`; \
# 		ln -s $$f $$n; \
# 	done; \
# 	cd ..; \
# 	echo 'export CZENG_TOOLS_BIN='${ACT_DIR}'/bin/' >> config.sh; \
# 	source config.sh;
# 
# cmake-2.8.5: cmake-2.8.5.tar.gz
# 	tar -xzf cmake-2.8.5.tar.gz; \
# 	cd cmake-2.8.5; \
# 	./configure; \
# 	make -j ${CPU_COUNT}; \
# 	make; \
# 	cd ..;
# 
# cmake-2.8.5.tar.gz:
# 	wget http://www.cmake.org/files/v2.8/cmake-2.8.5.tar.gz;

# Use standard tbb
# tbb.compiled: tbb40_20110809oss
# 	# this does not seem to exist any more
# 	cd tbb40_20110809oss/build/linux_*_release; \
# 	tbb_dir=`pwd`; \
# 	cd ../../../; \
# 	echo "source $$tbb_dir/tbbvars.sh" >> config.sh; \
# 	source config.sh; \
# 	date >> tbb.compiled
# 
# tbb40_20110809oss: tbb40_20110809oss_src.tgz
# 	tar -xzf tbb40_20110809oss_src.tgz; \
# 	cd tbb40_20110809oss; \
# 	make -j ${CPU_COUNT}; \
# 	touch $@;
# 
# tbb40_20110809oss_src.tgz:
# 	wget 'http://threadingbuildingblocks.org/uploads/77/175/4.0/tbb40_20110809oss_src.tgz';

check-architecture:
	if [ `arch` != 'x86_64' ]; then \
		echo "x86_64 has to be used."; \
		exit 1; \
	fi;

clean:
	rm -rf trtok-src trtok.compiled bin config.sh maxent* tbb* boost boost_1_51_0 boost.compiled quex trtok/trtok trtok/analyze

info:
	echo; \
	echo "===================="; \
	echo "Add to your bashrc: "; \
	echo "source `pwd`/config.sh";

check:
	if [ ! -f trtok/trtok ]; then \
		echo "trtok is not installed"; \
		exit 1; \
	fi; \
	if [ x${TRTOK_PATH} = x ]; then \
		echo "TRTOK_PATH is not set"; \
		exit 1; \
	fi;	\
	if [ x${CZENG_TOOLS_BIN} = x ]; then \
		echo "CZENG_TOOLS_BIN is not set"; \
		exit 1; \
	fi;

