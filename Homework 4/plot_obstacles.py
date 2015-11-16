from Tkinter import *
import time
import math
import random

def main():

    plot_obstacle(w, "points.txt")

def plot_obstacle(w, *infiles):

    # assuming all files have the same format
    
    master = Tk()
    w = Canvas(master, width=5000, height=5000)
    w.pack()

    wid = 2
    for filename in infiles:
        infile = open(filename, 'r')
        num_ob = int(infile.readline())
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
        wid + = 2
    mainloop()
main()
