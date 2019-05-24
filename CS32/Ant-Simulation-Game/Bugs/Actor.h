#ifndef ACTOR_H_
#define ACTOR_H_

#include "GraphObject.h"
#include "Compiler.h"
class StudentWorld;

// Students:  Add code to this file, Actor.cpp, StudentWorld.h, and StudentWorld.cpp
class Actor : public GraphObject
{
public:
	Actor(StudentWorld* s, int imageID, int x, int y, Direction dir, int depth) :
		GraphObject(imageID, x, y, dir, depth), m_dead(false), m_student(s), m_did(false) {}
	virtual ~Actor() {}
	virtual bool isDead()const { return m_dead; }
	virtual void setDead() { m_dead = true; }
	virtual bool doSomething() = 0;
	StudentWorld* getStudentWorld() { return m_student; }
	bool did() { return m_did; }
	void setdid() { m_did = (!m_did); }
private:
	bool m_dead;
	StudentWorld* m_student;
	bool m_did;
};
class Pebble :public Actor
{
public:
	Pebble(StudentWorld* s, int x, int y, int imageID = IID_ROCK, Direction dir=right, int depth = 1) :
		Actor(s,imageID, x, y,dir,depth) {}
	virtual ~Pebble() {}
	bool doSomething() { return false; }
};
class Water :public Actor
{
public:
	Water(StudentWorld* s, int x, int y) :Actor(s,IID_WATER_POOL, x, y, right,2) {}
	bool doSomething();
};
class Poison :public Actor
{
public:
	Poison(StudentWorld* s, int x, int y) :Actor(s, IID_POISON, x,y,right,2) {}
	bool doSomething();
};
class Energyholder:public Actor
{
public:
	Energyholder(StudentWorld*s, int imageID, int x, int y,int e) :Actor(s, imageID, x, y, right, 2),energy(e) {}
	virtual bool doSomething() = 0;
	int getEnergy() { return energy; }
	void setEnergy(int n) { energy += n; }
private:
	int energy;
};
class Anthill :public Energyholder
{
public:
	Anthill(StudentWorld* s, int x, int y, int m_colony, Compiler* program, std::string f ) :
		Energyholder(s, IID_ANT_HILL, x, y, 8999), colony(m_colony), bug(program) ,score(0),file(f)
	{
		std::string error;
		if (!bug->compile(file, error))
		{
			std::cout << "compile error" << std::endl;
			setDead();
		}
	}
	~Anthill()
	{
		delete bug;
		bug = nullptr;
	}
	bool doSomething();
	int getColony() const { return colony; }
	Compiler* getBug() { return bug; }
	void setScore(int n) { score += n; }
	int getScore() { return score; }
private:
	int colony;
	Compiler* bug;
	int score;
	std::string file;

};
class Pheromone :public Energyholder
{
public:
	Pheromone(StudentWorld* s, int x, int y, int imageID, int c) :Energyholder(s,imageID,x,y,256),colony(c) {}
	bool doSomething();
	void Increase();
	int getColony() { return colony; }
private:
	int colony;
};
class Food :public Energyholder
{
public:
	Food(StudentWorld* s, int x, int y, int food = 6000) :
		Energyholder(s,IID_FOOD, x, y,6000) {}
	virtual ~Food() {};
	bool doSomething() { return false; }
};
class Insect:public Actor
{
public:
	Insect(StudentWorld* s, int imageID, int x, int y, Direction dir, int hp,int depth=1):
		Actor(s, imageID,x,y,dir,depth),hitPoints(hp),stunState(false),sleepCount(0), bit(false) {}
	virtual bool doSomething() = 0;
	int getHp()const;
	void setHp(int n);
	void addFoodAfterDeath();
	void eat(Food* f);
	void setStuned(bool s) { stunState = s; }
	bool isStuned() { return stunState; }
	int getSleepCount()const;
	void setSleepCount(int n=0);
	void getBit() { bit = true; }
	void setBit() { bit = false; }
	bool isBit() { return bit; }
private:
	int hitPoints;
	bool stunState;
	int sleepCount;
	bool bit;
};
class Ant :public Insect
{
public:
	Ant(StudentWorld* s,Anthill* h,int imageID, int x, int y, int c) :
		Insect(s, imageID, x, y, static_cast<GraphObject::Direction>(randInt(up, left)),1500),
		colony(c),hold_food(0),counter(0),StunTick(0), last_random_num(0),hill(h) {}
	bool doSomething();
	int getStunTick() { return StunTick; }
	void setStunTick(int n);
	int getIdentity() { return colony; }
	bool Interpreter(Compiler* c, bool bitten, bool& moved);
	bool AntMove(Direction dir, int x, int y);
	void Dropfood();
	void doif(int operand1, int operand2, bool blocked, bool bitten);
private:
	int colony;
	int hold_food;
	int StunTick;
	int last_random_num;
	int counter;
	Anthill* hill;
};
class Grasshopper:public Insect
{
public:
	Grasshopper(StudentWorld* s, int x, int y, int imageID, int hp):
		Insect(s,imageID, x, y, static_cast<GraphObject::Direction>(randInt(up, left)),hp),m_distance(randInt(2, 10)) {}
	virtual ~Grasshopper() {}
	virtual bool doSomething() = 0;
	void walk() { if (m_distance > 0) { m_distance--; } }
	int getDistance() { return m_distance; }
	void setDistance(int d) { m_distance = d; }
	bool PrepMove();
	bool move();
private:
	int m_distance;
};
class AdultGrasshopper :public Grasshopper
{
public:
	AdultGrasshopper(StudentWorld* s, int x,int y,int hp=1600):
		Grasshopper(s,x,y, IID_ADULT_GRASSHOPPER,hp) {}
	virtual ~AdultGrasshopper() {}
	virtual bool doSomething();
	void bite();
	bool jump();
};
class babyGrasshopper : public Grasshopper
{
public:
	babyGrasshopper(StudentWorld* s, int x, int y, int hp=500):
		Grasshopper(s,x,y, IID_BABY_GRASSHOPPER, hp) {}
	virtual ~babyGrasshopper() {}
	virtual bool doSomething();
	void Transform();
};
#endif // ACTOR_H_
