CXX = g++
CXXFLAGS = -Wall -MMD -O2

EXECS = test
DEPS = ${SRCS:.o=.d}

all: ${EXECS}

test: resources.o test.o
	${CXX} ${CXXFLAGS} $^ -o $@

-include ${DEPS}

clean:
	rm *.o *.d ${EXECS}
