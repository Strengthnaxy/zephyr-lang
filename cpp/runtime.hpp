#pragma once
#include <iostream>
#include <string>
#include <cstdint>

namespace zephyr {
    using string = std::string;

    inline void print(const string& s) {
        std::cout << s << std::endl;
    }
}
