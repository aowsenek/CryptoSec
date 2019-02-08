import hashlib 
import multiprocessing
import time
import sys

def thread_0_counter(string):
	try:	
		counter = 0
		for i in range(len(string)):
			if string[i] != "0":
				return counter
			else:
				counter += 1
		return counter
	except KeyboardInterrupt:
		return -1

def thread_function(queue, string, start, increment):
	try:
		num = start
		best_string_so_far = ""
		best_count_so_far = -1
		for _ in range(0, 10000000):
			h = hashlib.sha256(string + str(num)).hexdigest()
			temp_count = thread_0_counter(h)

			if temp_count > best_count_so_far:
				best_count_so_far = temp_count
				best_string_so_far = string + str(num)
			
			num += increment

		queue.put((start % increment, best_count_so_far, best_string_so_far))
	except KeyboardInterrupt:
		print "Thread " + str(start % increment) + " kill received, cleaning up ..."
		queue.put((start % increment, best_count_so_far, best_string_so_far))
		return


if __name__ == '__main__':

	start_time = time.clock()

	# printLock = multiprocessing.Lock()

	# manager = multiprocessing.Manager()
	# return_dict = manager.dict()

	queue = multiprocessing.Queue()

	string = 'anow6879-brga0406-nopo4611-'

	processors = []

	max_string = ""
	max_count = -1

	try:
		start_increment = 0
		for i in range(4):
			processors.append(multiprocessing.Process(target=thread_function, args=(queue, string, i + start_increment, 4)))
			processors[i].start()
		for i in range(4):
			processors[i].join()
		start_increment += 10000000*4

		while True:
			for i in range(4):
				processors[i] = multiprocessing.Process(target=thread_function, args=(queue, string, i + start_increment, 4))
				processors[i].start()
			for i in range(4):
				processors[i].join()
			start_increment += 10000000*4

			while not queue.empty():
				thread, count, string = queue.get()
				if count > max_count:
					max_count = count
					max_string = string
			print max_string, hashlib.sha256(max_string).hexdigest(), max_count
			print "Round dont, increment at: " + str(start_increment)

			f = open('bonus.txt', 'w')
			f.write(max_string + " " + hashlib.sha256(max_string).hexdigest() + " " + str(max_count))
			f.close()

	except KeyboardInterrupt:
		print "Interrupt Caught, Cleaning Up..."

		for i in range(4):
			processors[i].join()

		max_string = None
		max_count = -1
		while not queue.empty():
			thread, count, string = queue.get()
			if count > max_count:
				max_count = count
				max_string = string

		print max_string, hashlib.sha256(max_string).hexdigest(), max_count

		f = open('bonus.txt', 'w')
		f.write(max_string + " " + hashlib.sha256(max_string).hexdigest() + " " + str(max_count))
		f.close()

		print time.clock() - start_time

		sys.exit()

	max_string = None
	max_count = -1
	while not queue.empty():
		thread, count, string = queue.get()
		if count > max_count:
			max_count = count
			max_string = string

	print max_string, hashlib.sha256(max_string).hexdigest(), max_count

	f = open('bonus.txt', 'w')
	f.write(max_string + " " + hashlib.sha256(max_string).hexdigest() + " " + str(max_count))
	f.close()

	print time.clock() - start_time