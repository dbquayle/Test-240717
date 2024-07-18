PROGRAM=osod

CXXFLAGS=-O0 -g -Wall -std=c++20 -static
CXXLIB+= -lpqxx
CXXLIBRARY+= -L/usr/local/lib
CXXINCLUDE+= -I/usr/local/include

CXXFLAGS+= $(CXXINCLUDE)

CXXSRC.osod=main.cc
CXXOBJ.osod=$(CXXSRC.osod:C/cc$/o/g)

CXXOBJ= $(CXXOBJ.osod)

.PHONY: all obj clean

all: $(PROGRAM)
	echo "done"

obj: $(CXXOBJ)
	echo "object files built"

clean:
	-rm $(CXXOBJ) *~ *.core $(PROGRAM)


$(PROGRAM): $(CXXOBJ)
.for p in $(PROGRAM)
	$(CXX) $(CXXLIBRARY) $(CXXFLAGS) -o $p $(CXXOBJ.$p) $(CXXLIB)
.endfor

