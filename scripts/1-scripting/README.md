## 1. Scripting: 

### Improve / Fix script

The following script should be taken as an input: https://github.com/realpython/python-scripts/blob/master/scripts/04_rename_with_slice.py. This script renames all files of a specific type in a given folder by removing the last 6 symbols of the existing filename. In this script, the following steps should be taken to improve/fix it:

* sys.argv should be used to avoid hardcoding of folder path (line 4)
* sys.argv should be used to avoid hardcoding a file type (line 5)
* sys.argv should be used to parametrize the desired slicing (line 8)
* String.format() should be replaced with the Python3 f-String (line 14)

```
1 import os
2 import glob
3
4 os.chdir("/Users/mikeherman/repos/bugs/se-platform/se/core/permissions")
5 for file in glob.glob("*.json"):
6    file_name = os.path.splitext(file)[0]
7    extension = os.path.splitext(file)[1]
8    new_file_name = file_name[:-6] + extension
9    try:
10        os.rename(file, new_file_name)
11    except OSError as e:
12        print(e)
13    else:
14        print("Renamed {} to {}".format(file, new_file_name))
```

#### Example: Check in ./test-folder and slice 1 character of all .json files located there:
```
❯ python3 04_rename_with_slice.py ./test-folder json 1
Current path ~/peex-1/scripts/test-folder
Renamed file.json to fil.json
Renamed file2.json to file.json
```
