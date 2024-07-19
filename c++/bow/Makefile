PROGRAM=bow

CXXFLAGS=-O0 -g -Wall -std=c++20 -static
CXXLIB+= -lpqxx -lpq -lpgcommon -lpgport -lintl -lssl -lcrypto -lz -lreadline \
	-lexecinfo -lm 
CXXLIBRARY+= -L/usr/local/lib
CXXINCLUDE+= -I/usr/local/include

CXXFLAGS+= $(CXXINCLUDE)

CXXSRC.bow=main.cc
CXXOBJ.bow=$(CXXSRC.bow:C/cc$/o/g)

CXXOBJ= $(CXXOBJ.bow)

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

