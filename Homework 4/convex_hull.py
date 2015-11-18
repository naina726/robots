from Tkinter import *
import time
import math
import random
import matplotlib.pyplot as plt
import sys
#from scipy.spatial import ConvexHull

def reflection(scaleUnit, pointList):
	pointNum = len(pointList)
	resultList = []
	for i in range(pointNum):
		resultList.append(pointList[i])
		resultList.append((pointList[i][0], pointList[i][1]+scaleUnit))
		resultList.append((pointList[i][0]+scaleUnit, pointList[i][1]+scaleUnit))
		resultList.append((pointList[i][0]+scaleUnit, pointList[i][1]))
	return resultList



def findConvexHull(pointList):
	
	if len(pointList) < 3:
		return pointList
	bottomPointList = []
	minY = 2147483647
	for point in pointList:
		if point[1] < minY:
			minY = point[1]
	for point in pointList:
		if point[1] == minY:
			bottomPointList.append(point)
	maxX = -2147483647
	for point in bottomPointList:
		if point[0] > maxX:
			maxX = point[0]
	bottomRightPoint = None
	for point in bottomPointList:
		if point[0] == maxX:
			bottomRightPoint = point
			break

	angleTupleList = []
	for point in pointList:
		angle = math.atan2(point[1]-bottomRightPoint[1], point[0]-bottomRightPoint[0])
		angleTupleList.append((angle, point[0], point[1]))
	angleTupleList.sort()
	

	convexHullList = []
	pointNum  = len(angleTupleList)
	convexHullList.append(angleTupleList[pointNum-1])
	convexHullList.append(angleTupleList[0])
	i = 1
	while i < pointNum-1:
		currentPoint = angleTupleList[i]
		tailPoint = convexHullList[-1]
		last2Point = convexHullList[-2]
		#sum1 = q[0]*r[1] + p[0]*q[1] + r[0]*p[1]
		#sum2 = q[0]*p[1] + r[0]*q[1] + p[0]*r[1]
		sum1 = tailPoint[1] * currentPoint[2] + last2Point[1] * tailPoint[2] + currentPoint[1] * last2Point[2]
		sum2 = tailPoint[1] * last2Point[2] + currentPoint[1] * tailPoint[2] + last2Point[1] * currentPoint[2]
		# on the left
		if sum1 > sum2:
			convexHullList.append(currentPoint)
			i += 1
		else:
			convexHullList.pop()
	
	# resultPointList is a point List, [(x,y),...]
	# resultEdgeList is an edge List, [((x1,y1),(x2,y2)), ...]
	resultPointList = [(ele[1], ele[2]) for ele in convexHullList]
	resultEdgeList = []
	for i in range(len(resultPointList)-1):
		resultEdgeList.append(((resultPointList[i][0], resultPointList[i][1]),
			(resultPointList[i+1][0], resultPointList[i+1][1])))
	resultEdgeList.append(((resultPointList[-1][0], resultPointList[-1][1]),(resultPointList[0][0], resultPointList[0][1])))
	#return resultEdgeList
	return resultPointList



# testPoint = [(1.0, 1.0),
# 			(2.0, 2.5), 
# 			(1.5, 4),
# 			(0, 1.5)]
testPoint = [(3.694, 7.787 ),
(2.498, -2.306),
(2.238, -2.216 ),
(1.445, -2.217 ),
(1.428, -3.620 ),
(-3.690, -3.618 ),
(-3.686, 0.979 ),
(-3.240, 1.966 ),
(-2.620, 3.631 ),
(-1.891, 3.379 ),
(-1.141, 3.382 ),
(-1.139, 4.454 ),
(-0.914, 4.440 ),
(-0.916, 11.116 ),
(1.457, 11.109)]


# testPoint = [[3.694, 7.787 ],
# [2.498, -2.306],
# [2.238, -2.216 ],
# [1.445, -2.217 ],
# [1.428, -3.620 ],
# [-3.690, -3.618 ],
# [-3.686, 0.979 ],
# [-3.240, 1.966 ],
# [-2.620, 3.631 ],
# [-1.891, 3.379 ],
# [-1.141, 3.382 ],
# [-1.139, 4.454 ],
# [-0.914, 4.440 ],
# [-0.916, 11.116 ],
# [1.457, 11.109]]
# hull = ConvexHull(testPoint)
# print hull
# sys.exit()


#print findConvexHull(reflection(0.35, testPoint))

newPointList = reflection(0.35, testPoint)
convexHullList = findConvexHull(newPointList)
#print convexHullList
#sys.exit()
originalX = [ele[0] for ele in convexHullList]
originalY = [ele[1] for ele in convexHullList]

plt.plot(originalX, originalY, 'ro')

plt.show()


