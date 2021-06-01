import multiprocessing

bind = "0.0.0.0:8085"
workers = multiprocessing.cpu_count() * 2 + 1
