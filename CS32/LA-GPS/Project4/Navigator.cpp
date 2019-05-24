#include "provided.h"
#include <string>
#include <vector>
#include <queue>
#include "MyMap.h"
#include "support.h"
using namespace std;

class NavigatorImpl
{
public:
	NavigatorImpl();
	~NavigatorImpl();
	bool loadMapData(string mapFile);
	NavResult navigate(string start, string end, vector<NavSegment>& directions) const;
private:
	AttractionMapper m_AttMap;
	SegmentMapper m_Segment;
	struct Point
	{
		Point(string name, Point* parent, GeoCoord geo,GeoCoord m_end)
		{
			m_name = name;
			m_prev = parent;
			m_geo = geo;
			m_totaldistance = 0;
			m_traveleddistance = 0;
			if (m_prev == nullptr)
			{
				m_totaldistance = distanceEarthMiles(m_geo, m_end);
			}
			else
			{
				m_traveleddistance = m_prev ->m_traveleddistance + distanceEarthMiles(m_prev->m_geo, m_geo);
				m_totaldistance = m_traveleddistance + distanceEarthMiles(m_geo, m_end);
			}
		}
		Point* m_prev;
		string m_name;
		GeoCoord m_geo;
		double m_totaldistance;
		double m_traveleddistance;
	};

	static bool comp(Point* first, Point* second);
	bool checkAttonStreet(const StreetSegment& seg, const string& dest)const;
	void ImplemntNav(Point* final, vector<NavSegment> &directions, Point* dest)
		const;
};

bool NavigatorImpl::comp(Point* first, Point* second)
{
	if (first->m_totaldistance >
		second->m_totaldistance)
	{
		return true;
	}
	else
	{
		return false;
	}
}
bool NavigatorImpl::checkAttonStreet(const StreetSegment& seg, const string& dest)const
{
	for (unsigned int i = 0; i < seg.attractions.size(); i++)
	{
		if (seg.attractions[i].name == dest)
		{
			return true;
		}
	}
	return false;
}
NavigatorImpl::NavigatorImpl()
{
}

NavigatorImpl::~NavigatorImpl()
{
}

bool
NavigatorImpl::loadMapData(string mapFile)
{
	MapLoader ml;
	if (!ml.load(mapFile))
	{
		return false;
	}
	m_AttMap.init(ml);
	m_Segment.init(ml);
	return true;
}

NavResult
NavigatorImpl::navigate(string start, string end, vector<NavSegment> &directions) const
{
	start = changeText(start);
	end = changeText(end);
	GeoCoord Geos;
	GeoCoord Geoe;
	NavResult res = NAV_NO_ROUTE;
	priority_queue<Point*, vector<Point*>, decltype(&NavigatorImpl::comp)> open(&NavigatorImpl::comp);
	MyMap<GeoCoord, Point*> close;
	if (!m_AttMap.getGeoCoord(start,Geos))
		return NAV_BAD_SOURCE;
	if (!m_AttMap.getGeoCoord(end, Geoe))
		return	NAV_BAD_DESTINATION;
	Point* now = nullptr;
	vector<StreetSegment> ss = m_Segment.getSegments
		(Geos);
	for (unsigned int i = 0; i < ss.size(); i++)
	{
		StreetSegment* street = &(ss.at(i));
		if (checkAttonStreet(*street, start))
		{
			now = new Point(street->streetName, nullptr, Geos, Geoe);
			break;
		}
	}
	open.push(now);
	while (!open.empty())
	{
		if (res == NAV_SUCCESS)
		{
			break;
		}
		now = open.top();
		open.pop();
		if (close.find(now->m_geo) != nullptr)
		{
			continue;
		}
		else
		{
			close.associate(now->m_geo, now);
		}
		vector<StreetSegment> segments = m_Segment.getSegments(now->m_geo);
		for	(unsigned int i = 0; i < segments.size(); i++)
		{
			StreetSegment* street = &(segments.at(i));
			if (checkAttonStreet(*street, end))
			{
				Point dest(street->streetName, now, Geoe, Geoe);
				ImplemntNav(now, directions, &dest);
				res = NAV_SUCCESS;
				break;
				//it does not implement the vector if it is the first time
			}
			if (street->segment.end == now->m_geo)
			{
				Point* p = new Point(street->streetName, now, street->segment.start, Geoe);
				if (close.find(p->m_geo) == nullptr)
				{
					open.push(p);
				}
			}
			else if (street->segment.start == now->m_geo)
			{
				Point* p = new Point(street->streetName, now, street->segment.end, Geoe);
				if (close.find(p->m_geo) == nullptr)
				{
					open.push(p);
				}
			}
			else
			{
				Point* p = new Point(street->streetName, now, street ->segment.end, Geoe);
				if (close.find(p->m_geo) == nullptr)
				{
					open.push(p);
				}
				p = new Point(street->streetName, now, street->segment.start, Geoe);
				if (close.find(p->m_geo) == nullptr)
				{
					open.push(p);
				}
			}
		}
	}
	while (!open.empty())
	{
		Point* kill = open.top();
		open.pop();
		delete kill;
		kill = nullptr;
	}
	close.clear();
	return res;
}
void
NavigatorImpl::ImplemntNav(Point* final, vector<NavSegment>& directions, Point* dest)const
{
	Point* p = final;
	Point* q = dest;
	vector<NavSegment> reverse;
	while (p !=nullptr)
	{
		GeoSegment geoseg(p->m_geo, q->m_geo);
		double angle =angleOfLine(geoseg);
		double distance = distanceEarthMiles(geoseg.start, geoseg.end);
		string dir = "";
		if (angle >= 0 && angle <= 22.5)
			dir = "east";
		else if (angle>22.5 && angle <= 67.5)
			dir = "northeast";
		else if (angle>67.5 && angle <= 112.5)
			dir = "north";
		else if (angle>112.5 && angle <= 157.5)
			dir = "northwest";
		else if (angle>157.5 && angle <= 202.5)
			dir = "west";
		else if (angle>202.5 && angle <= 247.5)
			dir = "southwest";
		else if (angle>247.5 && angle <=292.5)
			dir = "south";
		else if (angle>292.5 && angle <= 337.5)
			dir = "southeast";
		else if (angle>337.5 && angle < 360)
			dir ="east";
		NavSegment nav(dir, q->m_name, distance, geoseg);
		reverse.push_back(nav);
		if (p->m_name != q->m_name)
		{
			GeoSegment geosega(p->m_prev->m_geo, p->m_geo);
			GeoSegment geosegb(p->m_geo, q->m_geo);
			double angle = angleBetween2Lines(geosega, geosegb);
			string dir = "";
			if (angle >= 180)
				dir = "right";
			else
				dir = "left";
			NavSegment nav(dir, q->m_name);
			nav.m_geoSegment.start = p->m_geo;
			nav.m_geoSegment.end = q->m_geo;
			reverse.push_back(nav);
		}
		p = p->m_prev;
		q = q ->m_prev;
	}
	for (vector<NavSegment>::iterator it = directions.begin(); it !=directions.end();)
	{
		it = directions.erase(it);
	}
	for (unsigned int i = 0; i < reverse.size(); i++)
	{
		directions.push_back(reverse.at(reverse.size() - 1 -i));
	}
}

//******************** Navigator functions ************************************

// These 
//functions simply delegate to NavigatorImpl's functions.
// You probably don't want to change any of this code.

Navigator::Navigator()
{
	m_impl = new NavigatorImpl;
}

Navigator::~Navigator()
{
	delete m_impl;
}

bool Navigator::loadMapData(string mapFile)
{
	return m_impl->loadMapData(mapFile);
}

NavResult Navigator::navigate(string start, string end, vector<NavSegment>& directions)const
{
	return m_impl->navigate(start, end, directions);
}