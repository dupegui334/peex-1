# peex-1
Repo of exercises and nebo tasks made for PeEx evaluation

## 1. Improve / Fix script

The following script should be taken as an input: https://github.com/realpython/python-scripts/blob/master/scripts/04_rename_with_slice.py. This script renames all files of a specific type in a given folder by removing the last 6 symbols of the existing filename. In this script, the following steps should be taken to improve/fix it:

* sys.argv should be used to avoid hardcoding of folder path (line 4)
* sys.argv should be used to avoid hardcoding a file type (line 5)
* sys.argv should be used to parametrize the desired slicing (line 8)
* String.format() should be replaced with the Python3 f-String (line 14)

```
import os
import glob

os.chdir("/Users/mikeherman/repos/bugs/se-platform/se/core/permissions")
for file in glob.glob("*.json"):
    file_name = os.path.splitext(file)[0]
    extension = os.path.splitext(file)[1]
    new_file_name = file_name[:-6] + extension
    try:
        os.rename(file, new_file_name)
    except OSError as e:
        print(e)
    else:
        print("Renamed {} to {}".format(file, new_file_name))
```