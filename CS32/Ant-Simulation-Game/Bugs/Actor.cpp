#include "Actor.h"
#include "StudentWorld.h"
#include <cmath>

// Students:  Add code to this file (if you wish), Actor.h, StudentWorld.h, and StudentWorld.cpp

bool Anthill::doSomething()
{
	setEnergy(-1);
	if (getEnergy() <= 0)
	{
		setDead();
		return false;
	}
	Food* f = getStudentWorld()->IsthereFood(getX(),getY());
	if (f != nullptr)
	{
		if (f->getEnergy() > 10000)
		{
			f->setEnergy(-10000);
			setEnergy(10000);
		}
		else
		{
			int amt = f->getEnergy();
			f->setEnergy(-1 * amt);
			setEnergy(amt);
			f->setDead();
		}
		return false;
	}
	if (getEnergy()>=2000)
	{
		setEnergy(-1500);
		getStudentWorld()->addActor(new Ant(getStudentWorld(), this ,getColony(),getX(),getY(),getColony()),getX(),getY());
		score++;
	}
	return false;
}
bool Pheromone::doSomething()
{
	if (getEnergy() <= 0)
	{
		setDead();
	}
	else
	{
		setEnergy(-1);
	}
	return false;
}
void Pheromone::Increase()
{
	setEnergy(256);
	if (getEnergy() > 768)
	{
		setEnergy(768-getEnergy());
	}
}
bool Water::doSomething()
{
	getStudentWorld()->stunAllStunnableAt(getX(),getY());
	return false;
}
bool Poison::doSomething()
{
	getStudentWorld()->poisonAllPoisonableAt(getX(), getY());
	return false;
}
int Insect::getHp()const
{
	return hitPoints;
}
void Insect::setHp(int n)
{
	hitPoints += n;
}
void Insect::addFoodAfterDeath()
{
	Food* f = getStudentWorld()->IsthereFood(getX(), getY());
	if (f != nullptr)
	{
		f->setEnergy(100);
	}
	else
	{
		getStudentWorld()->addActor(new Food(getStudentWorld(), getX(), getY(),100), getX(), getY());
	}
}
void Insect::eat(Food* f)
{
	int amt = f->getEnergy();
	if (amt <= 0)
	{
		f->setDead();
		return;
	}
	if (amt > 200)
	{
		f->setEnergy(-200);
		setHp(200);
	}
	else
	{
		f->setEnergy(-1*amt);
		setHp(amt);
		f->setDead();
	}
}
int Insect::getSleepCount()const
{
	return sleepCount;
}
void Insect::setSleepCount(int n)
{
	//for increasing sleep ticks
	if (n != 0)
	{
		sleepCount += n;
		return;
	}
	// for normally counting sleep ticks
	if (sleepCount == 0)
	{
		sleepCount = 2;
		return;
	}
	sleepCount--;
}
bool Ant::doSomething()
{
	bool moved = false;
	setHp(-1);
	if (getHp() <= 0)
	{
		setDead();
		addFoodAfterDeath();		
		hill->setScore(-1);
		return moved;
	}
	if (getStunTick() != 0)
	{
		setStunTick(-1);
		return moved;
	}
	if (hill->getBug() == nullptr)
	{
		setDead();
		addFoodAfterDeath();
		return moved;
	}
	if (Interpreter(hill->getBug(), isBit(), moved)==false)
	{
		std::cerr << "Error";
	}
	if (moved == true)
	{
		setStuned(false);
	}
	return moved;
}
void Ant::setStunTick(int n)
{
	StunTick += n;
}
bool Ant::Interpreter(Compiler* c,bool bitten, bool& moved)
{
	bool blocked = false;
	Compiler::Command cmd;
	// start at the beginning of the vector
	for (int num=0;num<10;num++) // keep running forever for now
	{
		// get the command from element ic of the vector
		if (!c->getCommand(counter, cmd))
		{
			std::cerr << "Error compiler";
			return false; // error - no such instruction!
		}
		switch (cmd.opcode)
		{
		case Compiler::moveForward:
			{
				moved = AntMove(getDirection(), getX(), getY());
				if (moved == true)
				{
					bitten = false;
				}
				blocked = !moved;
				counter++;
				//std::cout << "mf wrong" << std::endl;
				return true;
			}
		case Compiler::generateRandomNumber:
			{
				int max = std::stoi(cmd.operand1);
				last_random_num = randInt(0, max - 1);
				counter++;
				//std::cout << "gr wrong" << std::endl;
				break;
			}
		case  Compiler::if_command:
			{
				int operand1 = std::stoi(cmd.operand1);
				int operand2 = std::stoi(cmd.operand2);
				doif(operand1, operand2, blocked, bitten);
				//std::cout << "if wrong" << std::endl;
				break;
			}
		case Compiler::goto_command:
			counter = std::stoi(cmd.operand1);
			//std::cout << "go wrong" << std::endl;
			break;
		case Compiler::eatFood:
			{
				if (hold_food >= 100)
				{
					hold_food -= 100;
					setHp(100);
				}
				else if (hold_food >= 0)
				{
					setHp(hold_food);
					hold_food = 0;
				}
				counter++;
				//std::cout << "ef wrong" << std::endl;
				return true;
			}
		case Compiler::pickupFood:
			{
				Food* f = getStudentWorld()->IsthereFood(getX(), getY());
				if (f != nullptr)
				{
					if (f->getEnergy() <= 0)
					{
						counter++;
						f->setDead();
						return false;
					}
					int res = 1800 - hold_food;
					int amt = f->getEnergy();
					int pick = (res > 400) ? 400 : res;
					if (pick >= amt)
					{
						f->setEnergy(-1 * amt);
						f->setDead();
						hold_food += amt;
					}
					else
					{
						f->setEnergy(-1 * pick);
						hold_food += pick;
					}
				}
				counter++;
				//std::cout << "pf wrong" << std::endl;
				return true;
			}
		case Compiler::faceRandomDirection:
			{
				Direction d = static_cast<GraphObject::Direction>(randInt(1, 4));
				setDirection(d);
				counter++;
				//std::cout << "frd wrong " << getIdentity() << std::endl;
				return true;
			}
		case Compiler::rotateClockwise:
			{
				Direction dir;
				switch (getDirection())
				{
				case up: dir = right; break;
				case right: dir = down; break;
				case down: dir = left; break;
				case left: dir = up; break;
				}
				setDirection(dir);
				counter++;
				//std::cout << "rc wrong" << std::endl;
				return true;
			}
		case Compiler::rotateCounterClockwise:
			{
				Direction cdir;
				switch (getDirection())
				{
				case up: cdir = left; break;
				case right: cdir = up; break;
				case down: cdir = right; break;
				case left: cdir = down; break;
				}
				setDirection(cdir);
				counter++;
				//std::cout << "rcc wrong" << std::endl;
				return true;
			}
		case Compiler::emitPheromone:
			{
				Pheromone* ph = getStudentWorld()->IsMyPheromone(getIdentity(), getX(), getY());
				if (ph != nullptr)
				{
					ph->Increase();
				}
				else
				{
					getStudentWorld()->addActor(new Pheromone(getStudentWorld(), getIdentity() + 10, getX(), getY(), getIdentity() + 10), getX(), getY());
				}
				counter++;
				//std::cout << "ep wrong" << std::endl;
				return true;
			}
		case Compiler::bite:
			{
				Insect* p = getStudentWorld()->IsEnenmyat(getIdentity(), getX(), getY());
				if (p != nullptr)
				{
					p->setHp(-15);
					p->getBit();
				}
				counter++;
				//std::cout << "bi wrong" << std::endl;
				return true;
			}
		case Compiler::dropFood:
			{
				Dropfood();
				counter++;
				//std::cout << "df wrong" << std::endl;
				return true;
			}
		}
		//std::cout << "other" << std::endl;
	}
	return true;
}
bool Ant::AntMove(Direction dir, int x, int y)
{
	switch (dir)
	{
	case GraphObject::up:
		if (getStudentWorld()->checkMove(this, getX(), getY(), getX(), getY()-1))
		{
			moveTo(x, y - 1);
			return true;
		}
		break;
	case GraphObject::left:
		if (getStudentWorld()->checkMove(this, getX(), getY(), getX() - 1, getY()))
		{
			moveTo(x - 1, y);
			return true;
		}
		break;
	case GraphObject::right:
		if (getStudentWorld()->checkMove(this, getX(), getY(), getX() + 1, getY()))
		{
			moveTo(x + 1, y);
			return true;
		}
		break;
	case GraphObject::down:
		if (getStudentWorld()->checkMove(this, getX(), getY(), getX(), getY()+1))
		{
			moveTo(x, y + 1);
			return true;
		}
		break;
	}
	return false;
}
void Ant::Dropfood()
{
	if (hold_food == 0)
	{
		return;
	}
	Food* f = getStudentWorld()->IsthereFood(getX(), getY());
	if (f != nullptr)
	{
		f->setEnergy(hold_food);
	}
	else
	{
		getStudentWorld()->addActor(new Food(getStudentWorld(), getX(), getY(), hold_food), getX(), getY());
	}
	hold_food = 0;
}
void Ant::doif(int operand1, int operand2,bool blocked, bool bitten)
{
	int i, j = 0;
	switch (getDirection())
	{
	case up: j = -1; break;
	case down: j = 1; break;
	case right: i = 1; break;
	case left: i = -1; break;
	}
	switch (operand1)
	{
	case 0:
		if (getStudentWorld()->IsDanger(getIdentity(), getX() + i, getY() + j))
		{
			counter = operand2;
		}
		else
		{
			counter++;
		}
		break;
	case 1:
		if (getStudentWorld()->IsMyPheromone(getIdentity(), getX()+i, getY()+j)!=nullptr)
		{
			counter = operand2;
		}
		else
		{
			counter++;
		}
		break;
	case 2:
		if (bitten)
		{
			counter = operand2;
		}
		else
		{
			counter++;
		}
		break;
	case 3:
		if (hold_food > 0)
		{
			counter = operand2;
		}
		else
		{
			counter++;
		}
		break;
	case 4:
		if (getHp()<=25)
		{
			counter = operand2;
		}
		else
		{
			counter++;
		}
		break;
	case 5:
		if (getStudentWorld()->IsMyhill(getIdentity(),getX(),getY()))
		{
			counter = operand2;
		}
		else
		{
			counter++;
		}
		break;
	case 6:
		{
			Food* f = getStudentWorld()->IsthereFood(getX(), getY());
			if (f != nullptr && f->getEnergy() >= 1)
			{
				counter = operand2;
			}
			else
			{
				counter++;
			}
			break;
		}
	case 7:
		{
			Insect* in = getStudentWorld()->IsEnenmyat(getIdentity(), getX(), getY());
			if (in != nullptr)
			{
				counter = operand2;
			}
			else
			{
				counter++;
			}
			break;
		}
	case 8:
		if (blocked)
		{
			counter = operand2;
		}
		else
		{
			counter++;
		}
		break;
	case 9:
		if (last_random_num == 0)
		{
			counter = operand2;
		}
		else
		{
			counter++;
		}
		break;
	}
}
bool Grasshopper::PrepMove()
{
	setHp(-1);
	if (getHp() <= 0)
	{
		addFoodAfterDeath();
		setDead();
		return false;
	}
	if (getSleepCount() != 0)
	{
		setSleepCount();
		return false;
	}
	return true;
}
bool Grasshopper::move()
{
	int x = getX(), y = getY();
	Direction dir = getDirection();
	switch (dir)
	{
	case right:
		if (getStudentWorld()->checkMove(this, getX(), getY(), getX() + 1, getY()))
		{
			moveTo(x + 1, y);
			walk();
		}
		else
		{
			setDistance(0);
		}
		break;
	case left:
		if (getStudentWorld()->checkMove(this, getX(), getY(), getX() - 1, getY()))
		{
			moveTo(x - 1, y);
			walk();
		}
		else
		{
			setDistance(0);
		}
		break;
	case up:
		if (getStudentWorld()->checkMove(this, getX(), getY(), getX(), getY() - 1))
		{
			moveTo(x, y - 1);
			walk();
		}
		else
		{
			setDistance(0);
		}
		break;
	case down:
		if (getStudentWorld()->checkMove(this, getX(), getY(), getX(), getY() + 1))
		{
			moveTo(x, y + 1);
			walk();
		}
		else
		{
			setDistance(0);
		}
		break;
	}
	if (getDistance() == 0)
	{
		setDirection(static_cast<GraphObject::Direction>(randInt(up, left)));
		setDistance(randInt(2, 10));
		return false;
	}
	return true;
}
bool babyGrasshopper::doSomething()
{
	bool moved = false;
	if (PrepMove() == false)
	{
		return false;
	}
	if (getHp() >= 1600)
	{
		Transform();
		return false;
	}
	Food* f = getStudentWorld()->IsthereFood(getX(), getY());
	if (f != nullptr)
	{
		eat(f);
		if (randInt(0, 99) >= 50)
		{
			setSleepCount();
			return moved;
		}
	}
	moved = move();
	if (moved == true)
	{
		setStuned(false);
	}
	setSleepCount();
	return moved;
}
void babyGrasshopper::Transform()
{
	setDead();
	addFoodAfterDeath();
	getStudentWorld()->addActor(new AdultGrasshopper(getStudentWorld(), getX(), getY()), getX(), getY());
}
bool AdultGrasshopper::doSomething()
{
	bool moved = false;
	if (PrepMove() == false)
	{
		return moved;
	}
	if (randInt(1, 99) <= 33)
	{
		bite();
		setSleepCount();
		return moved;
	}
	if (randInt(0, 99) < 10)
	{
		moved = jump();
		if (moved == true)
		{
			setStuned(false);
		}
		setSleepCount();
		return moved;
	}
	Food* f = getStudentWorld()->IsthereFood(getX(), getY());
	if (f != nullptr)
	{
		eat(f);
		if (randInt(0, 99) >= 50)
		{
			setSleepCount();
			return moved;
		}
	}
	moved = move();
	if (moved == true)
	{
		setStuned(false);
	}
	setSleepCount();
	return moved;
}
void AdultGrasshopper::bite()
{
	Insect* pi = getStudentWorld()->IsthereInsect(this, getX(), getY());
	if (pi != nullptr)
	{
		pi->setHp(-50);
		pi->getBit();
	}
}
bool AdultGrasshopper::jump()
{
	int angle = randInt(0, 360);
	int rad = randInt(1, 10);
	int x = getX() + rad * cos(angle);
	int y = getY() + rad * sin(angle);
	if (x > 63 || y > 63 || x < 0 || y < 0 )
	{
		return false;
}
	if (getStudentWorld()->checkMove(this, getX(), getY(), x, y) == true)
	{
		moveTo(x, y);
		return true;
	}
	return false;
}