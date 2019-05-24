#include "StudentWorld.h"
#include <string>
using namespace std;

GameWorld* createStudentWorld(string assetDir)
{
	return new StudentWorld(assetDir);
}

// Students:  Add code to this file (if you wish), StudentWorld.h, Actor.h and Actor.cpp
int StudentWorld::init()
{
	fileNames = getFilenamesOfAntPrograms();
	if (fileNames.size() == 0)
	{
		cout << "Error" << endl;
		return GWSTATUS_LEVEL_ERROR;
	}
	m_tick = 0;
	Field f;
	std::string fieldFile = getFieldFilename();
	std::string error;
	if (f.loadField(fieldFile, error) != Field::LoadResult::load_success)
	{
		setError(fieldFile + " " + error);
		return GWSTATUS_LEVEL_ERROR; // something bad happened!
	}
	for (int x = 0; x < VIEW_WIDTH; x++)
	{
		for (int y = 0; y < VIEW_HEIGHT; y++)
		{
			switch (f.getContentsOf(x, y))
			{
			case Field::FieldItem::anthill0:
				{
					Compiler* c0 = new Compiler;
					if (fileNames.size() <= IID_ANT_TYPE0 + 1) { return GWSTATUS_LEVEL_ERROR; }
					hill[0] = new Anthill(this, x, y, IID_ANT_TYPE0, c0,fileNames[IID_ANT_TYPE0]);
					slot[y][x].push_back(hill[0]);
				}
				break;
			case Field::FieldItem::anthill1:
				{
					Compiler* c1 = new Compiler;
					if (fileNames.size() <= IID_ANT_TYPE1 + 1) { return GWSTATUS_LEVEL_ERROR; }
					hill[1] = new Anthill(this, x, y, IID_ANT_TYPE1, c1, fileNames[IID_ANT_TYPE1]);
					slot[y][x].push_back(hill[1]);
				}
				break;
			case Field::FieldItem::anthill2:
				{
					Compiler* c2 = new Compiler;
					if (fileNames.size() <= IID_ANT_TYPE2 + 1) { return GWSTATUS_LEVEL_ERROR; }
					hill[2] = new Anthill(this, x, y, IID_ANT_TYPE2, c2, fileNames[IID_ANT_TYPE2]);
					slot[y][x].push_back(hill[2]);
				}
				break;
			case Field::FieldItem::anthill3:
				{
					Compiler* c3 = new Compiler;
					if (fileNames.size() <= IID_ANT_TYPE3 + 1) { return GWSTATUS_LEVEL_ERROR; }
					hill[3] = new Anthill(this, x, y, IID_ANT_TYPE3, c3, fileNames[IID_ANT_TYPE3]);
					slot[y][x].push_back(hill[3]);
				}
				break;
			case Field::FieldItem::water:
				slot[y][x].push_back(new Water(this, x, y));
				break;
			case Field::FieldItem::poison:
				slot[y][x].push_back(new Poison(this, x, y));
				break;
			case Field::FieldItem::food:
				slot[y][x].push_back(new Food(this, x, y));
				break;
			case Field::FieldItem::rock:
				slot[y][x].push_back(new Pebble(this, x, y));
				break;
			case Field::FieldItem::grasshopper:
				slot[y][x].push_back(new babyGrasshopper(this, x, y));
				break;
			default:
				break;
			}
		}
	}
	return GWSTATUS_CONTINUE_GAME;
}
void StudentWorld::resetDid()
{
	for (int x = 0; x < VIEW_WIDTH; x++)
	{
		for (int y = 0; y < VIEW_HEIGHT; y++)
		{
			for (unsigned int i = 0; i < slot[y][x].size();i++)
			{
				Actor* ac= dynamic_cast<Actor*>(slot[y][x].at(i));
				Insect* in= dynamic_cast<Insect*>(ac);
				if (ac->did() == true)
				{
					ac->setdid();
				}
				if (in != nullptr)
				{
					in->setBit();
				}
			}
		}
	}
}
int StudentWorld::move()
{
	updateTickCount();
	for (int x = 0; x < VIEW_WIDTH; x++)
	{
		for (int y = 0; y < VIEW_HEIGHT; y++)
		{
			for (unsigned int i = 0; i < slot[y][x].size();)
			{
				Actor* ac = dynamic_cast<Actor*>(slot[y][x].at(i));
				// get the actor’s current locatio
				if (ac != nullptr)
				{
					if (!ac->isDead())
					{
						// ask each actor to do something (e.g. move)
						if (ac->did() == false)
						{
							if (!ac->doSomething())
							{
								i++;
							}
						}
						ac->setdid();
					}
				}
			}
		}
	}
	resetDid();
	// Remove newly-dead actors after each tick
	removeDead(); // delete dead simulation objects
	// Update the simulation Status Line
	updateDisplayText(); // update the ticks/ant stats text at screen top
						 // If the simulation’s over (ticks == 2000) then see if we have a winner
	if (m_tick == 2000)
	{
		int max = 0;
		for (int i = 1; i < 4; i++)
		{
			if (hill[i]->getScore()>hill[max]->getScore())
			{
				max = i;
			}
		}
		if (hill[max]->getScore() >= 5)
		{
			setWinner(hill[max]->getBug()->getColonyName());
			return GWSTATUS_PLAYER_WON;
		}
		else
		{
			return GWSTATUS_NO_WINNER;
		}
	}
	else
	{
		return GWSTATUS_CONTINUE_GAME;
	}
}
void StudentWorld::updateTickCount()
{
	m_tick++;
}
bool StudentWorld::checkMove(Actor* q, int oldX, int oldY,int newX, int newY)
{
	if (!block(newX, newY))
	{
		for (unsigned int i = 0; i < slot[oldY][oldX].size(); i++)
		{
			if (q == dynamic_cast<Actor*>(slot[oldY][oldX].at(i)))
			{
				std::vector<Actor*>::iterator it = slot[oldY][oldX].begin();
				it += i;
				slot[oldY][oldX].erase(it);
				break;
			}
		}
		slot[newY][newX].push_back(q);
		return true;
	}
	return false;
}
void StudentWorld::updateDisplayText()
{
	string name[4];
	int score[4];
	for (int i = 0; i < 4; i++)
	{
		if (hill[i] != nullptr)
		{
			name[i] = hill[i]->getBug()->getColonyName();
			score[i] = hill[i]->getScore();
		}
	}
	std::ostringstream oss;
	oss << "Ticks:" ;
	int k = 2000 - m_tick;
	oss << setw(5) << k << " - ";
	for (int i = 0; i < 4; i++)
	{
		if (hill[i] != nullptr)
		{
			oss << name[i] << ": ";
			oss.fill('0');
			oss << setw(2) << score[i];
			oss << "  ";
		}
	}
	oss << endl;
	setGameStatText(oss.str());
}
bool StudentWorld::block(int x,int y)
{
	for (unsigned int k = 0; k < slot[y][x].size();k++)
	{
		Pebble* pp = dynamic_cast<Pebble*>(slot[y][x].at(k));
		if (pp != nullptr)
		{
			return true;
		}
	}
	return false;
}
void StudentWorld::removeDead()
{
	for (int x = 0; x < VIEW_WIDTH; x++)
	{
		for (int y = 0; y < VIEW_HEIGHT; y++)
		{
			for (std::vector<Actor*>::iterator it = slot[y][x].begin(); it != slot[y][x].end();)
			{
				if ((*it)->isDead())
				{
					//Actor* kill = *it;
					it = slot[y][x].erase(it);
					/*for (int i = 0; i < 4; i++)
					{
						if (hill[i] == kill)
						{
							hill[i] = nullptr;
							break;
						}
					}
					delete kill;
					kill = nullptr;*/
				}
				else
				{
					it++;
				}
			}
		}
	}
}
void StudentWorld::cleanUp()
{
	for (int x = 0; x < VIEW_WIDTH; x++)
	{
		for (int y = 0; y < VIEW_HEIGHT; y++)
		{
			for (std::vector<Actor*>::iterator it = slot[y][x].begin(); it != slot[y][x].end();)
			{
				Actor* ac = *it;
				it = slot[y][x].erase(it);
				delete ac;
			}
		}
	}
}
Food* StudentWorld::IsthereFood(int x, int y)
{
	for (unsigned int i = 0; i < slot[y][x].size(); i++)
	{
		Food* f = dynamic_cast<Food*>(slot[y][x].at(i));
		if (f != nullptr && isEdible(x,y))
		{
			return f;
		}
	}
	return nullptr;
}
Insect* StudentWorld::IsthereInsect(Insect* in,int x, int y)
{
	for (unsigned int i = 0; i < slot[y][x].size(); i++)
	{
		Insect* insect = dynamic_cast<Insect*>(slot[y][x].at(i));
		if (insect != nullptr && insect!=in)
		{
			return insect;
		}
	}
	return nullptr;
}
void StudentWorld::addActor(Actor* ac, int x, int y)
{
	slot[y][x].push_back(ac);
}
bool StudentWorld::poisonAllPoisonableAt(int x, int y)
{
	bool poisoned = false;
	for (unsigned int i = 0; i < slot[y][x].size(); i++)
	{
		Ant* an = dynamic_cast<Ant*>(slot[y][x].at(i));
		babyGrasshopper* bg = dynamic_cast<babyGrasshopper*>(slot[y][x].at(i));
		if (an != nullptr)
		{
			an->setHp(-150);//会不会没毒到？push_back?
			poisoned = true;
		}
		if(bg!=nullptr)
		{
			bg->setHp(-150);
			poisoned = true;
		}
	}
	return poisoned;
}
bool StudentWorld::stunAllStunnableAt(int x, int y)
{
	bool stunsth = false;
	for (unsigned int i = 0; i < slot[y][x].size(); i++)
	{
		Ant* an = dynamic_cast<Ant*>(slot[y][x].at(i));
		babyGrasshopper* bg = dynamic_cast<babyGrasshopper*>(slot[y][x].at(i));
		if (an != nullptr)
		{
			if (an->isStuned() == false)
			{
				an->setStuned(true);
				an->setStunTick(2);
				stunsth = true;
			}
		}
		if (bg != nullptr)
		{
			if (bg->isStuned() == false)
			{
				bg->setStuned(true);
				bg->setSleepCount(2);
				stunsth = true;
			}
		}
	}
	return stunsth;
}
Insect* StudentWorld::IsEnenmyat(int colony, int x, int y)
{
	for (unsigned int i = 0; i < slot[y][x].size(); i++)
	{
		Ant* an = dynamic_cast<Ant*>(slot[y][x].at(i));
		Grasshopper* gh = dynamic_cast<Grasshopper*>(slot[y][x].at(i));
		if (an != nullptr && an->getIdentity()!=colony)
		{
			return an;
		}
		if (gh != nullptr)
		{
			return gh;
		}
	}
	return nullptr;
}
Pheromone* StudentWorld::IsMyPheromone(int colony, int x, int y)
{
	for (unsigned int i = 0; i < slot[y][x].size(); i++)
	{
		Pheromone* ph = dynamic_cast<Pheromone*>(slot[y][x].at(i));
		if (ph != nullptr && colony==ph->getColony()-10)
		{
			return ph;
		}
	}
	return nullptr;
}
bool StudentWorld::IsDanger(int colony, int x, int y)
{
	for (unsigned int i = 0; i < slot[y][x].size(); i++)
	{
		Grasshopper* gh = dynamic_cast<Grasshopper*>(slot[y][x].at(i));
		Ant* an = dynamic_cast<Ant*>(slot[y][x].at(i));
		Poison* po = dynamic_cast<Poison*>(slot[y][x].at(i));
		Water* wa = dynamic_cast<Water*>(slot[y][x].at(i));
		if (gh != nullptr || po != nullptr || wa != nullptr || (an != nullptr && an->getIdentity() != colony))
		{
			return true;
		}
	}
	return false;
}
bool StudentWorld::IsMyhill(int colony, int x, int y)
{
	for (unsigned int i = 0; i < slot[y][x].size(); i++)
	{
		Anthill* hill = dynamic_cast<Anthill*>(slot[y][x].at(i));
		if (hill != nullptr && hill->getColony() == colony)
		{
			return true;
		}
	}
	return false;
}
bool StudentWorld::isEdible(int x, int y)
{
	for (unsigned int i = 0; i < slot[y][x].size(); i++)
	{
		Anthill* h = dynamic_cast<Anthill*>(slot[y][x].at(i));
		if (h != nullptr)
		{
			return false;
		}
	}
	return true;
}