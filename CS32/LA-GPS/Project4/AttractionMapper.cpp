#include "provided.h"
#include <string>
#include "MyMap.h"
#include <iostream>
using namespace std;

class AttractionMapperImpl
{
public:
	AttractionMapperImpl();
	~AttractionMapperImpl();
	void init(const MapLoader& ml);
	bool getGeoCoord(string attraction, GeoCoord& gc) const;
private:
	MyMap<string, GeoCoord> AttMap;
};

AttractionMapperImpl::AttractionMapperImpl()
{
}

AttractionMapperImpl::~AttractionMapperImpl()
{
	AttMap.clear();
}

void AttractionMapperImpl::init(const MapLoader& ml)
{
	for (unsigned int i = 0; i < ml.getNumSegments(); i++)
	{
		StreetSegment seg;
		if (ml.getSegment(i, seg))
		{
			for (unsigned int j = 0; j < seg.attractions.size(); j++)
			{
				AttMap.associate(seg.attractions.at(j).name, seg.attractions.at(j).geocoordinates);
			}
		}
	}
}

bool AttractionMapperImpl::getGeoCoord(string attraction, GeoCoord& gc) const
{
	attraction = changeText(attraction);
	const GeoCoord* tmp = AttMap.find(attraction);
	if (tmp != nullptr)
	{
		gc = *tmp;
		return true;
	}
	return false;
}

//******************** AttractionMapper functions *****************************

// These functions simply delegate to AttractionMapperImpl's functions.
// You probably don't want to change any of this code.

AttractionMapper::AttractionMapper()
{
	m_impl = new AttractionMapperImpl;
}

AttractionMapper::~AttractionMapper()
{
	delete m_impl;
}

void AttractionMapper::init(const MapLoader& ml)
{
	m_impl->init(ml);
}

bool AttractionMapper::getGeoCoord(string attraction, GeoCoord& gc) const
{
	return m_impl->getGeoCoord(attraction, gc);
}
