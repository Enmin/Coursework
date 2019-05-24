#include "support.h"
bool operator==(const GeoCoord& lhs, const GeoCoord& rhs)
{
	if (lhs.latitudeText == rhs.latitudeText && lhs.longitudeText == rhs.longitudeText)
	{
		return true;
	}
	else
	{
		return false;
	}
}
bool operator<(const GeoCoord& lhs, const GeoCoord& rhs)
{
	if (lhs.latitudeText < rhs.latitudeText)
	{
		return true;
	}
	else if(lhs.latitudeText==rhs.latitudeText)
	{
		if (lhs.longitudeText < rhs.longitudeText)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	else
	{
		return false;
	}
}
bool operator>(const GeoCoord& lhs, const GeoCoord& rhs)
{
	return !(lhs < rhs);
}
std::string changeText(std::string text)
{
	for (unsigned int i = 0; i < text.size(); i++)
	{
		int a = text[i];
		if (a < 0 || a>255)
		{
			continue;
		}
		if (isupper(text[i]))
		{
			text[i] = tolower(text[i]);
		}
	}
	return text;
}