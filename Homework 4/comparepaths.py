# output: description of the obstacles files(same format)

# second_part(cross out the invalid visible lines):
# input: two files A, B, A is the description of the obstacles files, B is newly created visible lines
#   (x1,y1,x2,y2)
# output: description of every valid visible lines

#if any line segment intersects 


def convert_obst(grown_ob_file):
    file_a = open(grown_ob_file, 'r')
    ob_edges = []
    num_ob = int(file_a.readline())
    
    literally_all_points = []

    for i in range(num_ob):
        all_points = []
        num_vert = int(file_a.readline())
        point = int(file_a.readline())
        point1 = point1.split()
        point1[0] = float(point1[0])
        point1[1] = float(point1[1])
        all_points.append((point1[0],point1[1]))
        literally_all_points.append(())
        for j in range(len(all_points)-1):
            ob_edges.append((all_points[j][0],all_points[j][1],all_points[j+1][0],all_points[j+1][1]))
        ob_edges.append((allpoints[0][0],allpoints[0][1],allpoints[-1][0],allpoints[-1][1]))        


    return ob_edges



    

def generate_visible_lines(walls, list_of_obs, start_point, end_point):
    # walls is list of tuples of points
    # list_of_obs is list of lists
    #     each sublist is composed of tuples of points

    for each_ob in list_of_obs:
        for each_corner in each_ob:
            if each_corner == (each_ob+1).


