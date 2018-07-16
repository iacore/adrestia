CXX = g++
CXXFLAGS = -Wall -MMD -O2 -std=c++11
OBJECTS = colour.o resources.o unit_kind.o unit.o game_rules.o player.o player_view.o action.o choose_resources_action.o build_units_action.o

MAIN_EXEC = main
MAIN_OBJS = ${OBJECTS} main.o
MAIN_DEPS = ${MAIN_OBJS:.o=.d}

TEST_EXEC = test
TEST_OBJS = ${OBJECTS} tests/resources_test.o tests/unit_kind_test.o tests/unit_test.o tests/game_rules_test.o tests/player_test.o tests/player_view_test.o tests/action_test.o tests/test.o
TEST_DEPS = ${TEST_OBJS:.o=.d}

EXECS = ${MAIN_EXEC} ${TEST_EXEC}

all: ${EXECS}

tests/catch.hpp:
	curl https://raw.githubusercontent.com/philsquared/Catch/master/single_include/catch.hpp > tests/catch.hpp

${MAIN_EXEC}: ${MAIN_OBJS}
	${CXX} ${CXXFLAGS} $^ -o $@

${TEST_EXEC}: ${TEST_OBJS}
	${CXX} ${CXXFLAGS} $^ -o $@

-include ${MAIN_DEPS} ${TEST_DEPS}

clean:
	rm *.o *.d tests/*.o tests/*.d ${EXECS}
