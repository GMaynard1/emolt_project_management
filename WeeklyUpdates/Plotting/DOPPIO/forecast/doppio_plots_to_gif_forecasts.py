from PIL import Image
import glob
import os

# os.chdir("/home/george/Documents/Plotting/DOPPIO/forecast/plots/C")
# frames = []
#
# imgs = sorted(glob.glob("*.png"))
# for i in imgs:
# 	new_frame = Image.open(i)
# 	frames.append(new_frame)
#
# frames[0].save(
# 	'DOPPIO_forecast_C.gif',
# 	format='GIF',
# 	append_images=frames[1:],
# 	save_all=True,
# 	duration=len(imgs)*1,
# 	loop=0
# )

os.chdir("/home/george/Documents/Plotting/DOPPIO/forecast/plots/F")
frames = []

imgs = sorted(glob.glob("*.png"))
for i in imgs:
	new_frame = Image.open(i)
	frames.append(new_frame)

frames[0].save(
	'DOPPIO_forecast_F.gif',
	format='GIF',
	append_images=frames[1:],
	save_all=True,
	duration=200,
	loop=0
)

