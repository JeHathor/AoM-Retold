//==============================================================================
// aiMath.xs		by JeHathor (2025)
//==============================================================================
//Be aware that I might ignore historical parameter conventions here!

extern const float mPI = 3.1415926535;
extern const float mE  = 2.7182818284;

extern const vector mDegrees0 = vector(1.0, 0.0, 0.0);
extern const vector mDegrees45 = vector(0.707107, 0.0, 0.707107);
extern const vector mDegrees90 = vector(0.0, 0.0, 1.0);
extern const vector mDegrees135 = vector(-0.707107, 0.0, 0.707107);
extern const vector mDegrees180 = vector(-1.0, 0.0, 0.0);
extern const vector mDegrees225 = vector(-0.707107, 0.0, -0.707107);
extern const vector mDegrees270 = vector(0.0, 0.0, -1.0);
extern const vector mDegrees315 = vector(0.707107, 0.0, -0.707107);
extern const vector mDegrees360 = vector(1.0, 0.0, 0.0);

//=============================================================================
//   MathVectorSet
//=============================================================================
// Set the 3 components into a vector, returns the new vector.
vector MathVectorSet(float x=-1, float y=-1, float z=-1)
{
    return(vector(x, y, z));
}

//=============================================================================
//   MathVectorGetX
//=============================================================================
// Returns the x component of the given vector.
float MathVectorGetX(vector v=cInvalidVector)
{
    return(v.x);
}

//=============================================================================
//   MathVectorGetY
//=============================================================================
// Returns the Y component of the given vector.
float MathVectorGetY(vector v=cInvalidVector)
{
    return(v.y);
}

//=============================================================================
//   MathVectorGetZ
//=============================================================================
// Returns the Z component of the given vector.
float MathVectorGetZ(vector v=cInvalidVector)
{
    return(v.z);
}

//=============================================================================
//   MathVectorSetX
//=============================================================================
// Set the x component of the given vector, returns the new vector.
vector MathVectorSetX(vector v=cInvalidVector, float x=-1)
{
    v.x = x;
    return(v);
}

//=============================================================================
//   MathVectorSetY
//=============================================================================
// Set the y component of the given vector, returns the new vector.
vector MathVectorSetY(vector v=cInvalidVector, float y=-1)
{
    v.y = y;
    return(v);
}

//=============================================================================
//   MathVectorSetZ
//=============================================================================
// Set the z component of the given vector, returns the new vector.
vector MathVectorSetZ(vector v=cInvalidVector, float z=-1)
{
    v.z = z;
    return(v);
}

//=============================================================================
//   MathMinFloat
//=============================================================================
float MathMinFloat(float valueA=cMaxFloat, float valueB=cMaxFloat, float valueC=cMaxFloat)
{
    float minVal = valueA;
    if (valueB < minVal){minVal = valueB;}
    if (valueC < minVal){minVal = valueC;}    
    return(minVal);
}

//=============================================================================
//   MathMaxFloat
//=============================================================================
float MathMaxFloat(float valueA=cMinFloat, float valueB=cMinFloat, float valueC=cMinFloat)
{
    float maxVal = valueA;
    if (valueB > maxVal){maxVal = valueB;}
    if (valueC > maxVal){maxVal = valueC;}    
    return(maxVal);
}

//=============================================================================
//   MathPI
//=============================================================================
float MathPI(void)
{
    return(mPI);	//3.1415926535
}

//=============================================================================
//   MathAbsoluteValue
//=============================================================================
float MathAbsoluteValue(float n=0)
{
    if(n < 0)
    {
	return(n*(-1));
    }
    return(n);
}

//=============================================================================
//   MathSquare
//=============================================================================
float MathSquare(float n=0)
{
    return(n*n);
}

//=============================================================================
//   MathCube
//=============================================================================
float MathCube(float n=0)
{
    return(n*n*n);
}

//=============================================================================
//   MathSquareRoot
//=============================================================================
float MathSquareRoot(float n=0)
{
    float power = n;
    while(power > 0) {
	float result = n / power;
	if(result == power)
	{
		return(power);
	}else{
		float recent = power;
		power = (result + power) * 0.5;
		if(power == recent) {
			return(power);
		}
	}
    }
    return(n);
}

//=============================================================================
//   MathDegreeToRadians
//=============================================================================
float MathDegreeToRadians(float angle=360)
{
	/***************************
	*	180Deg = 1PI Rad
	*	PI / 180 = 1Deg
	***************************/

	return(angle * 0.0174532925);
}

//=============================================================================
//   MathFactorial
//=============================================================================
float MathFactorial(float n = 0)
{
	if(n < 0)
	{
	   return(n);
	}

	float temp = 1;
	for(i = 1; <= n) {
		temp = temp * i;
	}
	return (temp);
}

//==============================================================================
//   TimeMinToMS
//==============================================================================
float TimeMinToMS(float t = 0)
{
	return (t*60*1000);
}

//==============================================================================
//   TimeMStoMin
//==============================================================================
int TimeMStoMin(float t = 0)
{
    return (1 * (t / (60*1000)) );
}

//=============================================================================
//   MathExponentiate
//=============================================================================
float MathExponentiate(float n=0, int power=1)
{
	float temp = n;
	for(i = 1; < MathAbsoluteValue(power))
	{
		temp = temp * n;
	}
	if(power < 0) {
		temp = 1/temp;
	}
	return (temp);
}

//=============================================================================
//   MathGoldenRatio
//=============================================================================
float MathGoldenRatio(float n = 0)
{
	return ( n * ((MathSquareRoot(5)+1) /2) );
}

//=============================================================================
//   MathSinus
//=============================================================================
float MathSinus(float n = 0)
{
	float temp = n;
	for(i = 1; < 100)
	{
		int j = i * 2 + 1;
		float k = MathExponentiate(n,j) / MathFactorial(j);
		if(k == 0) break;
		if(i % 2 == 0) temp = temp + k;
		if(i % 2 == 1) temp = temp - k;
	}
	return (temp);
}

//=============================================================================
//   MathCosinus
//=============================================================================
float MathCosinus(float n = 0)
{
	float temp = 1;
	for(i = 1; < 100)
	{
		int j = i * 2;
		float k = MathExponentiate(n,j) / MathFactorial(j);
		if(k == 0) break;
		if(i % 2 == 0) temp = temp + k;
		if(i % 2 == 1) temp = temp - k;
	}
	return (temp);
}

//=============================================================================
//   MathArcTangens
//=============================================================================
float MathArcTangens(float n = 0)
{
    float temp = n;

    if(MathAbsoluteValue(n) > 1) {
	temp = 1.0 / n;
    }

    float rad = temp;

    for(i = 1; < 100) {
	int j = i * 2 + 1;
	float k = MathExponentiate(temp,j) / j;
	if(k == 0) {
	    break;
	}else
	if(i % 2 == 0) {
	    rad = rad + k;
	}else
	if(i % 2 == 1) {
	    rad = rad - k;
	}
    }

    if(n > 1 || n < -1) {
	rad = MathPI() / 2.0 - rad;
    }else
    if(n < -1) {
	rad = 0.0 - rad;
    }
    return (rad);
}

//=============================================================================
//   MathSigmoid (hyperbolic tangent)
//=============================================================================
float MathSigmoid(float n=0.0)
{
    //Limits: [-1, 1]
    return(2 / (1 + MathExponentiate(mE,0-n)) - 1);
}

//=============================================================================
//   MathArcTangensII
//=============================================================================
float MathArcTangensII(float x = 0, float z = 0)
{
    float PI = MathPI();

    if(x > 0) {
	return (MathArcTangens(z / x));
    }else if(x < 0) {
	if(z < 0) {
	    return (MathArcTangens(z / x) - PI);
	}else
	if(z > 0) {
	    return (MathArcTangens(z / x) + PI);
	}
	return (PI);
    }else
    if(z > 0) {
	return (PI / 2.0);
    }else
    if(z < 0) {
	return (0.0 - (PI / 2.0));
    }
    return (0);
}

//=============================================================================
//   MathEuclideanDistance
//=============================================================================
int MathEuclideanDistance(vector PointA=cOriginVector, vector PointB=cOriginVector)
{
	return(xsVectorLength(PointA-PointB));
}

//=============================================================================
//   MathPointAlongPath
//=============================================================================
vector MathPointAlongPath(vector PathStart=cOriginVector, vector PathEnd=cOriginVector, int radius=0)
{
	if(radius == 0)
	{
		return(PathStart);
	}
	vector extend = xsVectorNormalize(PathStart-PathEnd)*radius;
	return(PathStart+extend);
}

//=============================================================================
//   MathPointOnCircle
//=============================================================================
vector MathPointOnCircle(vector centerPoint=cOriginVector, float radius=30, float angle=360)
{
	angle = MathDegreeToRadians(angle);
	float x = MathVectorGetX(centerPoint) + radius * MathCosinus(angle);
	float y = MathVectorGetY(centerPoint);	//height
	float z = MathVectorGetZ(centerPoint) + radius * MathSinus(angle);
	return(MathVectorSet(x,y,z));
}

//=============================================================================
//   MathRandomPointOnCircle
//=============================================================================
vector MathRandomPointOnCircle(vector centerPoint=cOriginVector, float minRadius=10, float maxRadius=30)
{
	int radius = aiRandInt(maxRadius-minRadius)+minRadius;
	int angle = MathDegreeToRadians(aiRandInt(angle));
	float x = MathVectorGetX(centerPoint) + radius * MathCosinus(angle);
	float y = MathVectorGetY(centerPoint);	//height
	float z = MathVectorGetZ(centerPoint) + radius * MathSinus(angle);
	return(MathVectorSet(x,y,z));
}

//=============================================================================
//   MathDirectionalVectorSetAngle
//=============================================================================
vector MathDirectionalVectorSetAngle(vector DV=cOriginVector, float angle=360)
{
	int vectorLength = xsVectorLength(DV);
	float vx = vectorLength * MathCosinus(MathDegreeToRadians(angle));
	float vz = vectorLength * MathSinus(MathDegreeToRadians(angle));
	return(MathVectorSet(vx,MathVectorGetY(DV),vz));
}

//=============================================================================
//   MathDirectionalVectorGetAngle
//=============================================================================
float MathDirectionalVectorGetAngle(vector DV=cOriginVector)
{
	float vx = MathVectorGetX(DV);
	float vz = MathVectorGetZ(DV);
	float angle = MathRadiansToDegree(MathArcTangensII(vx,vz));
	return(angle);
}

//=============================================================================
//   MathDirectionalVectorRotate
//=============================================================================
vector MathDirectionalVectorRotate(vector DV=cOriginVector, float rotation=360)
{
	float base = MathDirectionalVectorGetAngle(DV);
	float angle = base + rotation;
	return(MathDirectionalVectorSetAngle(angle,DV));
}