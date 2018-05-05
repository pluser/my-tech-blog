---
title: Python・デ・モンテカルロ
date: 2017-01-28 16:27:00
draft: false
---

最近Pythonで書いてないなーと思ったので、matplotlibの習得も兼ねてモンテカルロ法（乱択アルゴリズム）を使って円周率を求めてみました。アニメーションでわかるようになっていますが、かなり収束が悪く、10,0000点を打っても有効数字3桁がやっとです。

``` python
#!/usr/bin/python3

import math
import matplotlib as mpl
import matplotlib.patches, matplotlib.pyplot, matplotlib.animation
try:
	import numpy.random
except ImportError:
	import random

def _setup_graph():
	fig = mpl.pyplot.figure()
	ax = fig.add_subplot(1, 1, 1)
	#ax.add_patch(mpl.patches.PathPatch(mpl.path.Path.circle(), facecolor='none'))
	ax.add_patch(mpl.patches.Circle((0, 0), radius=1, facecolor='none'))
	ax.set_xlim(0, 1)
	ax.set_ylim(0, 1)
	ax.set_aspect('equal')
	return fig

def _plot_next(fig, lump=False):
	ax = fig.gca()
	f_cnt = 0
	hit_in = 0
	hit_out = 0
	hitbox = ax.text(0.1, 0.1, "", fontsize=24, bbox={"facecolor": "white", "pad": 20})
	while True:
		f_cnt += 1
		if lump:
			pin, pout = list(), list()
			if 'numpy' in globals():
				coor = numpy.random.rand(lump, 2)
			else:
				coor = [(random.random(), random.random()) for i in range(lump)]
			for x, y in coor:
				distance = math.sqrt(pow(x, 2)+pow(y, 2))
				if distance <= 1:
					hit_in += 1
					pin.append((x, y))
				else:
					hit_out += 1
					pout.append((x, y))
			ax.plot(list(zip(*pin))[0], list(zip(*pin))[1], "bx")
			ax.plot(list(zip(*pout))[0], list(zip(*pout))[1], "rx")
		else:
			if 'numpy' in globals():
				x, y = numpy.random.rand(), numpy.random.rand()
			else:
				x, y = random.random(), random.random()
			distance = math.sqrt(pow(x, 2)+pow(y, 2))
			if distance <= 1:
				hit_in += 1
				ax.plot(x, y, "bx")
			else:
				hit_out += 1
				ax.plot(x, y, "rx")
		est_pi = 4 * hit_in / (hit_in + hit_out)
		hitbox.set_text("totalcount={}\nhitcount_in={}\nhitcount_out={}\nestimated_pi={:.4f}\n"
						.format(hit_in+hit_out, hit_in, hit_out, est_pi))
		yield fig

def get_result(fig):
	plot = _plot_next(fig, lump=100)
	for i in range(100):
		next(plot)
	fig.show()

def get_anim(fig):
	plot = _plot_next(fig, lump=100)
	mpl.animation.FuncAnimation(fig, lambda x: next(plot), interval=0)
	fig.show()

if __name__ == "__main__":
	fig = _setup_graph()
	#get_result(fig)
	get_anim(fig)
	input()
```
