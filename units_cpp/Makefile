CXX = g++
CXXFLAGS = -Wall -MMD -O2 -std=c++11

EXECS = test
DEPS = ${SRCS:.o=.d}

all: ${EXECS}

test: colour.o resources.o unit_kind.o test.o
	${CXX} ${CXXFLAGS} $^ -o $@

-include ${DEPS}

clean:
	rm *.o *.d ${EXECS}
