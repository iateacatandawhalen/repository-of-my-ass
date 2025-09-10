import pygame
import math
import numpy as np

# Window
WIDTH, HEIGHT = 400, 400
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("2D Ray-Marched Rotating Player")
clock = pygame.time.Clock()

# Scene
circles = [{"pos": (200, 200), "r": 50}, {"pos": (300, 150), "r": 30}]
polygons = [[(50,50),(100,50),(100,100),(50,100)], [(250,300),(350,300),(350,350),(250,350)]]
mirrors = [{"start": (100,300), "end": (200,300)}, {"start": (250,250), "end": (300,300)}]

# Player cube
player = {"pos": [50,50], "size": 12, "speed": 2, "angle": 0}  # angle in radians

# NumPy array for pixels
pixels = np.zeros((HEIGHT, WIDTH, 3), dtype=np.uint8)

# Utilities
def length(a,b): return math.hypot(a[0]-b[0], b[1]-a[1])
def normalize(v):
    l = math.hypot(v[0],v[1])
    return (v[0]/l, v[1]/l) if l>0 else (0,0)
def point_to_segment_distance(p, a, b):
    vx, vy = b[0]-a[0], b[1]-a[1]
    wx, wy = p[0]-a[0], p[1]-a[1]
    c1 = wx*vx + wy*vy
    c2 = vx*vx + vy*vy
    t = max(0, min(1, c1/c2 if c2 !=0 else 0))
    closest = (a[0]+t*vx, a[1]+t*vy)
    dx, dy = p[0]-closest[0], p[1]-closest[1]
    return math.hypot(dx, dy)

def sdf_circle(p,c): return length(p,c["pos"]) - c["r"]
def sdf_polygon(p,poly): return min([point_to_segment_distance(p,poly[i],poly[(i+1)%len(poly)]) for i in range(len(poly))])
def scene_sdf(p):
    d = min([sdf_circle(p,c) for c in circles] + [sdf_polygon(p,poly) for poly in polygons])
    return d

def reflect(dir, normal):
    dot = dir[0]*normal[0]+dir[1]*normal[1]
    return (dir[0]-2*dot*normal[0], dir[1]-2*dot*normal[1])

def march_ray(origin, dir, max_dist=400, max_steps=200, bounces=0, max_bounces=3):
    pos = list(origin)
    t_total = 0
    brightness = 0
    for _ in range(max_steps):
        d = scene_sdf(pos)
        if d < 0.5:
            brightness = max(0, 255 - int(t_total*0.8))
            return brightness
        # Mirror reflection
        for m in mirrors:
            dist_to_mirror = point_to_segment_distance(pos,m["start"], m["end"])
            if dist_to_mirror < 1.0 and bounces < max_bounces:
                dx, dy = m["end"][0]-m["start"][0], m["end"][1]-m["start"][1]
                norm = normalize((-dy, dx))
                dir = reflect(normalize(dir), norm)
                bounces +=1
                break
        t_total += d
        if t_total > max_dist:
            break
        pos[0] += dir[0]*d
        pos[1] += dir[1]*d
    return 0

# Main loop
running = True
fov = math.radians(60)
num_rays = 200

while running:
    dt = clock.tick(30)
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

    # Player movement
    keys = pygame.key.get_pressed()
    if keys[pygame.K_w]: player["pos"][1] -= player["speed"]
    if keys[pygame.K_s]: player["pos"][1] += player["speed"]
    if keys[pygame.K_a]: player["pos"][0] -= player["speed"]
    if keys[pygame.K_d]: player["pos"][0] += player["speed"]

    # Direction toward mouse
    mouse = pygame.mouse.get_pos()
    dx, dy = mouse[0]-player["pos"][0], mouse[1]-player["pos"][1]
    player["angle"] = math.atan2(dy, dx)  # rotate player cube

    # Clear pixels
    pixels[:,:,:] = 0

    # Cast rays in FOV from player facing direction
    for i in range(num_rays):
        angle = player["angle"] - fov/2 + fov*i/num_rays
        dir = (math.cos(angle), math.sin(angle))
        # Soft shadow: multiple samples
        samples = []
        for offset in [(-0.3,-0.3),(0,0),(0.3,0.3)]:
            dir_off = normalize((dir[0]+offset[0]*0.01, dir[1]+offset[1]*0.01))
            samples.append(march_ray(player["pos"], dir_off))
        brightness = int(sum(samples)/len(samples))
        # Draw light along ray
        pos = list(player["pos"])
        for step in range(int(brightness/2)):
            px = int(pos[0])
            py = int(pos[1])
            if 0<=px<WIDTH and 0<=py<HEIGHT:
                pixels[py,px,:] = (brightness, brightness, brightness)
            pos[0] += dir[0]
            pos[1] += dir[1]

    # Draw mirrors (blue) and polygons (gray)
    for m in mirrors: pygame.draw.line(screen,(0,0,255), m["start"], m["end"],2)
    for poly in polygons: pygame.draw.polygon(screen,(100,100,100),poly,1)

    # Draw player cube rotated
    cx, cy = player["pos"]
    s = player["size"]
    angle = player["angle"]
    # Compute rotated square corners
    corners = []
    for dx, dy in [(-s/2,-s/2),(s/2,-s/2),(s/2,s/2),(-s/2,s/2)]:
        rx = dx*math.cos(angle) - dy*math.sin(angle) + cx
        ry = dx*math.sin(angle) + dy*math.cos(angle) + cy
        corners.append((rx, ry))
    pygame.draw.polygon(screen,(0,255,0),corners)

    # Blit pixels
    pygame.surfarray.blit_array(screen,pixels)
    pygame.display.flip()

pygame.quit()