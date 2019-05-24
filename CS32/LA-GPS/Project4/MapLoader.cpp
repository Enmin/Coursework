#include "provided.h"
#include <string>
#include <fstream>
#include <iostream>
#include "support.h"
using namespace std;

class MapLoaderImpl
{
public:
	MapLoaderImpl();
	~MapLoaderImpl();
	bool load(string mapFile);
	size_t getNumSegments() const;
	bool getSegment(size_t segNum, StreetSegment& seg) const;
private:
	vector<StreetSegment> mapdata;
};

MapLoaderImpl::MapLoaderImpl()
{
	
}

MapLoaderImpl::~MapLoaderImpl()
{
	
}

bool MapLoaderImpl::load(string mapFile)
{
	//return false;  // This compiles, but may not be correct
	ifstream fin(mapFile);
	if (!fin)
	{
		cerr << "Error Opening File" << endl;
		return false;
	}
	string s;
	while (getline(fin, s))
	{
		StreetSegment ss;
		ss.streetName = s;
		getline(fin, s);
		string m[4] = { "","","","" };
		for (int i = 0, j = 0; i < s.size(); i++)
		{
			if (isdigit(s[i]) || s[i] == '-' || s[i] == '.')
			{
				m[j] = m[j] + s[i];
			}
			else
			{
				j++;
				for (int k = i; k < s.size(); )
				{
					k = i;
					if (s[k] == ',' || s[k] == ' ')
					{
						i++;
					}
					else
					{
						break;
					}
				}
				i--;
			}
		}
		//cout << m[0] << ", " << m[1] << endl;
		GeoCoord start(m[0], m[1]);
		GeoCoord end(m[2], m[3]);
		GeoSegment Geoseg(start, end);
		ss.segment = Geoseg;

		getline(fin, s);
		int numAtt = stoi(s);
		for (int i = 0; i < numAtt; i++)
		{
			string a_name = "";
			getline(fin, a_name, '|');
			//cout << a_name << endl;
			string a[2] = { "", "" };
			getline(fin, s);
			for (int i = 0, j = 0; i < s.size(); i++)
			{
				if (isdigit(s[i]) || s[i] == '-' || s[i] == '.')
				{
					a[j] = a[j] + s[i];
				}
				else
				{
					j++;
					for (int k = i; k < s.size(); )
					{
						k = i;
						if (s[k] == ',' || s[k] == ' ')
						{
							i++;
						}
						else
						{
							break;
						}
					}
					i--;
				}
			}
			//cout << a[0] << ", " << a[1] << endl;
			GeoCoord geoatt(a[0], a[1]);
			a_name = changeText(a_name);
			Attraction att{ a_name,geoatt };
			ss.attractions.push_back(att);
		}
		mapdata.push_back(ss);
	}
	return true;
}

size_t MapLoaderImpl::getNumSegments() const
{
	return mapdata.size();
}

bool MapLoaderImpl::getSegment(size_t segNum, StreetSegment &seg) const
{
	if (segNum < 0 || segNum >= getNumSegments())
	{
		return false;
	}
	else
	{
		seg = mapdata.at(segNum);
		return true;
	}
}

//******************** MapLoader functions ************************************

// These functions simply delegate to MapLoaderImpl's functions.
// You probably don't want to change any of this code.

MapLoader::MapLoader()
{
	m_impl = new MapLoaderImpl;
}

MapLoader::~MapLoader()
{
	delete m_impl;
}

bool MapLoader::load(string mapFile)
{
	return m_impl->load(mapFile);
}

size_t MapLoader::getNumSegments() const
{
	return m_impl->getNumSegments();
}

bool MapLoader::getSegment(size_t segNum, StreetSegment& seg) const
{
   return m_impl->getSegment(segNum, seg);
}
