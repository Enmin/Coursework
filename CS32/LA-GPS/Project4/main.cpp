// The main.cpp you can use for testing will replace this file soon.

#include <iostream>
#include "provided.h"
#include "MyMap.h"
#include <algorithm>
#include <cmath>
#include <cassert>
using namespace std;
void example()
{
	MyMap<string, double> nameToGPA; // maps student name to GPA
									 // add new items to the binary search tree-based map
	nameToGPA.associate("Carey", 3.5); // Carey has a 3.5 GPA
	nameToGPA.associate("David", 3.99); // David beat Carey
	nameToGPA.associate("Abe", 3.2); // Abe has a 3.2 GPA
	double* davidsGPA = nameToGPA.find("David");
	if (davidsGPA != nullptr)
		*davidsGPA = 1.5; // after a re-grade of David¡¯s exam
	nameToGPA.associate("Carey", 4.0); // Carey deserves a 4.0
										   // replaces old 3.5 GPA
	double* lindasGPA = nameToGPA.find("David");
	if (lindasGPA == nullptr)
		cout << "Linda is not in the roster!" << endl;
	else
		cout << "Linda¡¯s GPA is: " << *lindasGPA << endl;
}
void example1(MapLoader &ml)
{
	AttractionMapper am; // note - you shouldn¡¯t define a AttractionMapperImpl
						 // instead, just define a AttractionMapper class and
						 // we¡¯ll have our class use your AttractionMapperImpl
						 // class automagically
	am.init(ml); // let our object build its internal data structures
				 // by iterating thru all segments from your MapLoader
	GeoCoord fillMe;
	std::string attraction = "The Coffee Bean & Tea Leaf";
	bool found = am.getGeoCoord(attraction, fillMe);
	if (found == false)
	{
		cout << "Error - no GeoCoord found matching this attraction\n";
		return;
	}
	cout << "The location of " << attraction << " is : " <<  fillMe.latitude << ", " << fillMe.longitude << std::endl;
}
void example2(MapLoader &ml)
{
	SegmentMapper sm; // note - you shouldn¡¯t define a SegmentMapperImpl class
					  // instead, just define a SegmentMapper class and we¡¯ll
					  // have our class use your SegmentMapperImpl class
					  // automagically
	sm.init(ml); // let our object build its internal data structures
				 // by iterating thru all segments from your MapLoader
	GeoCoord lookMeUp("34.0572000", "-118.4417620");
	std::vector<StreetSegment> vecOfAssociatedSegs(sm.getSegments(lookMeUp));
	if (vecOfAssociatedSegs.size() == 0)
	{
		cout << "Error - no segments found matching this coordinate\n";
		return;
	}
	cout << "Here are all the segments associated with your coordinate : \n";
	for (auto s : vecOfAssociatedSegs)
	{
		cout << "Segment¡¯s street : " << s.streetName << std::endl;
		cout << "Segment¡¯s start lat / long: " << s.segment.start.latitude << ", " <<
			s.segment.start.longitude << std::endl;
		cout << "Segment¡¯s end lat / long: " << s.segment.end.latitude << ", " <<
			s.segment.end.longitude << std::endl;
		cout << "This segment has " << s.attractions.size() <<
			" attractions on it.\n";
	}
}
void test()
{
	MapLoader ml;
	ml.load("mapdata.txt");
	example();
	example1(ml);
	example2(ml);
}
void navi_test()
{
	Navigator navi;
	navi.loadMapData("mapdata.txt");
	vector<NavSegment> gps;
	navi.navigate("1061 Broxton Avenue", "Headlines!", gps);
	if (gps.size() == 0)
	{
		cout << "no Solution" << endl;
	}
	else
	{
		cout << "yes solution" << endl;
		for (unsigned int i = 0; i < gps.size(); i++)
		{
			cout << "Type: " << (gps[i].m_command == 0 ? "PROCEED" : "TURN") << endl;
			cout << "Start: " << gps[i].m_geoSegment.start.latitudeText << " " << gps[i].m_geoSegment.start.longitudeText << endl;
			cout << "End: " << gps[i].m_geoSegment.end.latitudeText << " " << gps[i].m_geoSegment.end.longitudeText << endl;
			cout << "Direction: " << gps[i].m_direction << endl;
			cout << "Distance: " << gps[i].m_distance << endl;
			cout << "Street: " << gps[i].m_streetName << endl;
			cout << endl;
		}
	}
}
int main()
{
	//test();
	cout << "About to test MyMap" << endl;
	{
		MyMap<int, string> mm;
		mm.associate(20, "Ethel");
		mm.associate(10, "Fred");
		const string* p = mm.find(10);
		assert(p != nullptr  &&  *p == "Fred");
		assert(mm.find(30) == nullptr);
		assert(mm.size() == 2);
	}
	cout << "MyMap PASSED" << endl;

	cout << "About to test MapLoader" << endl;
	{
		MapLoader ml;
		assert(ml.load("testmap.txt"));
		size_t numSegments = ml.getNumSegments();
		assert(numSegments == 7);
		bool foundAttraction = false;
		for (size_t i = 0; i < numSegments; i++)
		{
			StreetSegment seg;
			assert(ml.getSegment(i, seg));
			if (seg.streetName == "Picadilly")
			{
				assert(seg.attractions.size() == 1);
				assert(seg.attractions[0].name == "eros statue");
				foundAttraction = true;
				break;
			}
		}
		assert(foundAttraction);
	}
	cout << "MapLoader PASSED" << endl;

	cout << "About to test AttractionMapper" << endl;
	{
		MapLoader ml;
		assert(ml.load("testmap.txt"));
		AttractionMapper am;
		am.init(ml);
		GeoCoord gc;
		assert(am.getGeoCoord("Hamleys Toy Store", gc));
		assert(gc.latitudeText == "51.512812");
		cout << gc.longitudeText << endl;
		assert(gc.longitudeText == "-0.140114");
	}
	cout << "AttractionMapper PASSED" << endl;

	cout << "About to test SegmentMapper" << endl;
	{
		MapLoader ml;
		assert(ml.load("testmap.txt"));
		SegmentMapper sm;
		sm.init(ml);
		GeoCoord gc("51.510087", "-0.134563");
		vector<StreetSegment> vss = sm.getSegments(gc);
		assert(vss.size() == 4);
		string names[4];
		for (size_t i = 0; i < 4; i++)
			names[i] = vss[i].streetName;
		sort(names, names + 4);
		const string expected[4] = {
			"Coventry Street", "Picadilly", "Regent Street", "Shaftesbury Avenue"
		};
		assert(equal(names, names + 4, expected));
	}
	cout << "SegmentMapper PASSED" << endl;

	cout << "About to test Navigator" << endl;
	{
		Navigator nav;
		assert(nav.loadMapData("testmap.txt"));
		vector<NavSegment> directions;
		assert(nav.navigate("Eros Statue", "Hamleys Toy Store", directions) == NAV_SUCCESS);
		assert(directions.size() == 6);
		struct ExpectedItem
		{
			NavSegment::NavCommand command;
			string direction;
			double distance;
			string streetName;
		};
		const ExpectedItem expected[6] = {
			{ NavSegment::PROCEED, "northwest", 0.0138, "Picadilly" },
			{ NavSegment::TURN, "left", 0, "" },
			{ NavSegment::PROCEED, "west", 0.0119, "Regent Street" },
			{ NavSegment::PROCEED, "west", 0.0845, "Regent Street" },
			{ NavSegment::PROCEED, "west", 0.0696, "Regent Street" },
			{ NavSegment::PROCEED, "northwest", 0.1871, "Regent Street" },
		};
		for (size_t i = 0; i < 6; i++)
		{
			const NavSegment& ns = directions[i];
			const ExpectedItem& exp = expected[i];
			assert(ns.m_command == exp.command);
			assert(ns.m_direction == exp.direction);
			if (ns.m_command == NavSegment::PROCEED)
			{
				assert(abs(ns.m_distance - exp.distance) < 0.00051);
				assert(ns.m_streetName == exp.streetName);
			}
		}
	}
	cout << "Navigator PASSED" << endl;
}
