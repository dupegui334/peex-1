import os
import glob
import sys

os.chdir(sys.argv[1])
print(os.getcwd())
for file in glob.glob(f"*.{sys.argv[2]}"):
    file_name = os.path.splitext(file)[0]
    extension = os.path.splitext(file)[1]
    new_file_name = file_name[:-sys.argv[3]] + extension
    try:
        os.rename(file, new_file_name)
    except OSError as e:
        print(e)
    else:
        print("Renamed {} to {}".format(file, new_file_name))