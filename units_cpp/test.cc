#include <iostream>
#include "resources.h"

int main() {
  std::cout << "=== Adrestia C++ Test Suite ===" << std::endl;
  Resources r1(1,2,3);
  Resources r2(2,3,1);
  std::cout << "r1:       " << r1 << std::endl;
  std::cout << "r2:       " << r2 << std::endl;
  std::cout << "r1 + r2:  " << (r1 + r2) << std::endl;
  std::cout << "r1 <= r2: " << (r1 <= r2) << std::endl;
  return 0;
}
