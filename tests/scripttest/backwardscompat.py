import sys

def string(string):
    try:
        if sys.version_info >= (3,):
            if isinstance(string, str):
                return string
            return str(string, "utf-8")
        else:
	    return string.decode('utf-8')
    except:
        return string
