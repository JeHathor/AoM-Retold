/**
 * Contains example functions for working with arrays.
 * 
 * @author JeHathor
 * @version (06.07.2025)
 */
static int[] testArray = default;

// Initialise an empty testArray, returns array size
int initEmpty()
{
    testArray = new int(0, -1);		// (SIZE, INITIAL_VALUE)
    return(testArray.size());
}

// Fill testArray with random integers in [0,999], returns array size
int initRandom(int size)
{
    testArray.resize(size, 0);
    for(int i = 0; i < size; i++)
    {
        testArray[i] = xsRandInt(0,999);
    }
    return(testArray.size());
}

// Fill testArray as sequence from MIN to MAX inclusive, returns array size
int initSequence(int min, int max)
{
    int arraySize = max - min + 1;
    testArray.resize(arraySize, 0);
    for(int i = 0; i < testArray.size(); i++)
    {
        testArray[i] = min + i;
    }
    return(testArray.size());
}

// Print array contents, returns count of elements printed
String printArrayToString()
{
    string msg = "";
    for(int i = 0; i < testArray.size(); i++)
    {
        msg += xsIntToString(testArray[i]) + ",";
    }
    return(msg);
}

// Appends a value to testArray and returns the new array length
int append(int value)
{
    testArray.add(value);
    return(testArray.size());
}

// Returns the value at the given index, or -1 if index is out-of-bounds
int getValueAtIndex(int index)
{
    if (index < 0 || index >= testArray.size())
        return(-1);
    return(testArray[index]);
}

// Removes the element at the given index and returns the new array length
int deleteIndex(int index)
{
    if (index < 0 || index >= testArray.size())
        return(testArray.size()); // Out of Bounds

    testArray.removeIndex(index);
    return(testArray.size());
}

// Removes all occurrences of value in testArray, returns new array length
int removeAllByValue(int value)
{
    int i = 0;
    while (i < testArray.size())
    {
        if (testArray[i] == value)
        {
            testArray.removeIndex(i);
            // do not increment i, array has shifted
        }else{
            i++;
        }
    }
    return(testArray.size());
}

// Swap elements at a and b, returns true on success, false on failure (invalid indices)
bool swap(int a, int b)
{
    if(a < 0 || b < 0 || a >= testArray.size() || b >= testArray.size())
        return(false);

    int temp = testArray[a];
    testArray[a] = testArray[b];
    testArray[b] = temp;
    return(true);
}

// Find index of minimum element from start, returns index or -1 if invalid start
int findMin(int start)
{
    if(start < 0 || start >= testArray.size())
        return(-1);

    int min = start;
    for(int i = start + 1; i < testArray.size(); i++)
    {
        if(testArray[i] < testArray[min])
        {
            min = i;
        }
    }
    return(min);
}

// Find index of maximum element from start, returns index or -1 if invalid start
int findMax(int start)
{
    if (start < 0 || start >= testArray.size())
        return(-1);

    int max = start;
    for (int i = start + 1; i < testArray.size(); i++)
    {
        if (testArray[i] > testArray[max])
        {
            max = i;
        }
    }
    return(max);
}

// Check if value exists in the array, returns true if found
bool valueExists(int value)
{
    for (int i = 0; i < testArray.size(); i++)
    {
        if (testArray[i] == value)
            return(true);
    }
    return(false);
}

// Check if sorted ascending (standard)
bool isSortedAscending()
{
    for(int i = 0; i < testArray.size() - 1; i++)
    {
        if(testArray[i] > testArray[i + 1])
            return(false);
    }
    return(true);
}

// Selection sort, returns true on completion
bool selectionSort()
{
    for(int q = 0; q < testArray.size(); q++)
    {
        int p = findMin(q);
        if(p == -1) return(false);
        swap(q, p);
    }
    return(isSortedAscending());
}

// Bubble sort, returns true on completion
bool bubbleSort()
{
    bool swapped;
    for(int i = 0; i < testArray.size(); i++)
    {
        swapped = false;
        for(int g = 0; g < testArray.size() - i - 1; g++)
        {
            if(testArray[g] > testArray[g + 1])
            {
                swap(g, g + 1);
                swapped = true;
            }
        }
        if(!swapped)
            break;
    }
    return(isSortedAscending());
}

// Insertion sort, returns true on completion
bool insertionSort()
{
    int j = 0;
    for (int i = 1; i < testArray.size(); i++)
    {
        j = i;
        while ((j >= 1) && (testArray[j - 1] > testArray[j]))
        {
            swap(j, j - 1);
            j--;
        }
    }
    return(isSortedAscending());
}
