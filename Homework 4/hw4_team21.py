##########################################################
# COMS W4733 Computational Aspects of Robotics 2015
#
# Homework 4
#
# Team number: 21
# Team leader: Yiqing Cui(yc3121)
# Team members: Jasleen Nuno (jn2465)  Naina Prasad (np2302)
# Usage: Set the input obstacle file and input start_and_goal_point file name
# in variable obstaclesFile and startGoalFile. Then type python hw4_team21.py
# 
##########################################################
 


from Tkinter import *
import time
import math
import random
import matplotlib.pyplot as plt
import sys
import Queue

# Warning!!!!!!------------user should specify these two files----------------
startGoalFile = 'testStartGoal.txt'
obstaclesFile = 'testObstacles.txt'





outputObjectFile = 'obj.txt'
outputDistanceFile = 'dis.txt'
inputObsFile = 'obj.txt'
inputDistFile = 'dis.txt'
outputFile = 'sp.txt'
startPointName = '0'
goalPointName = '1'
generatedVisibleLineFile = 'vl.txt' 
grownObstaclesFile = 'go.txt'
reflectionScale = 0.35



# Load info of obstacles, start point and goal point from original file.
# The filename are specified in variable obstaclesFile and startGoalFile.
def readOriginalFile(startGoalFile, obstaclesFile):
    lines = open(startGoalFile).read().split('\n')
    startX = round(float(lines[0].split()[0]), 6)
    startY = round(float(lines[0].split()[1]), 6)
    goalX = round(float(lines[1].split()[0]), 6)
    goalY = round(float(lines[1].split()[1]), 6)
    lines = open(obstaclesFile).read().split('\n')
    lineNum = len(lines)
    obstaclesNum = int(lines[0])
    obstaclesList = []
    currentLineNum = 1
    while 1:
        if currentLineNum >= lineNum:
            break
        if lines[currentLineNum] == '\n' or lines[currentLineNum] == '' or lines[currentLineNum] == '\r':
            break
        if not ' ' in lines[currentLineNum]:
            obstacleEdgesNum = int(lines[currentLineNum])
            currentObstacle = []
            for i in range(obstacleEdgesNum):
                X = round(float(lines[currentLineNum+i+1].split()[0]), 6)
                Y = round(float(lines[currentLineNum+i+1].split()[1]), 6)
                currentObstacle.append((X,Y))
            obstaclesList.append(currentObstacle)
            currentLineNum += obstacleEdgesNum + 1
    return (startX,startY), (goalX, goalY), obstaclesList

# Reflect to get the new size of each obstacle
def reflection(scaleUnit, pointList):
    pointNum = len(pointList)
    resultList = []
    for i in range(pointNum):
        resultList.append(pointList[i])
        resultList.append((pointList[i][0], round(pointList[i][1]+scaleUnit,6)))
        resultList.append((round(pointList[i][0]+scaleUnit,6), round(pointList[i][1]+scaleUnit,6)))
        resultList.append((round(pointList[i][0]+scaleUnit,6), pointList[i][1]))
    return resultList


# Point List is like [(x1,y1), (x2,y2)...]
# Find conves hull of input points list
def findConvexHull(pointList):
    #print pointList

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
    #print maxX, minY
    angleTupleList = []
    for point in pointList:
        angle = math.atan2(point[1]-bottomRightPoint[1], point[0]-bottomRightPoint[0])
        angleTupleList.append((angle, point[0], point[1]))
    angleTupleList = list(set(angleTupleList))
    angleTupleList.sort()
    #angleTupleList


    convexHullList = []
    pointNum  = len(angleTupleList)
    convexHullList.append(angleTupleList[pointNum-1])
    convexHullList.append(angleTupleList[0])
    i = 1
    #print len(convexHullList)
    while i < pointNum-1:
        #print len(convexHullList)

        currentPoint = angleTupleList[i]
        tailPoint = convexHullList[-1]
        last2Point = convexHullList[-2]
        #print tailPoint
        #print last2Point
        #print currentPoint
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
            #print convexHullList

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

# Test whether a point is inside any obstacle. False means inside.
def judgePointInside(obstacleList, point):
    #print len(obstacleList)
    for obstacle in obstacleList:
        convexHullList = findConvexHull(obstacle + [point])
        if not point in convexHullList:
            return False
    return True



# Generate every possible visible lines
def generate_visible_lines(walls, list_of_obs, start_point, end_point):
    # walls is list of tuples of points
    # list_of_obs is list of lists
    #     each sublist is composed of tuples of points
    list_of_obs.append(walls)
    visible_lines = []
    obstacles_num = len(list_of_obs)
    for i in range(obstacles_num-1):
        for j in range(i+1, obstacles_num):
            firstObstacle = list_of_obs[i]
            secondObstacle = list_of_obs[j]
            for p1 in range(len(firstObstacle)):
                for p2 in range(len(secondObstacle)):
                    if judgePointInside(list_of_obs[:-1], firstObstacle[p1]) and judgePointInside(list_of_obs[:-1], secondObstacle[p2]):
                        visible_lines.append((firstObstacle[p1][0], firstObstacle[p1][1], secondObstacle[p2][0], secondObstacle[p2][1]))
    
    for i in range(obstacles_num):
    	for eachPoint in list_of_obs[i]:
    		visible_lines.append((eachPoint[0], eachPoint[1], start_point[0], start_point[1]))
    		visible_lines.append((eachPoint[0], eachPoint[1], end_point[0], end_point[1]))

    return visible_lines


# Helper function for detect line segment intersection
def ccw(x1,y1,x2,y2,x3,y3):
    return (y3-y1)*(x2-x1) > (y2-y1)*(x3-x1)

# Test whether two line segments are intersected
def isIntersected(firstEdge, secondEdge):
	x1 = firstEdge[0]
	y1 = firstEdge[1]
	x2 = firstEdge[2]
	y2 = firstEdge[3]
	x3 = secondEdge[0]
	y3 = secondEdge[1]
	x4 = secondEdge[2]
	y4 = secondEdge[3]
	if x1 == x3 and y1 == y3:
		return False
	if x1 == x4 and y1 == y4:
		return False
	if x2 == x3 and y2 == y3:
		return False
	if x2 == x4 and y2 == y4:
		return False
	return ccw(x1,y1,x3,y3,x4,y4) != ccw(x2,y2,x3,y3,x4,y4) and ccw(x1,y1,x2,y2,x3,y3) != ccw(x1,y1,x2,y2,x4,y4)

# Cross out illegal visible lines(intersect with some edges of an obstacle)
def chooseLegalLines(walls, list_of_obs, generatedLines):
	list_of_obs.append(walls)
	obstacleEdgeLineList = []
	for eachObstacles in list_of_obs:
		pointNum = len(eachObstacles)
		for i in range(pointNum):
			edgeLine = (eachObstacles[i%pointNum][0], eachObstacles[i%pointNum][1],eachObstacles[(i+1)%pointNum][0], eachObstacles[(i+1)%pointNum][1])
			obstacleEdgeLineList.append(edgeLine)
	legalVisibleLines = []
	for eachLine in generatedLines:
		legal = True
		for eachEdge in obstacleEdgeLineList:
			if isIntersected(eachLine, eachEdge):
				# print eachLine, eachEdge
				legal = False
				break
		if legal == True:
			legalVisibleLines.append(eachLine)
	return legalVisibleLines

    
            
# Draw function
def plot_obstacle(w,start_point, end_point, *infiles):
    

    w.create_oval((400+start_point[0]*40)-5,(150+start_point[1]*40)+5,(400+start_point[0]*40)+5,(150+start_point[1]*40)-5,width=1,fill='green')
    w.create_oval((400+end_point[0]*40)-5,(150+end_point[1]*40)+5,(400+end_point[0]*40)+5,(150+end_point[1]*40)-5,width=1,fill='red')
    Ob = True
    wid = 2
    for filename in infiles:
        infile = open(filename, 'r')
        num_ob = infile.readline()
        num_ob = num_ob.split()
        # for files with obstacles
        if len(num_ob) == 1:
            num_ob = int(num_ob[0])
            for i in range(num_ob):
                points = []
                num_edges = int(infile.readline())
                for j in range(num_edges):
                    point = infile.readline()
                    point = point.split()
                    point[0] =  400 + float(point[0])*40
                    point[1] = 150 + float(point[1])*40
                    points.append(point)
                if Ob == True:
                    color = 'black'
                    Ob = False
                else:
                    color = 'brown1'
                for j in range(len(points)-1):
                    w.create_line(points[j][0], points[j][1], points[j+1][0], points[j+1][1], width = wid,fill=color)
                w.create_line(points[-1][0],points[-1][1], points[0][0],points[0][1], width = wid,fill=color)
            infile.close()
            time.sleep(2)
            # wid = wid+  2
        # for files with lines formatted x1 y1 x2 y2
        elif len(num_ob) == 4 :
            while(len(num_ob) >0):
                for i in range(len(num_ob)):
                    if i % 2 == 0:
                        num_ob[i] = 400 + float(num_ob[i])*40
                    else:
                        num_ob[i] = 150 + float(num_ob[i])*40
                w.create_line(num_ob[0], num_ob[1], num_ob[2], num_ob[3], width=wid, fill='blue')
                num_ob = infile.readline()
                num_ob = num_ob.split()
            wid =  wid + 2
            time.sleep(2)
        # for files with lines formatted x1 y1            
        else:
            points = []
            while(len(num_ob)>0):
                num_ob[0] = 400 + float(num_ob[0])*40
                num_ob[1] = 150 + float(num_ob[1])*40
                points.append((num_ob[0],num_ob[1]))
                num_ob = infile.readline()
                num_ob = num_ob.split()
            for i in range(len(points)-1):
                w.create_line(points[i][0], points[i][1], points[i+1][0], points[i+1][1], width=wid, fill='green')
            wid = wid + 2
            #w.create_oval(points[0][0]-5,points[0][1]+5,points[0][0]+5,points[0][1]-5,width=1,fill='green')
            #w.create_oval(points[-1][0]-5,points[-1][1]+5,points[-1][0]+5,points[-1][1]-5,width=1,fill='red')
            time.sleep(2)
    #mainloop()
    #return


# Dijkstra's Algorithm part 
def second_part(objects_file, lines_file, source, destination):
            
    obj = open(objects_file,'r')
    cities = {}
    
    for line in obj:
        line = line.split()
        cities[line[0]] = Vertex(line[0],400+float(line[1])*40,150+float(line[2])*40)
    obj.close()
    
    connCities = open(lines_file, 'r')
    for line in connCities:
        line = line.split()
        city1 = line[0]
        city2 = line[1]
        cost = float(line[2])
        cities[city1].addAdj(cities[city2],cost)
        #cities[city1].addDist(cost)
        cities[city2].addAdj(cities[city1],cost)
        #cities[city2].addDist(cost)
        
    connCities.close()
    
    di = Dijkstras(cities, source, destination)
    di.dijkstras()
    open_file = open(outputFile,'w')
    di.writePath(open_file,cities[destination])
    
class Vertex():
    def __init__(self, name, xcoord, ycoord):
        self.city = name
        self.x = xcoord
        self.y = ycoord
        self.adj = []
        self.distances = []
        self.dist = 0
        self.path = None
    def addAdj(self, v, distance):
        self.adj.append(v)
        self.distances.append(distance)
    def getName():
        return city

class Dijkstras():
    def __init__(self, cities, source, destination):
        self.cities = cities
        self.sourceName = source
        self.destinName = destination
        self.source = cities[source]
        self.destination =  cities[destination]
    def getSource(self):
        return self.source
    def getDestination(self):
        return self.destination
    def dijkstras(self):
        q = Queue.PriorityQueue()
        for v in self.cities.values():
            v.dist = float('inf')
        self.source.dist = 0
        q.put(self.source)
        while q.qsize() > 0:
            v = q.get()
            for i in range(len(v.adj)):
                if v.adj[i].dist == float('inf'):
                    v.adj[i].dist = v.dist + v.distances[i]
                    v.adj[i].path = v;
                    q.put(v.adj[i])

    def writePath(self,path_file, v):
        if(v.path!=None):
            self.writePath(path_file, v.path)
            path_file.write("\n")
        path_file.write(str((v.x-400)/40))
        path_file.write(" ")
        path_file.write(str((v.y-150)/40))
    
# Write info of grown obstacles into file           
def generateGrownObstaclesFile(wall, grownObstaclesFile, list_of_ob):
    list_of_obs = [wall] + list_of_ob
    filehandler = open(grownObstaclesFile, 'w')
    obsNum = len(list_of_obs)
    filehandler.write(str(obsNum)+'\n')
    for eachObstacles in list_of_obs:
        edgeNum = len(eachObstacles)
        filehandler.write(str(edgeNum)+'\n')
        for i in range(edgeNum):
            filehandler.write('%s %s\n' % (eachObstacles[i][0], eachObstacles[i][1]))
    filehandler.close()

# Write info of legal visible lines into file
def generateVisibleLinesFile(generatedVisibleLineFile, legalLinesList):
    filehandler = open(generatedVisibleLineFile, 'w')
    linesNum = len(legalLinesList)
    for i in range(linesNum):
        filehandler.write('%s %s %s %s\n' % (legalLinesList[i][0], legalLinesList[i][1], legalLinesList[i][2], legalLinesList[i][3]))
    filehandler.close()


# Calculate the distance between points
def calcDist(pointA, pointB):
    squareSum = ((pointA[0]-pointB[0]) ** 2) + ((pointA[1]-pointB[1]) ** 2)
    return round(math.sqrt(squareSum), 6)




if __name__ == "__main__":
    start_point, goal_point, obstaclesList = readOriginalFile(startGoalFile, obstaclesFile)
    wall = obstaclesList[0]
    list_of_obs = [findConvexHull(reflection(reflectionScale, pointList)) for pointList in obstaclesList[1:]]
    generateGrownObstaclesFile(wall, grownObstaclesFile, list_of_obs)

    generatedLines = generate_visible_lines(wall, list_of_obs, start_point, goal_point)
    legalLines = chooseLegalLines(wall, list_of_obs, generatedLines)
    generateVisibleLinesFile(generatedVisibleLineFile, legalLines)


    filehandler1 = open(outputObjectFile, 'w')
    filehandler2 = open(outputDistanceFile, 'w')
    coordinateNameDict = {}
    coordinateNameDict[start_point] = 0
    coordinateNameDict[goal_point] = 1
    filehandler1.write('%s %s %s\n' % (0, start_point[0], start_point[1]))
    filehandler1.write('%s %s %s\n' % (1, goal_point[0], goal_point[1]))
    currentPointNum = 2
    for eachObstacle in list_of_obs:
    	pointsNum = len(eachObstacle)
    	for i in range(pointsNum):
    		if not coordinateNameDict.has_key(eachObstacle[i]):
    			coordinateNameDict[eachObstacle[i]] = currentPointNum
    			filehandler1.write('%s %s %s\n' % (currentPointNum, eachObstacle[i][0], eachObstacle[i][1]))
    			currentPointNum += 1
    	for i in range(pointsNum):
    		firstPointName = coordinateNameDict[eachObstacle[i%pointsNum]]
    		secondPointName = coordinateNameDict[eachObstacle[(i+1)%pointsNum]]
    		dist = calcDist(eachObstacle[i%pointsNum], eachObstacle[(i+1)%pointsNum])
    		filehandler2.write('%s %s %s\n' % (firstPointName, secondPointName, dist))

    for eachLine in legalLines:
    	if not coordinateNameDict.has_key((eachLine[0], eachLine[1])):
    		coordinateNameDict[(eachLine[0], eachLine[1])] = currentPointNum
    		filehandler1.write('%s %s %s\n' % (currentPointNum, eachLine[0], eachLine[1]))
    		currentPointNum += 1

    	if not coordinateNameDict.has_key((eachLine[2], eachLine[3])):
    		coordinateNameDict[(eachLine[2], eachLine[3])] = currentPointNum
    		filehandler1.write('%s %s %s\n' % (currentPointNum, eachLine[2], eachLine[3]))
    		currentPointNum += 1
    	firstPointName = coordinateNameDict[(eachLine[0], eachLine[1])]
    	secondPointName = coordinateNameDict[(eachLine[2], eachLine[3])]
    	dist = calcDist((eachLine[0], eachLine[1]),(eachLine[2], eachLine[3]))
    	filehandler2.write('%s %s %s\n' % (firstPointName, secondPointName, dist))

    filehandler1.close()
    filehandler2.close()
      
    second_part(inputObsFile, inputDistFile,startPointName,goalPointName)

    master = Tk()
    w = Canvas(master, width=5000, height=5000)
    w.pack()
    plot_obstacle(w,start_point, goal_point, obstaclesFile)
    plot_obstacle(w,start_point, goal_point, grownObstaclesFile)
    plot_obstacle(w,start_point, goal_point, generatedVisibleLineFile)
    plot_obstacle(w,start_point, goal_point, outputFile)
    mainloop()

