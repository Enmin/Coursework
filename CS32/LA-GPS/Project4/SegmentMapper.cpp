#include "provided.h"
#include <vector>
#include "MyMap.h"
using namespace std;

class SegmentMapperImpl
{
public:
	SegmentMapperImpl();
	~SegmentMapperImpl();
	void init(const MapLoader& ml);
	vector<StreetSegment> getSegments(const GeoCoord& gc) const;
private:
	MyMap<GeoCoord, vector<StreetSegment>> SegmentMap;
	void initHelper(const GeoCoord& geo, StreetSegment& seg)
	{
		vector<StreetSegment>* p = SegmentMap.find(geo);
		if (p != nullptr)
		{
			p->push_back(seg);
		}
		else
		{
			vector<StreetSegment> n;
			n.push_back(seg);
			SegmentMap.associate(geo,n);
		}
	}
};

SegmentMapperImpl::SegmentMapperImpl()
{
}

SegmentMapperImpl::~SegmentMapperImpl()
{
}

void SegmentMapperImpl::init(const MapLoader& ml)
{
	StreetSegment seg;
	int i = 0;
	for (i = 0; i < ml.getNumSegments(); i++)
	{
		ml.getSegment(i, seg);
		initHelper(seg.segment.start,seg);
		initHelper(seg.segment.end, seg);
		for (int j = 0; j < seg.attractions.size(); j++)
		{
			if (seg.attractions[j].geocoordinates == seg.segment.start || seg.attractions[j].geocoordinates == seg.segment.end)
			{
				continue;
			}
			initHelper(seg.attractions[j].geocoordinates,seg);
		}
	}
}

vector<StreetSegment> SegmentMapperImpl::getSegments(const GeoCoord& gc) const
{
	const vector<StreetSegment> segments;
	const vector<StreetSegment>* seg = SegmentMap.find(gc);
	const vector<StreetSegment> seg2 = *seg;
	if (seg == nullptr)
	{
		return segments;
	}
	else
	{
		return seg2;
	}
}

//******************** SegmentMapper functions ********************************

// These functions simply delegate to SegmentMapperImpl's functions.
// You probably don't want to change any of this code.

SegmentMapper::SegmentMapper()
{
	m_impl = new SegmentMapperImpl;
}

SegmentMapper::~SegmentMapper()
{
	delete m_impl;
}

void SegmentMapper::init(const MapLoader& ml)
{
	m_impl->init(ml);
}

vector<StreetSegment> SegmentMapper::getSegments(const GeoCoord& gc) const
{
	return m_impl->getSegments(gc);
}
