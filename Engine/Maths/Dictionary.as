uint hash(string str, uint arrSize)
{
    uint64 hash = 5381;
    uint i = 0;
    for(uint i = 0; i < str.length(); ++i)
        hash = ((hash << 5) + hash) + str[i];
    return hash % arrSize;
}


class Data
{
    string key;
    any value; //xd
}

class Dictionary
{
    uint arraySize;
    uint elementsCount;
    Data[] arr;

    Dictionary()
    {
        elementsCount = 0;
        arraySize = 16;
        arr.resize(arraySize);
    }

    void _increaseArray()
    {
        Data temp;
        Data[] new_arr(arraySize*2);
        for(uint i = 0; i < arraySize; ++i)
        {
            temp = arr[i];
            if(!temp.key.isEmpty())
            {
                new_arr[hash(temp.key, arraySize*2)] = temp;
            }
        }
        arraySize *= 2;
        arr = new_arr;
    }

    bool get(const string &in idx, ComponentBodyPair@[] &out value) const
    {
        any output;
        if(get(idx, output))
        {
            if(output.retrieve(value))
            {
                return true;
            }
            else
            {
                error("Expected ComponentBodyPair@[] type for key " + idx);
                return false;
            }
        }else{
            return false;
        }
    }

    bool get(const string &in idx, int64 &out value) const
    {
        any output;
        if(get(idx, output))
        {
            if(output.retrieve(value))
            {
                return true;
            }
            else
            {
                error("Expected int64 type for key " + idx);
                return false;
            }
        }else{
            return false;
        }
    }

    bool get(const string &in idx, double &out value) const
    {
        any output;
        if(get(idx, output))
        {
            if(output.retrieve(value))
            {
                return true;
            }
            else
            {
                error("Expected double type for key " + idx);
                return false;
            }
        }else{
            return false;
        }
    }

    bool get(const string &in idx, bool &out value) const
    {
        any output;
        if(get(idx, output))
        {
            if(output.retrieve(value))
            {
                return true;
            }
            else
            {
                error("Expected bool type for key " + idx);
                return false;
            }
        }else{
            return false;
        }
    }

    any get_opIndex(string idx) const
    {
        any output;
        if(get(idx, output))
            return output;
        else
            return any(null);
    }

    bool get(const string &in idx, any &out value) const
    {
        uint i = hash(idx, arraySize);
        Data temp = arr[i];
        while(!temp.key.isEmpty())
        {
            if(temp.key == idx)
            {
                value = temp.value;
                return true;
            }
            if(++i == arraySize)
                i = 0;
            temp = arr[i];
        }
        return false;
    }

    void set(const string &in idx, ComponentBodyPair@[] &in value)
    {
        set(idx, any(value));
    }

    void set(const string &in idx, int64 &in value)
    {
        set(idx, any(value));
    }

    void set(const string &in idx, double &in value)
    {
        set(idx, any(value));
    }

    void set(const string &in idx, bool &in value)
    {
        set(idx, any(value));
    }

    void set_opIndex(string idx, any value) 
    {
        set(idx, value);
    }

    void set(const string &in idx, any &in value)
    {
        if(idx.isEmpty())
        {
            error("Can't access entry by empty string");
            return;
        }
        uint i = hash(idx, arraySize);
        Data temp = arr[i];
        while(!temp.key.isEmpty() && temp.key != idx)
        {
            if(++i == arraySize)
                i = 0;
            temp = arr[i];
        }
        arr[i].value = value;
        if(temp.key != idx)
        {
            arr[i].key = idx;
            if(++elementsCount >= arraySize/2)
            {
                _increaseArray();
            }
        }
    }

    bool exists(string idx)
    {
        uint i = hash(idx, arraySize);
        Data temp = arr[i];
        while(!temp.key.isEmpty())
        {
            if(temp.key == idx)
                return true;
            if(++i == arraySize)
                i = 0;
            temp = arr[i];
        }
        return false;
    }

    bool delete(string idx)
    {
        uint i = hash(idx, arraySize);
        Data temp = arr[i];
        while(!temp.key.isEmpty())
        {
            if(temp.key == idx)
            {
                _compress(i);
                return true;
            }
            if(++i == arraySize)
                i = 0;
            temp = arr[i];
        }
        return false;
    }

    void _compress(uint i)
    {
        Data temp;
        uint prevI;
        while(true) //xd
        {
            prevI = i;
            if(++i == arraySize)
                i = 0;
            temp = arr[i];
            if(temp.key.isEmpty() || hash(temp.key, arraySize) != hash(arr[prevI].key, arraySize))
                break;
            arr[prevI] = temp;
        }
        arr[prevI].key = "";
        --elementsCount;
    }

    array<string> @getKeys()
    {
        array<string> outArr = {};
        Data temp;
        for(uint i = 0; i < arraySize; ++i)
        {
            temp = arr[i];
            if(!temp.key.isEmpty())
            {
                outArr.insertLast(temp.key);
            }
        }
        return outArr;
    }

    uint getSize()
    {
        return elementsCount;
    }

    void deleteAll()
    {
        for(uint i = 0; i < arraySize; ++i)
        {
            if(!arr[i].key.isEmpty())
            {
                arr[i].key = "";
            }
        }
        elementsCount = 0;
    }

    bool isEmpty()
    {
        return elementsCount==0;
    }
}