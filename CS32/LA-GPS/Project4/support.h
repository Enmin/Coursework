#ifndef SUPPORT_H
#define SUPPORT_H
#include "provided.h"
#include <string>
bool operator<(const GeoCoord& lhs, const GeoCoord& rhs);
bool operator>(const GeoCoord& lhs, const GeoCoord& rhs);
bool operator==(const GeoCoord& lhs, const GeoCoord& rhs);
std::string changeText(std::string text);
#endif
