from PIL import Image
import glob
import os

os.chdir("/home/george/Documents/Plotting/NECOFS/forecast/plots")
frames = []

imgs = sorted(glob.glob("*.png"))
for i in imgs:
	new_frame = Image.open(i)
	frames.append(new_frame)

frames[0].save(
	'NECOFS_GOM.gif',
	format='GIF',
	append_images=frames[1:],
	save_all=True,
	duration=200,
	loop=0
)

os.chdir("/home/george/Documents/Plotting/MABAY/forecast/plots")
frames = []

imgs = sorted(glob.glob("*.png"))
for i in imgs:
	new_frame = Image.open(i)
	frames.append(new_frame)

frames[0].save(
	'NECOFS_MABAY.gif',
	format='GIF',
	append_images=frames[1:],
	save_all=True,
	duration=200,
	loop=0
)
