# -*- coding: utf-8 -*-
"""
Created on Mon Nov 16 15:41:42 2015

@author: Jasleen
"""

from Tkinter import *
import time
import Queue

def main():

    second_part('samplepoints.txt','distances.txt','A','J')

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
    open_file = open('shortestpath.txt','w')
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
        path_file.write(str((v.x-150)/40))
        path_file.write(" ")
        path_file.write(str((v.y-400)/40))
        
            
        



def plot_obstacle(w, *infiles):

    # assuming all files have the same format
    
    master = Tk()
    w = Canvas(master, width=5000, height=5000)
    w.pack()

    wid = 2
    for filename in infiles:
        infile = open(filename, 'r')
        num_ob = infile.readline()
        num_ob = num_obj.split()
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
                for j in range(len(points)-1):
                    w.create_line(points[j][0], points[j][1], points[j+1][0], points[j+1][1], width = wid)
                w.create_line(points[-1][0],points[-1][1], points[0][0],points[0][1], width = wid)
            infile.close()
            time.sleep(2)
            wid = wid+  2
        # for files with lines formatted x1 y1 x2 y2
        elif len(num_ob) == 4 :
            while(len(num_ob) >0):
                for i in range(len(num_ob)):
                    if i % 2 == 0:
                        num_ob[i] = 400 + float(num_oj[i])*40
                    else:
                        num_ob[i] = 150 + float(num_ob[i])*40
                w.create_line(num_ob[0], num_ob[1], num_ob[2], num_ob[3], width=wid)
                num_ob = infile.readline()
                num_ob = num_ob.split()
            wid =  wid + 2
            time.sleep(2)
        # for giles with lines formatted x1 y1            
        else:
            points = []
            while(len(num_ob)>0):
                num_ob[0] = 400 + float(num_oj[i])*40
                num_ob[1] = 150 + float(num_ob[i])*40
                points.append((num_ob[0],num_ob[1]))
                num_ob = infile.readline()
                num_ob = num_ob.split()
            for i in range(len(points)-1):
                w.create_line(points[i][0], points[i][1], points[i+1][0], points[i+1][1], width=wid)
            w.create_line(points[0][0], points[0][1], points[-1][0], points[-1][1], width=wid)
            wid = wid + 2
            time.sleep(2)
    mainloop()
main()

