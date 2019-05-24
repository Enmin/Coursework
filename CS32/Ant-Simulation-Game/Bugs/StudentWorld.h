#ifndef STUDENTWORLD_H_
#define STUDENTWORLD_H_

#include "GameWorld.h"
#include "GameConstants.h"
#include <sstream>
#include <iomanip>
#include <string>
#include <list>
#include "Actor.h"
#include "Field.h"

// Students:  Add code to this file, StudentWorld.cpp, Actor.h, and Actor.cpp

class StudentWorld : public GameWorld
{
public:
	StudentWorld(std::string assetDir)
	 : GameWorld(assetDir)
	{
	}

	virtual int init();

	virtual int move();
		  // This code is here merely to allow the game to build, run, and terminate after you hit enter.
		  // Notice that the return value GWSTATUS_NO_WINNER will cause our framework to end the simulation.

	virtual void cleanUp();
	
	void updateTickCount();
	bool checkMove(Actor* q,int oldX,int oldY, int newX, int newY);
	void updateDisplayText();
	bool block(int x, int y);
	void resetDid();
	void removeDead();
	Food* IsthereFood(int x, int y);
	Insect* IsthereInsect(Insect* in,int x, int y);
	void addActor(Actor* ac,int x, int y);
	bool poisonAllPoisonableAt(int x, int y);
	bool stunAllStunnableAt(int x, int y);
	Insect* IsEnenmyat(int colony, int x, int y);
	Pheromone* IsMyPheromone(int colony, int x, int y);
	bool IsDanger(int colony, int x, int y);
	bool IsMyhill(int colony, int x, int y);
	bool isEdible(int x, int y);

private:
	std::vector<Actor*> slot[VIEW_HEIGHT][VIEW_WIDTH];
	int m_tick;
	Anthill* hill[4];
	std::vector<std::string> fileNames;
};

#endif // STUDENTWORLD_H_
