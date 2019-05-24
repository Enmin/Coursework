// MyMap.h
#ifndef MYMAP_H
#define MYMAP_H
// Skeleton for the MyMap class template.  You must implement the first six
// member functions.
#include <iostream>
#include "support.h"
template<typename KeyType, typename ValueType>
class MyMap
{
public:
	MyMap()
	{
		root = nullptr;
		m_size = 0;
	}
	~MyMap() {}
	void clear()
	{
		if (root != nullptr)
			clear(root);
		root = nullptr;
		m_size = 0;
	}
	int size() const
	{
		return m_size;
	}

	void associate(const KeyType& key, const ValueType& value) 
	{
		ValueType* val = find(key);
		if (val != nullptr)
		{
			*val = value;
			return;
		}
		add(root,key,value);
		m_size++;
	}
	

	// for a map that can't be modified, return a pointer to const ValueType
	const ValueType* find(const KeyType& key) const
	{
		if (root == nullptr)
		{
			return nullptr;
		}
		return search(root, key);
	}

	// for a modifiable map, return a pointer to modifiable ValueType
	ValueType* find(const KeyType& key)
	{
		return const_cast<ValueType*>(const_cast<const MyMap*>(this)->find(key));
	}

	// C++11 syntax for preventing copying and assignment
	MyMap(const MyMap&) = delete;
	MyMap& operator=(const MyMap&) = delete;

private:
	struct Node
	{
		KeyType m_key;
		ValueType m_value;
		Node* left;
		Node* right;
	};
	Node* root;
	int m_size;
	void add(Node* &p, const KeyType& key, const ValueType& value)
	{
		if (p == nullptr)
		{
			p = new Node;
			p->m_key = key;
			p->m_value = value;
			p->left = nullptr;
			p->right = nullptr;
			return;
		}
		else if (key < p->m_key)
		{
			return add(p->left, key, value);
		}
		else
		{
			return add(p->right, key, value);
		}
	}
	const ValueType* search(Node* p, const KeyType& key) const
	{
		if (p == nullptr)
		{
			return nullptr;
		}
		if (p->m_key == key)
		{
			return &(p->m_value);
		}
		if (key < p->m_key)
		{
			return search(p->left, key);
		}
		else
		{
			return search(p->right, key);
		}
	}
	void clear(Node *p)
	{
		if (p != nullptr)
		{
			clear(p->left);
			clear(p->right);
			delete p;
			p = nullptr;
		}
		else
		{
			return;
		}
	}
};
#endif